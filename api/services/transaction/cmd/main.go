package main

import (
	"log"
	"os"
	"pushtaka/pkg/database"
	"pushtaka/pkg/messaging"
	"pushtaka/services/transaction/internal/domain"
	"pushtaka/services/transaction/internal/handler"
	"pushtaka/services/transaction/internal/repository"
	"pushtaka/services/transaction/internal/usecase"
	msgConsumer "pushtaka/services/transaction/internal/messaging"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	_ "gorm.io/driver/postgres"
	_ "gorm.io/gorm"
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
	db.AutoMigrate(&domain.Transaction{})

	// RabbitMQ
	conn, ch, err := messaging.ConnectRabbitMQ(os.Getenv("RABBITMQ_URL"))
	if err != nil {
		log.Fatalf("Failed to connect to RabbitMQ: %v", err)
	}
	defer conn.Close()
	defer ch.Close()

	// Queue Declare
	_, err = ch.QueueDeclare(
		"stock_updates", // name
		true,            // durable
		false,           // delete when unused
		false,           // exclusive
		false,           // no-wait
		nil,             // arguments
	)
	if err != nil {
		log.Fatalf("Failed to declare queue: %v", err)
	}

	// App
	app := fiber.New()
	app.Use(logger.New())

	// Init Layers
	timeoutContext := time.Duration(2) * time.Second
	txRepo := repository.NewPostgresTransactionRepo(db)
	txUsecase := usecase.NewTransactionUsecase(txRepo, timeoutContext, ch)

	// Start Consumer
	consumer := msgConsumer.NewConsumer(txUsecase)
	go func() {
		consumer.Start(conn)
	}()

	// Init Handler
	handler.NewTransactionHandler(app, txUsecase)

	log.Fatal(app.Listen(":3000"))
}
