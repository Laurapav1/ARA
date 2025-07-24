// internal/models/user.go
package models

import "gorm.io/gorm"

type User struct {
	gorm.Model // provides ID, CreatedAt, UpdatedAt, DeletedAt
	FirstName  string
	LastName   string
	Email      string `gorm:"uniqueIndex"`
	Role       string // "volunteer" or "staff"
	Status     string // "pending", "approved", "declined"
}
