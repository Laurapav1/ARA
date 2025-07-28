// cmd/api/main.go
package main

import (
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
	"github.com/winrarr/ARA/internal/config"
	"github.com/winrarr/ARA/internal/db"
	"github.com/winrarr/ARA/internal/handlers"
	"github.com/winrarr/ARA/internal/models"
)

func main() {
	// 1) Load configuration
	cfg := config.Load()

	// 2) Connect to the database via GORM
	gormDB := db.ConnectGORM(cfg)

	// 3) If you need the underlying *sql.DB for pinging, closing, etc.
	sqlDB, err := gormDB.DB()
	if err != nil {
		log.Fatalf("unable to get sql.DB from GORM: %v", err)
	}
	defer sqlDB.Close()

	// 4) Auto‑migrate your models
	if err := gormDB.AutoMigrate(
		&models.User{},
	); err != nil {
		log.Fatalf("auto‑migration failed: %v", err)
	}

	// 5) Spin up Gin and register routes
	router := gin.Default()
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	router.POST(
		"/signup",
		handlers.Signup(gormDB),
	)
	// staff approves a volunteer
	router.PUT(
		"/volunteers/:id/approve",
		handlers.ApproveVolunteer(gormDB),
	)

	// 6) Start listening
	addr := fmt.Sprintf(":%s", cfg.Port)
	log.Printf("Starting server on %s", addr)
	if err := router.Run(addr); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
