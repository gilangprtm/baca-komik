package handlers

import (
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"baca-komik-api/database"
	"baca-komik-api/services"
	"baca-komik-api/utils"
)

type ComicHandler struct {
	comicService *services.ComicService
}

func NewComicHandler(db *database.DB) *ComicHandler {
	return &ComicHandler{
		comicService: services.NewComicService(db),
	}
}

// GetComics handles GET /api/comics
func (h *ComicHandler) GetComics(c *gin.Context) {
	// Parse query parameters
	pageStr := c.DefaultQuery("page", "1")
	limitStr := c.DefaultQuery("limit", "10")
	search := c.Query("search")
	genre := c.Query("genre")
	country := c.Query("country")
	sort := c.DefaultQuery("sort", "rank")
	order := c.DefaultQuery("order", "desc")

	// Convert page and limit to integers
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

	// Get comics from service
	comics, total, err := h.comicService.GetComics(page, limit, search, genre, country, sort, order)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Failed to retrieve comics")
		return
	}

	// Return response with pagination meta
	utils.SuccessResponseWithMeta(c, comics, page, limit, total)
}

// GetHomeComics - EXACT COPY from Next.js /api/comics/home/route.ts
func (h *ComicHandler) GetHomeComics(c *gin.Context) {
	// Parse query parameters - EXACTLY like Next.js lines 10-15
	pageStr := c.DefaultQuery("page", "1")
	limitStr := c.DefaultQuery("limit", "10")
	sort := c.DefaultQuery("sort", "")
	order := c.DefaultQuery("order", "desc")

	// Convert page and limit to integers
	page, err := strconv.Atoi(pageStr)
	if err != nil || page < 1 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid page parameter"})
		return
	}

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 1 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid limit parameter"})
		return
	}

	// Validate and normalize parameters
	page, limit, _ = utils.CalculatePagination(page, limit)

	// Get home comics from service
	comics, total, err := h.comicService.GetHomeComics(page, limit, sort, order)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve home comics"})
		return
	}

	// Return response - EXACTLY like Next.js lines 146-154
	c.JSON(http.StatusOK, gin.H{
		"data": comics,
		"meta": gin.H{
			"currentPage":   page,
			"totalPages":    (total + limit - 1) / limit,
			"totalItems":    total,
			"itemsPerPage":  limit,
		},
	})
}

// GetPopularComics handles GET /api/comics/popular
func (h *ComicHandler) GetPopularComics(c *gin.Context) {
	// Parse query parameters
	typeParam := c.DefaultQuery("type", "all_time")
	limitStr := c.DefaultQuery("limit", "20")

	// Convert limit to integer
	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 1 {
		utils.BadRequestResponse(c, "Invalid limit parameter")
		return
	}

	// Validate limit
	if limit > 100 {
		limit = 100
	}

	// Get popular comics from service
	comics, total, err := h.comicService.GetPopularComics(typeParam, limit)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Failed to retrieve popular comics")
		return
	}

	// Return response with meta (no pagination for popular)
	c.JSON(http.StatusOK, gin.H{
		"data": comics,
		"meta": gin.H{
			"type":  typeParam,
			"limit": limit,
			"total": total,
		},
	})
}

// GetRecommendedComics handles GET /api/comics/recommended
func (h *ComicHandler) GetRecommendedComics(c *gin.Context) {
	// Parse query parameters
	limitStr := c.DefaultQuery("limit", "20")

	// Convert limit to integer
	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 1 {
		utils.BadRequestResponse(c, "Invalid limit parameter")
		return
	}

	// Validate limit
	if limit > 100 {
		limit = 100
	}

	// Get recommended comics from service
	comics, total, err := h.comicService.GetRecommendedComics(limit)
	if err != nil {
		utils.InternalServerErrorResponse(c, "Failed to retrieve recommended comics")
		return
	}

	// Return response with meta (no pagination for recommended)
	c.JSON(http.StatusOK, gin.H{
		"data": comics,
		"meta": gin.H{
			"limit": limit,
			"total": total,
		},
	})
}

// GetComicDetails - EXACT COPY from Next.js /api/comics/[id]/route.ts
func (h *ComicHandler) GetComicDetails(c *gin.Context) {
	id := c.Param("id")

	// Validate ID - EXACTLY like Next.js
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid comic ID"})
		return
	}

	// Get comic details from service
	comic, err := h.comicService.GetComicDetails(id)
	if err != nil {
		if err.Error() == "comic not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Comic not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "An unexpected error occurred"})
		}
		return
	}

	// Return comic details directly - EXACTLY like Next.js (no wrapper)
	c.JSON(http.StatusOK, comic)
}

// GetCompleteComicDetails - EXACT COPY from Next.js /api/comics/[id]/complete handler
func (h *ComicHandler) GetCompleteComicDetails(c *gin.Context) {
	id := c.Param("id")

	// Validate ID - EXACTLY like Next.js lines 20-23
	if id == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid comic ID"})
		return
	}

	// Get user ID from context (optional auth) - EXACTLY like Next.js lines 25-28
	userID, _ := c.Get("user_id")
	var userIDStr *string
	if userID != nil {
		if uid, ok := userID.(string); ok {
			userIDStr = &uid
		}
	}

	// Get complete comic details from service
	comic, err := h.comicService.GetCompleteComicDetails(id, userIDStr)
	if err != nil {
		if err.Error() == "comic not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": "Comic not found"})
		} else {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "An unexpected error occurred"})
		}
		return
	}

	// Return response - EXACTLY like Next.js lines 124-127
	c.JSON(http.StatusOK, comic)
}

// GetComicChapters handles GET /api/comics/:id/chapters
func (h *ComicHandler) GetComicChapters(c *gin.Context) {
	id := c.Param("id")
	if id == "" {
		utils.BadRequestResponse(c, "Comic ID is required")
		return
	}

	// Parse query parameters
	pageStr := c.DefaultQuery("page", "1")
	limitStr := c.DefaultQuery("limit", "20")
	sort := c.DefaultQuery("sort", "chapter_number")
	order := c.DefaultQuery("order", "desc")

	// Convert page and limit to integers
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

	// Get comic chapters from service
	response, total, err := h.comicService.GetComicChapters(id, page, limit, sort, order)
	if err != nil {
		utils.NotFoundResponse(c, "Comic not found")
		return
	}

	// Return chapters with pagination meta
	c.JSON(http.StatusOK, gin.H{
		"comic": response.Comic,
		"data":  response.Data,
		"meta": gin.H{
			"page":        page,
			"limit":       limit,
			"total":       total,
			"total_pages": (total + limit - 1) / limit,
			"has_more":    page < (total+limit-1)/limit,
		},
	})
}
