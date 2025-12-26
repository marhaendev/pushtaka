package database

import (
	"fmt"
	"log"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

type DBConfig struct {
	Host     string
	User     string
	Password string
	Name     string
	Port     string
}

func Connect(cfg DBConfig) (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Jakarta",
		cfg.Host,
		cfg.User,
		cfg.Password,
		cfg.Name,
		cfg.Port,
	)

	var db *gorm.DB
	var err error

	// GORM Config with Silent Logger
	gormConfig := &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	}

	for i := 0; i < 5; i++ {
		db, err = gorm.Open(postgres.Open(dsn), gormConfig)
		if err == nil {
			// Configure Connection Pool
			sqlDB, sqlErr := db.DB()
			if sqlErr == nil {
				sqlDB.SetMaxIdleConns(10)
				sqlDB.SetMaxOpenConns(100)
				sqlDB.SetConnMaxLifetime(time.Hour)
			}
			return db, nil
		}
		log.Printf("[pkg/database] Failed to connect, retrying in 2s... (%d/5)", i+1)
		time.Sleep(2 * time.Second)
	}

	return nil, fmt.Errorf("[pkg/database] failed to connect after retries: %v", err)
}
