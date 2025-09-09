package auth

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/winrarr/ARA/internal/auth"
	"github.com/winrarr/ARA/internal/models"
)

type SignupRequest struct {
	FirstName string `json:"first_name" binding:"required"`
	LastName  string `json:"last_name" binding:"required"`
	Email     string `json:"email" binding:"required,email"`
	Password  string `json:"password" binding:"required"`
}

func (api *API) Signup(c *gin.Context) {
	var req SignupRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	req.Email = strings.ToLower(req.Email)

	hash, err := auth.HashPassword(req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "couldn’t hash password"})
		return
	}

	user := models.User{
		FirstName: req.FirstName,
		LastName:  req.LastName,
		Email:     req.Email,
		Password:  hash,
		Role:      "volunteer",
		Status:    "pending",
	}
	if err := api.DB.Create(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "couldn’t create user"})
		return
	}
	c.JSON(http.StatusCreated, gin.H{"message": "signup successful; awaiting approval"})
}
