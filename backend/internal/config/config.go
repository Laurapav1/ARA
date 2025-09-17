package config

import (
	"os"
)

type Config struct {
	Port   string
	DBHost string
	DBPort string
	DBUser string
	DBPass string
	DBName string
}

func Load() *Config {
	cfg := &Config{
		Port:   os.Getenv("PORT"),
		DBHost: os.Getenv("DB_HOST"),
		DBPort: os.Getenv("DB_PORT"),
		DBUser: os.Getenv("DB_USER"),
		DBPass: os.Getenv("DB_PASS"),
		DBName: os.Getenv("DB_NAME"),
	}

	return cfg
}
