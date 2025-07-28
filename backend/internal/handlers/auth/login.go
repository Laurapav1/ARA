package auth

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/winrarr/ARA/internal/auth"
	"github.com/winrarr/ARA/internal/models"
	"gorm.io/gorm"
)

type LoginRequest struct {
	Email    string `json:"email"    binding:"required,email"`
	Password string `json:"password" binding:"required"`
}

func (api *API) Login(c *gin.Context) {
	var req LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 1) Find user
	var user models.User
	if err := api.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "db error"})
		}
		return
	}

	// 2) Check approved status
	if user.Status != "approved" {
		c.JSON(http.StatusForbidden, gin.H{"error": "account not approved"})
		return
	}

	// 3) Verify password
	if err := auth.CheckPassword(user.Password, req.Password); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid credentials"})
		return
	}

	// 4) Generate JWT
	token, err := auth.GenerateToken(user.ID, user.Role)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "couldn't create token"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"token": token})
}
