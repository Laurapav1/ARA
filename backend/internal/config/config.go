package config

import "os"

type Config struct {
	Port, DBHost, DBPort, DBUser, DBPass, DBName string
}

func Load() *Config {
	return &Config{
		Port:   os.Getenv("PORT"),
		DBHost: os.Getenv("DB_HOST"),
		DBPort: os.Getenv("DB_PORT"),
		DBUser: os.Getenv("DB_USER"),
		DBPass: os.Getenv("DB_PASS"),
		DBName: os.Getenv("DB_NAME"),
	}
}
