package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"

	"baca-komik-api/database"
	"baca-komik-api/services"
)

// SetupHandler handles setup-related requests
type SetupHandler struct {
	setupService *services.SetupService
	logger       *logrus.Logger
}

// NewSetupHandler creates a new setup handler
func NewSetupHandler(db *database.DB) *SetupHandler {
	baseService := services.NewBaseService(db)
	setupService := services.NewSetupService(baseService)

	return &SetupHandler{
		setupService: setupService,
		logger:       logrus.New(),
	}
}

// CreateAdminUser - EXACT COPY from Next.js /api/setup/route.ts
func (h *SetupHandler) CreateAdminUser(c *gin.Context) {
	// Create admin user from service
	result, err := h.setupService.CreateAdminUser()
	if err != nil {
		if err.Error() == "admin user already exists" {
			c.JSON(http.StatusOK, gin.H{"message": "Admin user already exists"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		}
		return
	}

	// Return success response - EXACTLY like Next.js lines 57-66
	c.JSON(http.StatusCreated, result)
}
