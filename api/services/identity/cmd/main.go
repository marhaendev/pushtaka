package main

import (
	"log"
	"os"
	"strconv"
	"time"

	"pushtaka/pkg/database"
	"pushtaka/pkg/mail"
	"pushtaka/pkg/middleware"
	"pushtaka/services/identity/internal/domain"
	"pushtaka/services/identity/internal/handler"
	"pushtaka/services/identity/internal/repository"
	"pushtaka/services/identity/internal/usecase"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
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
	db.AutoMigrate(&domain.User{}, &domain.Config{})

	// Mail Config
	mailPort, _ := strconv.Atoi(os.Getenv("SMTP_PORT"))
	mailCfg := mail.MailConfig{
		Host:     os.Getenv("SMTP_HOST"),
		Port:     mailPort,
		User:     os.Getenv("SMTP_USER"),
		Password: os.Getenv("SMTP_PASS"),
	}
	mailSender := mail.NewMailSender(mailCfg)

	// App
	app := fiber.New()
	app.Use(logger.New())
	app.Use(cors.New())

	// Init Layers
	timeoutContext := time.Duration(2) * time.Second
	userRepo := repository.NewUserRepository(db)
	authUsecase := usecase.NewAuthUsecase(userRepo, mailSender, timeoutContext)
	userUsecase := usecase.NewUserUsecase(userRepo, timeoutContext)
	settingsUsecase := usecase.NewSettingsUsecase(userRepo, timeoutContext)

	// Init Middleware
	roleMiddleware := middleware.NewRoleMiddleware()

	// Init Handler
	handler.NewAuthHandler(app, authUsecase)
	handler.NewUserHandler(app, userUsecase, roleMiddleware.RequireRole(domain.RoleAdmin), roleMiddleware.RequireAuth())
	handler.NewSettingsHandler(app, settingsUsecase, roleMiddleware.RequireRole(domain.RoleAdmin))

	// Start server
	log.Fatal(app.Listen(":3000"))
}
