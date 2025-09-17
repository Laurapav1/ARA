package db

import (
	"fmt"
	"log"

	"github.com/winrarr/ARA/internal/config"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

// ConnectGORM opens a GORM DB connection.
func ConnectGORM(cfg *config.Config) *gorm.DB {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		cfg.DBHost, cfg.DBPort, cfg.DBUser, cfg.DBPass, cfg.DBName,
	)
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		log.Fatalf("failed to connect to DB with GORM: %v", err)
	}
	return db
}
