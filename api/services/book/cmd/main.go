package main

import (
	"log"
	"os"
	"pushtaka/pkg/database"
	"pushtaka/pkg/messaging"
	"pushtaka/services/book/internal/domain"
	"pushtaka/services/book/internal/handler"
	msgConsumer "pushtaka/services/book/internal/messaging"
	"pushtaka/services/book/internal/repository"
	"pushtaka/services/book/internal/usecase"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
)

func main() {
	// DB Config
	cfg := database.DBConfig{
		Host:     os.Getenv("DB_Host"),
		User:     os.Getenv("DB_User"),
		Password: os.Getenv("DB_Password"),
		Name:     os.Getenv("DB_Name"),
		Port:     os.Getenv("DB_Port"),
	}

	db, err := database.Connect(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// Auto Migrate
	db.AutoMigrate(&domain.Book{}, &domain.Favorite{})

	// App
	app := fiber.New()
	app.Use(logger.New())

	// Init Layers
	timeoutContext := time.Duration(2) * time.Second
	
	// RabbitMQ Connection
	conn, ch, err := messaging.ConnectRabbitMQ(os.Getenv("RABBITMQ_URL"))
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer conn.Close()
	defer ch.Close()

	bookRepo := repository.NewPostgresBookRepo(db)
	favoriteRepo := repository.NewPostgresFavoriteRepo(db)
	
	bookPublisher := msgConsumer.NewBookPublisher(ch)
	bookUsecase := usecase.NewBookUsecase(bookRepo, bookPublisher, timeoutContext)
	favoriteUsecase := usecase.NewFavoriteUsecase(favoriteRepo, timeoutContext)

	// Init Handler
	handler.NewBookHandler(app, bookUsecase)
	handler.NewFavoriteHandler(app, favoriteUsecase)

	// RabbitMQ Consumer
	go func() {
		log.Println("Connected to RabbitMQ, starting consumer...")
		msgConsumer.StartConsumer(conn, bookRepo)
	}()

	// Start server
	log.Fatal(app.Listen(":3000"))
}
