package config

import (
	"log"
	"os"
	"strings"

	"github.com/spf13/viper"
)

type Config struct {
	// Server Configuration
	Port    string `mapstructure:"PORT"`
	GinMode string `mapstructure:"GIN_MODE"`
	LogLevel string `mapstructure:"LOG_LEVEL"`

	// Supabase Configuration
	SupabaseURL        string `mapstructure:"SUPABASE_URL"`
	SupabaseAnonKey    string `mapstructure:"SUPABASE_ANON_KEY"`
	SupabaseServiceKey string `mapstructure:"SUPABASE_SERVICE_KEY"`

	// Database Configuration
	DBHost     string `mapstructure:"DB_HOST"`
	DBPort     string `mapstructure:"DB_PORT"`
	DBName     string `mapstructure:"DB_NAME"`
	DBUser     string `mapstructure:"DB_USER"`
	DBPassword string `mapstructure:"DB_PASSWORD"`
	DBSSLMode  string `mapstructure:"DB_SSL_MODE"`

	// JWT Configuration
	JWTSecret string `mapstructure:"JWT_SECRET"`

	// CORS Configuration
	CORSAllowedOrigins []string `mapstructure:"CORS_ALLOWED_ORIGINS"`
	CORSAllowedMethods []string `mapstructure:"CORS_ALLOWED_METHODS"`
	CORSAllowedHeaders []string `mapstructure:"CORS_ALLOWED_HEADERS"`
}

func Load() *Config {
	viper.SetConfigName(".env")
	viper.SetConfigType("env")
	viper.AddConfigPath(".")
	viper.AutomaticEnv()

	// Set default values
	setDefaults()

	// Read config file if exists
	if err := viper.ReadInConfig(); err != nil {
		log.Println("No config file found, using environment variables and defaults")
	}

	var config Config
	if err := viper.Unmarshal(&config); err != nil {
		log.Fatal("Failed to unmarshal config:", err)
	}

	// Fallback: Read critical environment variables directly if empty
	if config.DBPassword == "" {
		config.DBPassword = os.Getenv("DB_PASSWORD")
	}
	if config.SupabaseServiceKey == "" {
		config.SupabaseServiceKey = os.Getenv("SUPABASE_SERVICE_KEY")
	}

	// Debug logging for Railway
	log.Printf("Config loaded - DB_HOST: %s", config.DBHost)
	log.Printf("Config loaded - DB_USER: %s", config.DBUser)
	log.Printf("Config loaded - DB_PASSWORD: %s", maskPassword(config.DBPassword))
	log.Printf("Config loaded - SUPABASE_SERVICE_KEY: %s", maskPassword(config.SupabaseServiceKey))

	// Parse comma-separated values for CORS
	if corsOrigins := os.Getenv("CORS_ALLOWED_ORIGINS"); corsOrigins != "" {
		config.CORSAllowedOrigins = strings.Split(corsOrigins, ",")
	}
	if corsMethods := os.Getenv("CORS_ALLOWED_METHODS"); corsMethods != "" {
		config.CORSAllowedMethods = strings.Split(corsMethods, ",")
	}
	if corsHeaders := os.Getenv("CORS_ALLOWED_HEADERS"); corsHeaders != "" {
		config.CORSAllowedHeaders = strings.Split(corsHeaders, ",")
	}

	return &config
}

func maskPassword(password string) string {
	if password == "" {
		return "[EMPTY]"
	}
	if len(password) <= 4 {
		return "[MASKED]"
	}
	return password[:4] + "****"
}

func setDefaults() {
	// Server defaults
	viper.SetDefault("PORT", "8080")
	viper.SetDefault("GIN_MODE", "debug")
	viper.SetDefault("LOG_LEVEL", "info")

	// Supabase defaults (from existing Next.js config)
	viper.SetDefault("SUPABASE_URL", "https://owiowqcpkksbuuoyhplm.supabase.co")
	viper.SetDefault("SUPABASE_ANON_KEY", "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im93aW93cWNwa2tzYnV1b3locGxtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDYwNzc5MTEsImV4cCI6MjA2MTY1MzkxMX0.T230qvftj_LATF2tg1zKdHpMRjr0tqyIsP-zcMxVlco")

	// Database defaults (updated for Railway)
	viper.SetDefault("DB_HOST", "aws-0-ap-southeast-1.pooler.supabase.com")
	viper.SetDefault("DB_PORT", "5432")
	viper.SetDefault("DB_NAME", "postgres")
	viper.SetDefault("DB_USER", "postgres.owiowqcpkksbuuoyhplm")
	viper.SetDefault("DB_SSL_MODE", "require")
	// Note: DB_PASSWORD should be set via environment variable

	// CORS defaults
	viper.SetDefault("CORS_ALLOWED_ORIGINS", []string{"*"})
	viper.SetDefault("CORS_ALLOWED_METHODS", []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"})
	viper.SetDefault("CORS_ALLOWED_HEADERS", []string{"Origin", "Content-Type", "Accept", "Authorization", "X-Requested-With"})
}
