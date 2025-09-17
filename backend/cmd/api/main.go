// cmd/api/main.go
package main

import (
	"fmt"
	"log"

	"github.com/gin-gonic/gin"
	"github.com/winrarr/ARA/internal/config"
	"github.com/winrarr/ARA/internal/db"
	"github.com/winrarr/ARA/internal/handlers/auth"
	"github.com/winrarr/ARA/internal/models"
)

func main() {
	cfg := config.Load()
	gormDB := db.ConnectGORM(cfg)

	// 3) If you need the underlying *sql.DB for pinging, closing, etc.
	sqlDB, err := gormDB.DB()
	if err != nil {
		log.Fatalf("unable to get sql.DB from GORM: %v", err)
	}
	defer sqlDB.Close()

	if err := gormDB.AutoMigrate(
		&models.User{},
	); err != nil {
		log.Fatalf("auto‑migration failed: %v", err)
	}

	api := &auth.API{DB: gormDB}

	router := gin.Default()
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	router.POST("/signup", api.Signup)
	router.POST("/login", api.Login)

	router.PUT("/volunteers/:id/approve", api.ApproveVolunteer)
	router.PUT("/volunteers/:id/decline", api.DeclineVolunteer)

	addr := fmt.Sprintf(":%s", cfg.Port)
	log.Printf("Starting server on %s", addr)
	if err := router.Run(addr); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
