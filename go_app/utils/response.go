package utils

import (
	"math"
	"net/http"

	"github.com/gin-gonic/gin"
)

// Standard response structures to match Next.js API format

type Response struct {
	Data interface{} `json:"data,omitempty"`
	Meta *Meta       `json:"meta,omitempty"`
}

type Meta struct {
	Page       int  `json:"page"`
	Limit      int  `json:"limit"`
	Total      int  `json:"total"`
	TotalPages int  `json:"total_pages"`
	HasMore    bool `json:"has_more"`
}

type ErrorResponseStruct struct {
	Error string `json:"error"`
}

// SuccessResponse sends a success response with data
func SuccessResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, Response{Data: data})
}

// SuccessResponseWithMeta sends a success response with data and pagination meta
func SuccessResponseWithMeta(c *gin.Context, data interface{}, page, limit, total int) {
	totalPages := int(math.Ceil(float64(total) / float64(limit)))
	hasMore := page < totalPages

	meta := &Meta{
		Page:       page,
		Limit:      limit,
		Total:      total,
		TotalPages: totalPages,
		HasMore:    hasMore,
	}

	c.JSON(http.StatusOK, Response{
		Data: data,
		Meta: meta,
	})
}

// CreatedResponse sends a 201 Created response
func CreatedResponse(c *gin.Context, data interface{}) {
	c.JSON(http.StatusCreated, data)
}

// ErrorResponse sends an error response
func ErrorResponse(c *gin.Context, statusCode int, message string) {
	c.JSON(statusCode, ErrorResponseStruct{Error: message})
}

// BadRequestResponse sends a 400 Bad Request response
func BadRequestResponse(c *gin.Context, message string) {
	ErrorResponse(c, http.StatusBadRequest, message)
}

// UnauthorizedResponse sends a 401 Unauthorized response
func UnauthorizedResponse(c *gin.Context, message string) {
	ErrorResponse(c, http.StatusUnauthorized, message)
}

// NotFoundResponse sends a 404 Not Found response
func NotFoundResponse(c *gin.Context, message string) {
	ErrorResponse(c, http.StatusNotFound, message)
}

// InternalServerErrorResponse sends a 500 Internal Server Error response
func InternalServerErrorResponse(c *gin.Context, message string) {
	ErrorResponse(c, http.StatusInternalServerError, message)
}

// CalculatePagination calculates offset and validates pagination parameters
func CalculatePagination(page, limit int) (int, int, int) {
	// Set defaults
	if page < 1 {
		page = 1
	}
	if limit < 1 {
		limit = 10
	}
	if limit > 100 {
		limit = 100 // Max limit to prevent abuse
	}

	offset := (page - 1) * limit
	return page, limit, offset
}
