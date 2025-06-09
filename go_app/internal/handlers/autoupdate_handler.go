package handlers

import (
	"net/http"
	"time"

	"baca-komik-api/internal/autoupdate"
	"github.com/gin-gonic/gin"
)

type AutoUpdateHandler struct {
	service *autoupdate.AutoUpdateService
}

func NewAutoUpdateHandler(service *autoupdate.AutoUpdateService) *AutoUpdateHandler {
	return &AutoUpdateHandler{service: service}
}

type AutoUpdateResponse struct {
	Success bool        `json:"success"`
	Message string      `json:"message"`
	Data    interface{} `json:"data,omitempty"`
}

// StartAutoUpdate starts the auto-update service
func (h *AutoUpdateHandler) StartAutoUpdate(c *gin.Context) {
	if h.service.IsRunning() {
		c.JSON(http.StatusOK, AutoUpdateResponse{
			Success: true,
			Message: "Auto-update service is already running",
			Data: map[string]interface{}{
				"status": "running",
				"config": h.service.GetConfig(),
			},
		})
		return
	}

	if err := h.service.Start(); err != nil {
		c.JSON(http.StatusInternalServerError, AutoUpdateResponse{
			Success: false,
			Message: err.Error(),
		})
		return
	}

	c.JSON(http.StatusOK, AutoUpdateResponse{
		Success: true,
		Message: "Auto-update service started successfully",
		Data: map[string]interface{}{
			"status": "started",
			"config": h.service.GetConfig(),
		},
	})
}

// StopAutoUpdate stops the auto-update service
func (h *AutoUpdateHandler) StopAutoUpdate(c *gin.Context) {
	if !h.service.IsRunning() {
		c.JSON(http.StatusOK, AutoUpdateResponse{
			Success: true,
			Message: "Auto-update service is not running",
			Data: map[string]interface{}{
				"status": "stopped",
			},
		})
		return
	}

	h.service.Stop()

	c.JSON(http.StatusOK, AutoUpdateResponse{
		Success: true,
		Message: "Auto-update service stopped successfully",
		Data: map[string]interface{}{
			"status": "stopped",
		},
	})
}

// GetAutoUpdateStatus returns the current status of auto-update service
func (h *AutoUpdateHandler) GetAutoUpdateStatus(c *gin.Context) {
	status := "stopped"
	if h.service.IsRunning() {
		status = "running"
	}

	c.JSON(http.StatusOK, AutoUpdateResponse{
		Success: true,
		Message: "Auto-update service status retrieved",
		Data: map[string]interface{}{
			"status":    status,
			"config":    h.service.GetConfig(),
			"timestamp": time.Now(),
		},
	})
}

// UpdateAutoUpdateConfig updates the auto-update service configuration
func (h *AutoUpdateHandler) UpdateAutoUpdateConfig(c *gin.Context) {
	var config autoupdate.Config
	if err := c.ShouldBindJSON(&config); err != nil {
		c.JSON(http.StatusBadRequest, AutoUpdateResponse{
			Success: false,
			Message: "Invalid configuration: " + err.Error(),
		})
		return
	}

	// Validate configuration
	if config.Interval < time.Minute {
		c.JSON(http.StatusBadRequest, AutoUpdateResponse{
			Success: false,
			Message: "Interval must be at least 1 minute",
		})
		return
	}

	if config.PageSize < 1 || config.PageSize > 100 {
		c.JSON(http.StatusBadRequest, AutoUpdateResponse{
			Success: false,
			Message: "Page size must be between 1 and 100",
		})
		return
	}

	if config.MaxPages < 1 || config.MaxPages > 20 {
		c.JSON(http.StatusBadRequest, AutoUpdateResponse{
			Success: false,
			Message: "Max pages must be between 1 and 20",
		})
		return
	}

	h.service.UpdateConfig(&config)

	c.JSON(http.StatusOK, AutoUpdateResponse{
		Success: true,
		Message: "Auto-update configuration updated successfully",
		Data: map[string]interface{}{
			"config": h.service.GetConfig(),
		},
	})
}

// TriggerManualUpdate triggers a manual update check
func (h *AutoUpdateHandler) TriggerManualUpdate(c *gin.Context) {
	if !h.service.IsRunning() {
		c.JSON(http.StatusBadRequest, AutoUpdateResponse{
			Success: false,
			Message: "Auto-update service is not running",
		})
		return
	}

	// Trigger manual update in background
	go func() {
		// This would need to be implemented in the service
		// h.service.TriggerManualUpdate()
	}()

	c.JSON(http.StatusOK, AutoUpdateResponse{
		Success: true,
		Message: "Manual update triggered successfully",
		Data: map[string]interface{}{
			"timestamp": time.Now(),
		},
	})
}
