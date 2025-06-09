package routes

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"baca-komik-api/config"
	"baca-komik-api/database"
	"baca-komik-api/handlers"
	"baca-komik-api/internal/crawler"
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
	var setupHandler *handlers.SetupHandler
	var crawlerHandler *handlers.CrawlerHandler

	if db != nil {
		comicHandler = handlers.NewComicHandler(db)
		chapterHandler = handlers.NewChapterHandler(db)
		bookmarkHandler = handlers.NewBookmarkHandler(db)
		voteHandler = handlers.NewVoteHandler(db)
		commentHandler = handlers.NewCommentHandler(db)
		setupHandler = handlers.NewSetupHandler(db)

		// Initialize crawler
		crawlerConfig := &crawler.Config{
			BaseURL:   "https://api.shngm.io/v1",
			BatchSize: 10,
			DryRun:    false,
			Verbose:   true,
			Headers: map[string]string{
				"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36",
				"Origin":     "https://app.shinigami.asia",
				"Referer":    "https://app.shinigami.asia/",
				"Sec-Fetch-Mode": "cors",
				"Sec-Fetch-Site": "cross-site",
			},
		}
		crawlerInstance := crawler.New(db, crawlerConfig)
		crawlerHandler = handlers.NewCrawlerHandler(crawlerInstance)
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
			// Bookmarks routes - exactly like Next.js
			bookmarks := protected.Group("/bookmarks")
			{
				bookmarks.GET("", bookmarkHandler.GetUserBookmarks)
				bookmarks.GET("/details", bookmarkHandler.GetDetailedBookmarks)
				bookmarks.POST("", bookmarkHandler.AddBookmark)
				bookmarks.DELETE("/:id", bookmarkHandler.RemoveBookmark) // id = comic_id like Next.js
			}

			// Votes routes - exactly like Next.js
			votes := protected.Group("/votes")
			{
				votes.POST("", voteHandler.AddVote)
				votes.DELETE("/:id", voteHandler.RemoveVote) // id = comic_id/chapter_id + ?type=comic like Next.js
			}

			// Comments routes (POST requires auth, GET is public)
			comments := protected.Group("/comments")
			{
				comments.POST("", commentHandler.AddComment)
			}
		}

		// Public comments route (no auth required for reading)
		v1.GET("/comments/:id", commentHandler.GetComments)

		// Setup route - EXACTLY like Next.js /api/setup
		if setupHandler != nil {
			v1.GET("/setup", setupHandler.CreateAdminUser)
		}

		// Crawler routes (admin only)
		if crawlerHandler != nil {
			crawler := v1.Group("/crawler")
			{
				crawler.POST("/start", crawlerHandler.StartCrawling)
				crawler.GET("/status", crawlerHandler.GetCrawlStatus)
				crawler.POST("/stop", crawlerHandler.StopCrawling)
				crawler.POST("/resume", crawlerHandler.ResumeCrawling)
				crawler.GET("/history", crawlerHandler.GetCrawlHistory)
			}
		}
	}
}
