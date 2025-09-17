package auth

import (
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/winrarr/ARA/internal/models"
)

// DeclineVolunteer marks a volunteer’s status as "declined".
func (api *API) DeclineVolunteer(c *gin.Context) {
	id := c.Param("id")

	// Update status to "declined"
	result := api.DB.
		Model(&models.User{}).
		Where("id = ? AND role = ?", id, "volunteer").
		Update("status", "declined")

	if result.Error != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "couldn’t decline volunteer"})
		return
	}
	if result.RowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{
			"error": fmt.Sprintf("no volunteer found with id %s", id),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "volunteer declined"})
}
