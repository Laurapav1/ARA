package handlers

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/winrarr/ARA/internal/models"
	"gorm.io/gorm"
)

func ApproveVolunteer(db *gorm.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.Param("id")

		// Perform the update and capture the result
		result := db.
			Model(&models.User{}).
			Where("id = ? AND role = ?", id, "volunteer").
			Update("status", "approved")

		if result.Error != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "couldn’t approve volunteer"})
			return
		}
		if result.RowsAffected == 0 {
			// No row matched—return 404
			c.JSON(http.StatusNotFound, gin.H{
				"error": fmt.Sprintf("no volunteer found with id %s", id),
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{"message": "volunteer approved"})
	}
}
