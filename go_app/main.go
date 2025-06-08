package main

import (
	"log"
	"os"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	"baca-komik-api/config"
	"baca-komik-api/database"
	"baca-komik-api/middleware"
	"baca-komik-api/routes"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Initialize configuration
	cfg := config.Load()

	// Set Gin mode
	gin.SetMode(cfg.GinMode)

	// Initialize database connection
	db, err := database.Connect(cfg)
	if err != nil {
		log.Printf("Warning: Failed to connect to database: %v", err)
		log.Println("Running in development mode without database connection")
		db = nil // Set to nil for development mode
	} else {
		defer db.Close()
	}

	// Initialize Gin router
	router := gin.New()

	// Setup middleware
	middleware.Setup(router, cfg)

	// Setup routes
	routes.Setup(router, db, cfg)

	// Get port from environment or use default
	port := os.Getenv("PORT")
	if port == "" {
		port = cfg.Port
	}

	// Start server
	log.Printf("Server starting on port %s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
