package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"baca-komik-api/database"
	"baca-komik-api/services"
)

type HealthHandler struct {
	db          *database.DB
	testService *services.TestService
}

func NewHealthHandler(db *database.DB) *HealthHandler {
	return &HealthHandler{
		db:          db,
		testService: services.NewTestService(db),
	}
}

func (h *HealthHandler) Health(c *gin.Context) {
	// Check database health
	if err := h.db.Health(); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status":   "unhealthy",
			"database": "disconnected",
			"error":    err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":   "healthy",
		"database": "connected",
		"version":  "1.0.0",
		"service":  "baca-komik-api",
	})
}

func (h *HealthHandler) TestDatabase(c *gin.Context) {
	// Run comprehensive database tests
	if err := h.testService.RunAllTests(); err != nil {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"status": "failed",
			"error":  err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"status":  "success",
		"message": "All database tests passed",
	})
}
