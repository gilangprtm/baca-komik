package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"baca-komik-api/database"
	"baca-komik-api/services"
	"baca-komik-api/utils"
)

type ChapterHandler struct {
	chapterService *services.ChapterService
}

func NewChapterHandler(db *database.DB) *ChapterHandler {
	return &ChapterHandler{
		chapterService: services.NewChapterService(db),
	}
}

// GetChapterDetails handles GET /api/chapters/:id
func (h *ChapterHandler) GetChapterDetails(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.BadRequestResponse(c, "Chapter ID is required")
		return
	}

	// Get chapter details from service
	chapter, err := h.chapterService.GetChapterDetails(id)
	if err != nil {
		utils.NotFoundResponse(c, "Chapter not found")
		return
	}

	// Return chapter details
	utils.SuccessResponse(c, chapter)
}

// GetCompleteChapterDetails handles GET /api/chapters/:id/complete
func (h *ChapterHandler) GetCompleteChapterDetails(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.BadRequestResponse(c, "Chapter ID is required")
		return
	}

	// Get user ID from context (optional auth)
	userID, _ := c.Get("user_id")
	var userIDStr *string
	if userID != nil {
		if uid, ok := userID.(string); ok {
			userIDStr = &uid
		}
	}

	// Get complete chapter details from service
	chapter, err := h.chapterService.GetCompleteChapterDetails(id, userIDStr)
	if err != nil {
		utils.NotFoundResponse(c, "Chapter not found")
		return
	}

	// Return complete chapter details
	c.JSON(http.StatusOK, chapter)
}

// GetChapterPages handles GET /api/chapters/:id/pages
func (h *ChapterHandler) GetChapterPages(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.BadRequestResponse(c, "Chapter ID is required")
		return
	}

	// Get chapter pages from service
	pages, err := h.chapterService.GetChapterPages(id)
	if err != nil {
		utils.NotFoundResponse(c, "Chapter not found")
		return
	}

	// Return chapter pages
	utils.SuccessResponse(c, pages)
}

// GetAdjacentChapters handles GET /api/chapters/:id/adjacent
func (h *ChapterHandler) GetAdjacentChapters(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.BadRequestResponse(c, "Chapter ID is required")
		return
	}

	// Parse limit parameter
	limitStr := c.DefaultQuery("limit", "5")
	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 1 {
		utils.BadRequestResponse(c, "Invalid limit parameter")
		return
	}

	// Validate limit
	if limit > 20 {
		limit = 20
	}

	// Get adjacent chapters from service
	response, err := h.chapterService.GetAdjacentChapters(id, limit)
	if err != nil {
		utils.NotFoundResponse(c, "Chapter not found")
		return
	}

	// Return adjacent chapters
	utils.SuccessResponse(c, response)
}
