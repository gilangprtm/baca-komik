package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"baca-komik-api/config"
	"baca-komik-api/database"
	"baca-komik-api/handlers"
	"baca-komik-api/middleware"
)

func Setup(router *gin.Engine, db *database.DB, cfg *config.Config) {
	// Initialize handlers
	healthHandler := handlers.NewHealthHandler(db)

	// Initialize other handlers (they will handle nil database gracefully)
	var comicHandler *handlers.ComicHandler
	var chapterHandler *handlers.ChapterHandler
	var bookmarkHandler *handlers.BookmarkHandler
	var voteHandler *handlers.VoteHandler
	var commentHandler *handlers.CommentHandler

	if db != nil {
		comicHandler = handlers.NewComicHandler(db)
		chapterHandler = handlers.NewChapterHandler(db)
		bookmarkHandler = handlers.NewBookmarkHandler(db)
		voteHandler = handlers.NewVoteHandler(db)
		commentHandler = handlers.NewCommentHandler(db)
	}

	// Health check endpoint
	router.GET("/health", healthHandler.Health)
	if db != nil {
		router.GET("/test-db", healthHandler.TestDatabase)
	}
	router.GET("/", func(c *gin.Context) {
		status := "running"
		if db == nil {
			status = "running (development mode - no database)"
		}
		c.JSON(http.StatusOK, gin.H{
			"message": "BacaKomik API v1.0.0",
			"status":  status,
			"database": db != nil,
		})
	})

	// API v1 routes
	v1 := router.Group("/api")
	{
		// Comics routes
		comics := v1.Group("/comics")
		{
			// Public routes
			if comicHandler != nil {
				comics.GET("", comicHandler.GetComics)
				comics.GET("/home", comicHandler.GetHomeComics)
				comics.GET("/popular", comicHandler.GetPopularComics)
				comics.GET("/recommended", comicHandler.GetRecommendedComics)
				comics.GET("/:id", comicHandler.GetComicDetails)
				comics.GET("/:id/complete", middleware.OptionalAuth(cfg), comicHandler.GetCompleteComicDetails)
				comics.GET("/:id/chapters", comicHandler.GetComicChapters)
			} else {
				// Mock responses for development
				comics.GET("", func(c *gin.Context) {
					c.JSON(http.StatusOK, gin.H{"message": "Comics API - Database not connected"})
				})
				comics.GET("/home", func(c *gin.Context) {
					c.JSON(http.StatusOK, gin.H{"message": "Home Comics API - Database not connected"})
				})
				comics.GET("/popular", func(c *gin.Context) {
					c.JSON(http.StatusOK, gin.H{"message": "Popular Comics API - Database not connected"})
				})
				comics.GET("/recommended", func(c *gin.Context) {
					c.JSON(http.StatusOK, gin.H{"message": "Recommended Comics API - Database not connected"})
				})
			}
		}

		// Chapters routes
		chapters := v1.Group("/chapters")
		{
			chapters.GET("/:id", chapterHandler.GetChapterDetails)
			chapters.GET("/:id/complete", middleware.OptionalAuth(cfg), chapterHandler.GetCompleteChapterDetails)
			chapters.GET("/:id/pages", chapterHandler.GetChapterPages)
			chapters.GET("/:id/adjacent", chapterHandler.GetAdjacentChapters)
		}

		// Protected routes (require authentication)
		protected := v1.Group("")
		protected.Use(middleware.AuthRequired(cfg))
		{
			// Bookmarks routes
			bookmarks := protected.Group("/bookmarks")
			{
				bookmarks.GET("", bookmarkHandler.GetUserBookmarks)
				bookmarks.GET("/details", bookmarkHandler.GetDetailedBookmarks)
				bookmarks.POST("", bookmarkHandler.AddBookmark)
				bookmarks.DELETE("/:id", bookmarkHandler.RemoveBookmark)
			}

			// Votes routes
			votes := protected.Group("/votes")
			{
				votes.POST("", voteHandler.AddVote)
				votes.DELETE("/:id", voteHandler.RemoveVote)
			}

			// Comments routes (POST requires auth, GET is public)
			comments := protected.Group("/comments")
			{
				comments.POST("", commentHandler.AddComment)
			}
		}

		// Public comments route (no auth required for reading)
		v1.GET("/comments/:id", commentHandler.GetComments)
	}
}
