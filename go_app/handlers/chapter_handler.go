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

// GetChapterDetails - EXACT COPY from Next.js /api/chapters/[id]/route.ts
func (h *ChapterHandler) GetChapterDetails(c *gin.Context) {
	id := c.Param("id")

	// Validate ID - EXACTLY like Next.js lines 14-20
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid chapter ID"})
		return
	}

	// Get chapter details from service
	chapter, err := h.chapterService.GetChapterDetails(id)
	if err != nil {
		if err.Error() == "chapter not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Chapter not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "An unexpected error occurred"})
		}
		return
	}

	// Return chapter details directly - EXACTLY like Next.js line 99 (no wrapper)
	c.JSON(http.StatusOK, chapter)
}

// GetCompleteChapterDetails - EXACT COPY from Next.js /api/chapters/[id]/complete handler
func (h *ChapterHandler) GetCompleteChapterDetails(c *gin.Context) {
	id := c.Param("id")

	// Validate ID - EXACTLY like Next.js lines 14-20
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid chapter ID"})
		return
	}

	// Get user ID from context (optional auth) - EXACTLY like Next.js lines 22-25
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
		if err.Error() == "chapter not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Chapter not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "An unexpected error occurred"})
		}
		return
	}

	// Return response - EXACTLY like Next.js lines 164-172
	c.JSON(http.StatusOK, chapter)
}

// GetChapterPages - EXACT COPY from Next.js /api/chapters/[id]/pages handler
func (h *ChapterHandler) GetChapterPages(c *gin.Context) {
	id := c.Param("id")

	// Validate ID - EXACTLY like Next.js lines 15-20
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid chapter ID"})
		return
	}

	// Get chapter pages from service
	pages, err := h.chapterService.GetChapterPages(id)
	if err != nil {
		if err.Error() == "chapter not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Chapter not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "An unexpected error occurred"})
		}
		return
	}

	// Return response directly - EXACTLY like Next.js lines 64-72
	c.JSON(http.StatusOK, pages)
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
