package config

type Config struct {
  Port, DBHost, DBPort, DBUser, DBPass, DBName string
}

func Load() *Config {
  return &Config{}
}
