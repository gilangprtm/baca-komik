package handlers

import (
	"fmt"
	"net/http"
	"time"

	"baca-komik-api/internal/crawler"
	"github.com/gin-gonic/gin"
)

type CrawlerHandler struct {
	crawler *crawler.Crawler
}

func NewCrawlerHandler(c *crawler.Crawler) *CrawlerHandler {
	return &CrawlerHandler{crawler: c}
}

type CrawlRequest struct {
	Mode      string `json:"mode" binding:"required"`
	StartPage int    `json:"start_page,omitempty"`
	EndPage   int    `json:"end_page,omitempty"`
	BatchSize int    `json:"batch_size,omitempty"`
	MangaID   string `json:"manga_id,omitempty"`
	DryRun    bool   `json:"dry_run,omitempty"`
}

type CrawlResponse struct {
	Success   bool        `json:"success"`
	Message   string      `json:"message"`
	StartTime time.Time   `json:"start_time"`
	JobID     string      `json:"job_id,omitempty"`
	Data      interface{} `json:"data,omitempty"`
}

// StartCrawling starts a crawling job
func (h *CrawlerHandler) StartCrawling(c *gin.Context) {
	var req CrawlRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, CrawlResponse{
			Success: false,
			Message: fmt.Sprintf("Invalid request: %v", err),
		})
		return
	}

	// Set defaults
	if req.BatchSize == 0 {
		req.BatchSize = 10
	}
	if req.EndPage == 0 {
		req.EndPage = 10
	}

	jobID := fmt.Sprintf("crawl_%s_%d", req.Mode, time.Now().Unix())
	
	// Start crawling immediately (not in goroutine for Railway compatibility)
	var err error
	switch req.Mode {
	case "genres":
		err = h.crawler.CrawlGenres()
	case "formats":
		err = h.crawler.CrawlFormats()
	case "types":
		err = h.crawler.CrawlTypes()
	case "authors":
		err = h.crawler.CrawlAuthors()
	case "artists":
		err = h.crawler.CrawlArtists()
	case "manga":
		err = h.crawler.CrawlManga(req.StartPage, req.EndPage)
	case "chapters":
		if req.MangaID == "all" || req.MangaID == "" {
			// Auto-crawl chapters for all manga in database
			err = h.crawler.CrawlAllChapters()
		} else {
			// Crawl chapters for specific manga ID
			err = h.crawler.CrawlChaptersForManga(req.MangaID)
		}
	case "pages":
		err = h.crawler.CrawlAllPages()
	case "all":
		err = h.crawler.CrawlAll()
	case "auto":
		err = h.crawler.CrawlAllMasterData()
	default:
		c.JSON(http.StatusBadRequest, CrawlResponse{
			Success: false,
			Message: fmt.Sprintf("Unknown mode: %s", req.Mode),
		})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, CrawlResponse{
			Success: false,
			Message: fmt.Sprintf("Crawling failed: %v", err),
		})
		return
	}

	c.JSON(http.StatusOK, CrawlResponse{
		Success:   true,
		Message:   fmt.Sprintf("Crawling completed successfully: %s", req.Mode),
		StartTime: time.Now(),
		JobID:     jobID,
	})
}

// GetCrawlStatus returns current crawling status
func (h *CrawlerHandler) GetCrawlStatus(c *gin.Context) {
	checkpoint, err := h.crawler.LoadCheckpoint()
	if err != nil {
		c.JSON(http.StatusInternalServerError, CrawlResponse{
			Success: false,
			Message: fmt.Sprintf("Failed to load checkpoint: %v", err),
		})
		return
	}

	if checkpoint == nil {
		c.JSON(http.StatusOK, CrawlResponse{
			Success: true,
			Message: "No active crawling session",
			Data:    nil,
		})
		return
	}

	// Calculate progress percentage
	progress := float64(0)
	if checkpoint.EstimatedTotal > 0 {
		progress = float64(checkpoint.TotalProcessed) / float64(checkpoint.EstimatedTotal) * 100
	}

	elapsed := time.Since(checkpoint.StartTime)
	var eta string
	if checkpoint.TotalProcessed > 0 && checkpoint.EstimatedTotal > 0 {
		rate := float64(checkpoint.TotalProcessed) / elapsed.Seconds()
		remaining := checkpoint.EstimatedTotal - checkpoint.TotalProcessed
		etaSeconds := float64(remaining) / rate
		eta = time.Duration(etaSeconds * float64(time.Second)).Round(time.Minute).String()
	}

	statusData := map[string]interface{}{
		"phase":            checkpoint.Phase,
		"current_page":     checkpoint.CurrentPage,
		"total_processed":  checkpoint.TotalProcessed,
		"estimated_total":  checkpoint.EstimatedTotal,
		"progress_percent": progress,
		"elapsed_time":     elapsed.Round(time.Second).String(),
		"eta":              eta,
		"success_count":    checkpoint.SuccessCount,
		"error_count":      checkpoint.ErrorCount,
		"last_update":      checkpoint.LastUpdateTime,
	}

	c.JSON(http.StatusOK, CrawlResponse{
		Success: true,
		Message: "Crawling status retrieved",
		Data:    statusData,
	})
}

// StopCrawling stops current crawling (clears checkpoint)
func (h *CrawlerHandler) StopCrawling(c *gin.Context) {
	if err := h.crawler.ClearCheckpoint(); err != nil {
		c.JSON(http.StatusInternalServerError, CrawlResponse{
			Success: false,
			Message: fmt.Sprintf("Failed to stop crawling: %v", err),
		})
		return
	}

	c.JSON(http.StatusOK, CrawlResponse{
		Success: true,
		Message: "Crawling stopped and checkpoint cleared",
	})
}

// ResumeCrawling resumes from last checkpoint
func (h *CrawlerHandler) ResumeCrawling(c *gin.Context) {
	checkpoint, err := h.crawler.LoadCheckpoint()
	if err != nil {
		c.JSON(http.StatusInternalServerError, CrawlResponse{
			Success: false,
			Message: fmt.Sprintf("Failed to load checkpoint: %v", err),
		})
		return
	}

	if checkpoint == nil {
		c.JSON(http.StatusBadRequest, CrawlResponse{
			Success: false,
			Message: "No checkpoint found to resume from",
		})
		return
	}

	// Start resume in background
	go func() {
		// TODO: Implement resume logic based on checkpoint.Phase
		// For now, just continue from where it left off
		switch checkpoint.Phase {
		case "manga":
			h.crawler.CrawlManga(checkpoint.CurrentPage, -1)
		case "chapters":
			h.crawler.CrawlAllChapters()
		case "pages":
			h.crawler.CrawlAllPages()
		}
	}()

	c.JSON(http.StatusOK, CrawlResponse{
		Success:   true,
		Message:   fmt.Sprintf("Resuming %s crawling from page %d", checkpoint.Phase, checkpoint.CurrentPage),
		StartTime: time.Now(),
		Data:      checkpoint,
	})
}

// GetCrawlHistory returns crawling statistics
func (h *CrawlerHandler) GetCrawlHistory(c *gin.Context) {
	// TODO: Implement crawl history from database
	c.JSON(http.StatusOK, CrawlResponse{
		Success: true,
		Message: "Crawl history feature coming soon",
		Data:    map[string]string{"status": "not_implemented"},
	})
}
