package handlers

import (
	"strconv"

	"github.com/gin-gonic/gin"
	"baca-komik-api/database"
	"baca-komik-api/models"
	"baca-komik-api/services"
	"baca-komik-api/utils"
)

type CommentHandler struct {
	commentService *services.CommentService
}

func NewCommentHandler(db *database.DB) *CommentHandler {
	return &CommentHandler{
		commentService: services.NewCommentService(db),
	}
}

// GetComments handles GET /api/comments/:id
func (h *CommentHandler) GetComments(c *gin.Context) {
	// Get target ID from path parameter
	targetID := c.Param("id")
	if targetID == "" {
		utils.BadRequestResponse(c, "Target ID is required")
		return
	}

	// Parse query parameters
	commentType := c.DefaultQuery("type", "comic")
	pageStr := c.DefaultQuery("page", "1")
	limitStr := c.DefaultQuery("limit", "10")
	parentOnlyStr := c.DefaultQuery("parent_only", "false")

	// Validate comment type
	if commentType != "comic" && commentType != "chapter" {
		utils.BadRequestResponse(c, "Invalid type. Must be 'comic' or 'chapter'")
		return
	}

	// Parse page and limit
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

	// Parse parent_only
	parentOnly, err := strconv.ParseBool(parentOnlyStr)
	if err != nil {
		parentOnly = false
	}

	// Validate and normalize parameters
	page, limit, _ = utils.CalculatePagination(page, limit)

	// Get comments from service
	comments, total, err := h.commentService.GetComments(targetID, commentType, page, limit, parentOnly)
	if err != nil {
		if err.Error() == "invalid type, must be 'comic' or 'chapter'" {
			utils.BadRequestResponse(c, "Invalid type. Must be 'comic' or 'chapter'")
			return
		}
		utils.InternalServerErrorResponse(c, "Failed to retrieve comments")
		return
	}

	// Return response with pagination meta
	utils.SuccessResponseWithMeta(c, comments, page, limit, total)
}

// AddComment handles POST /api/comments
func (h *CommentHandler) AddComment(c *gin.Context) {
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
	var request models.CreateCommentRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		utils.BadRequestResponse(c, "Invalid request body")
		return
	}

	// Validate request
	if request.Content == "" {
		utils.BadRequestResponse(c, "Content is required")
		return
	}

	if (request.IDKomik == nil && request.IDChapter == nil) ||
		(request.IDKomik != nil && request.IDChapter != nil) {
		utils.BadRequestResponse(c, "Provide either comic_id or chapter_id, not both")
		return
	}

	// Add comment
	comment, err := h.commentService.AddComment(userIDStr, &request)
	if err != nil {
		switch err.Error() {
		case "comic not found":
			utils.NotFoundResponse(c, "Comic not found")
			return
		case "chapter not found":
			utils.NotFoundResponse(c, "Chapter not found")
			return
		case "parent comment not found":
			utils.NotFoundResponse(c, "Parent comment not found")
			return
		case "parent comment is not for the same comic":
			utils.BadRequestResponse(c, "Parent comment is not for the same comic")
			return
		case "parent comment is not for the same chapter":
			utils.BadRequestResponse(c, "Parent comment is not for the same chapter")
			return
		case "provide either comic_id or chapter_id, not both":
			utils.BadRequestResponse(c, "Provide either comic_id or chapter_id, not both")
			return
		default:
			utils.InternalServerErrorResponse(c, "Failed to add comment")
			return
		}
	}

	// Return created comment
	utils.CreatedResponse(c, comment)
}
