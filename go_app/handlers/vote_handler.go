package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"baca-komik-api/database"
	"baca-komik-api/models"
	"baca-komik-api/services"
	"baca-komik-api/utils"
)

type VoteHandler struct {
	voteService *services.VoteService
}

func NewVoteHandler(db *database.DB) *VoteHandler {
	return &VoteHandler{
		voteService: services.NewVoteService(db),
	}
}

// AddVote handles POST /api/votes
func (h *VoteHandler) AddVote(c *gin.Context) {
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
	var request models.CreateVoteRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		utils.BadRequestResponse(c, "Invalid request body")
		return
	}

	// Validate request
	if (request.IDKomik == nil && request.IDChapter == nil) ||
		(request.IDKomik != nil && request.IDChapter != nil) {
		utils.BadRequestResponse(c, "Provide either comic_id or chapter_id, not both")
		return
	}

	// Add vote
	vote, err := h.voteService.AddVote(userIDStr, &request)
	if err != nil {
		switch err.Error() {
		case "comic not found":
			utils.NotFoundResponse(c, "Comic not found")
			return
		case "chapter not found":
			utils.NotFoundResponse(c, "Chapter not found")
			return
		case "vote already exists":
			utils.BadRequestResponse(c, "Vote already exists")
			return
		case "provide either comic_id or chapter_id, not both":
			utils.BadRequestResponse(c, "Provide either comic_id or chapter_id, not both")
			return
		default:
			utils.InternalServerErrorResponse(c, "Failed to add vote")
			return
		}
	}

	// Return created vote
	utils.CreatedResponse(c, vote)
}

// RemoveVote handles DELETE /api/votes/:id
func (h *VoteHandler) RemoveVote(c *gin.Context) {
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

	// Get target ID from path parameter
	targetID := c.Param("id")
	if targetID == "" {
		utils.BadRequestResponse(c, "Target ID is required")
		return
	}

	// Get vote type from query parameter
	voteType := c.Query("type")
	if voteType == "" {
		voteType = "comic" // default to comic for backward compatibility
	}

	// Validate vote type
	if voteType != "comic" && voteType != "chapter" {
		utils.BadRequestResponse(c, "Invalid type. Must be 'comic' or 'chapter'")
		return
	}

	// Remove vote
	err := h.voteService.RemoveVote(userIDStr, targetID, voteType)
	if err != nil {
		switch err.Error() {
		case "vote not found":
			utils.NotFoundResponse(c, "Vote not found")
			return
		case "invalid vote type, must be 'comic' or 'chapter'":
			utils.BadRequestResponse(c, "Invalid vote type. Must be 'comic' or 'chapter'")
			return
		default:
			utils.InternalServerErrorResponse(c, "Failed to remove vote")
			return
		}
	}

	// Return success response
	c.JSON(http.StatusOK, models.SuccessResponse{Success: true})
}
