package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"baca-komik-api/database"
	"baca-komik-api/models"
	"baca-komik-api/services"
	"baca-komik-api/utils"
)

type BookmarkHandler struct {
	bookmarkService *services.BookmarkService
}

func NewBookmarkHandler(db *database.DB) *BookmarkHandler {
	return &BookmarkHandler{
		bookmarkService: services.NewBookmarkService(db),
	}
}

// GetUserBookmarks handles GET /api/bookmarks
func (h *BookmarkHandler) GetUserBookmarks(c *gin.Context) {
	// Get user ID from context
	userID, exists := c.Get("user_id")
	if !exists {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	userIDStr, ok := userID.(string)
	if !ok {
		utils.UnauthorizedResponse(c, "Invalid user ID")
		return
	}

	// Parse query parameters
	pageStr := c.DefaultQuery("page", "1")
	limitStr := c.DefaultQuery("limit", "10")

	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		utils.BadRequestResponse(c, "Invalid page parameter")
		return
	}

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 1 {
		utils.BadRequestResponse(c, "Invalid limit parameter")
		return
	}

	// Validate and normalize parameters
	page, limit, _ = utils.CalculatePagination(page, limit)

	// Get bookmarks from service
	bookmarks, total, err := h.bookmarkService.GetUserBookmarks(userIDStr, page, limit)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Failed to retrieve bookmarks")
		return
	}

	// Return response with pagination meta
	utils.SuccessResponseWithMeta(c, bookmarks, page, limit, total)
}

// GetDetailedBookmarks handles GET /api/bookmarks/details
func (h *BookmarkHandler) GetDetailedBookmarks(c *gin.Context) {
	// Get user ID from context
	userID, exists := c.Get("user_id")
	if !exists {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	userIDStr, ok := userID.(string)
	if !ok {
		utils.UnauthorizedResponse(c, "Invalid user ID")
		return
	}

	// Parse query parameters
	pageStr := c.DefaultQuery("page", "1")
	limitStr := c.DefaultQuery("limit", "10")

	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		utils.BadRequestResponse(c, "Invalid page parameter")
		return
	}

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 1 {
		utils.BadRequestResponse(c, "Invalid limit parameter")
		return
	}

	// Validate and normalize parameters
	page, limit, _ = utils.CalculatePagination(page, limit)

	// Get detailed bookmarks from service
	bookmarks, total, err := h.bookmarkService.GetDetailedBookmarks(userIDStr, page, limit)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Failed to retrieve detailed bookmarks")
		return
	}

	// Return response with pagination meta
	utils.SuccessResponseWithMeta(c, bookmarks, page, limit, total)
}

// AddBookmark handles POST /api/bookmarks
func (h *BookmarkHandler) AddBookmark(c *gin.Context) {
	// Get user ID from context
	userID, exists := c.Get("user_id")
	if !exists {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	userIDStr, ok := userID.(string)
	if !ok {
		utils.UnauthorizedResponse(c, "Invalid user ID")
		return
	}

	// Parse request body
	var request models.CreateBookmarkRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		utils.BadRequestResponse(c, "Invalid request body")
		return
	}

	// Validate request
	if request.IDKomik == "" {
		utils.BadRequestResponse(c, "Comic ID is required")
		return
	}

	// Add bookmark
	bookmark, err := h.bookmarkService.AddBookmark(userIDStr, request.IDKomik)
	if err != nil {
		if err.Error() == "comic not found" {
			utils.NotFoundResponse(c, "Comic not found")
			return
		}
		if err.Error() == "bookmark already exists" {
			utils.BadRequestResponse(c, "Bookmark already exists")
			return
		}
		utils.InternalServerErrorResponse(c, "Failed to add bookmark")
		return
	}

	// Return created bookmark
	utils.CreatedResponse(c, bookmark)
}

// RemoveBookmark handles DELETE /api/bookmarks/:id
func (h *BookmarkHandler) RemoveBookmark(c *gin.Context) {
	// Get user ID from context
	userID, exists := c.Get("user_id")
	if !exists {
		utils.UnauthorizedResponse(c, "User not authenticated")
		return
	}

	userIDStr, ok := userID.(string)
	if !ok {
		utils.UnauthorizedResponse(c, "Invalid user ID")
		return
	}

	// Get comic ID from path parameter
	comicID := c.Param("id")
	if comicID == "" {
		utils.BadRequestResponse(c, "Comic ID is required")
		return
	}

	// Remove bookmark
	err := h.bookmarkService.RemoveBookmark(userIDStr, comicID)
	if err != nil {
		if err.Error() == "bookmark not found" {
			utils.NotFoundResponse(c, "Bookmark not found")
			return
		}
		utils.InternalServerErrorResponse(c, "Failed to remove bookmark")
		return
	}

	// Return success response
	c.JSON(http.StatusOK, models.SuccessResponse{Success: true})
}
