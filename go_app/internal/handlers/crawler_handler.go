package handlers

import (
	"fmt"
	"net/http"
	"sync"
	"time"

	"baca-komik-api/internal/crawler"
	"github.com/gin-gonic/gin"
)

type CrawlerHandler struct {
	crawler       *crawler.Crawler
	activeJobs    map[string]*CrawlJob
	jobsMutex     sync.RWMutex
}

type CrawlJob struct {
	ID        string    `json:"id"`
	Mode      string    `json:"mode"`
	Status    string    `json:"status"` // "running", "completed", "failed"
	StartTime time.Time `json:"start_time"`
	EndTime   *time.Time `json:"end_time,omitempty"`
	Progress  *CrawlProgress `json:"progress,omitempty"`
	Error     string    `json:"error,omitempty"`
}

type CrawlProgress struct {
	CurrentStep   string `json:"current_step"`
	TotalSteps    int    `json:"total_steps"`
	CompletedSteps int   `json:"completed_steps"`
	Percentage    float64 `json:"percentage"`
}

func NewCrawlerHandler(c *crawler.Crawler) *CrawlerHandler {
	return &CrawlerHandler{
		crawler:    c,
		activeJobs: make(map[string]*CrawlJob),
	}
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

	// Create job entry
	job := &CrawlJob{
		ID:        jobID,
		Mode:      req.Mode,
		Status:    "running",
		StartTime: time.Now(),
		Progress: &CrawlProgress{
			CurrentStep: "Starting...",
			TotalSteps:  1,
			CompletedSteps: 0,
			Percentage: 0,
		},
	}

	// Store job in active jobs
	h.jobsMutex.Lock()
	h.activeJobs[jobID] = job
	h.jobsMutex.Unlock()

	// Start crawling in background goroutine
	go func() {
		var err error

		// Update job status
		h.updateJobProgress(jobID, "Running crawling...", 0, 1)

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
			err = fmt.Errorf("unknown mode: %s", req.Mode)
		}

		// Update job completion
		h.completeJob(jobID, err)
	}()

	c.JSON(http.StatusOK, CrawlResponse{
		Success:   true,
		Message:   fmt.Sprintf("Crawling job started in background: %s", req.Mode),
		StartTime: time.Now(),
		JobID:     jobID,
		Data:      map[string]string{"job_id": jobID, "status": "running"},
	})
}

// GetCrawlStatus returns current crawling status
func (h *CrawlerHandler) GetCrawlStatus(c *gin.Context) {
	// Check for active background jobs first
	activeJob := h.getActiveJob()
	if activeJob != nil {
		elapsed := time.Since(activeJob.StartTime)

		statusData := map[string]interface{}{
			"job_id":           activeJob.ID,
			"mode":             activeJob.Mode,
			"status":           activeJob.Status,
			"current_step":     activeJob.Progress.CurrentStep,
			"progress_percent": activeJob.Progress.Percentage,
			"elapsed_time":     elapsed.Round(time.Second).String(),
			"start_time":       activeJob.StartTime,
		}

		c.JSON(http.StatusOK, CrawlResponse{
			Success: true,
			Message: "Active crawling job found",
			Data:    statusData,
		})
		return
	}

	// Fallback to checkpoint system
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
	h.jobsMutex.RLock()
	jobs := make([]*CrawlJob, 0, len(h.activeJobs))
	for _, job := range h.activeJobs {
		jobs = append(jobs, job)
	}
	h.jobsMutex.RUnlock()

	c.JSON(http.StatusOK, CrawlResponse{
		Success: true,
		Message: "Crawl history retrieved",
		Data:    map[string]interface{}{"jobs": jobs, "total": len(jobs)},
	})
}

// Helper functions for job management
func (h *CrawlerHandler) updateJobProgress(jobID, step string, completed, total int) {
	h.jobsMutex.Lock()
	defer h.jobsMutex.Unlock()

	if job, exists := h.activeJobs[jobID]; exists {
		job.Progress.CurrentStep = step
		job.Progress.CompletedSteps = completed
		job.Progress.TotalSteps = total
		if total > 0 {
			job.Progress.Percentage = float64(completed) / float64(total) * 100
		}
	}
}

func (h *CrawlerHandler) completeJob(jobID string, err error) {
	h.jobsMutex.Lock()
	defer h.jobsMutex.Unlock()

	if job, exists := h.activeJobs[jobID]; exists {
		now := time.Now()
		job.EndTime = &now

		if err != nil {
			job.Status = "failed"
			job.Error = err.Error()
		} else {
			job.Status = "completed"
			job.Progress.Percentage = 100
			job.Progress.CurrentStep = "Completed"
		}
	}
}

func (h *CrawlerHandler) getActiveJob() *CrawlJob {
	h.jobsMutex.RLock()
	defer h.jobsMutex.RUnlock()

	for _, job := range h.activeJobs {
		if job.Status == "running" {
			return job
		}
	}
	return nil
}

// GetJobStatus returns status of specific job
func (h *CrawlerHandler) GetJobStatus(c *gin.Context) {
	jobID := c.Param("id")

	h.jobsMutex.RLock()
	job, exists := h.activeJobs[jobID]
	h.jobsMutex.RUnlock()

	if !exists {
		c.JSON(http.StatusNotFound, CrawlResponse{
			Success: false,
			Message: fmt.Sprintf("Job not found: %s", jobID),
		})
		return
	}

	var elapsed time.Duration
	if job.EndTime != nil {
		elapsed = job.EndTime.Sub(job.StartTime)
	} else {
		elapsed = time.Since(job.StartTime)
	}

	statusData := map[string]interface{}{
		"job_id":           job.ID,
		"mode":             job.Mode,
		"status":           job.Status,
		"current_step":     job.Progress.CurrentStep,
		"progress_percent": job.Progress.Percentage,
		"elapsed_time":     elapsed.Round(time.Second).String(),
		"start_time":       job.StartTime,
		"end_time":         job.EndTime,
		"error":            job.Error,
	}

	c.JSON(http.StatusOK, CrawlResponse{
		Success: true,
		Message: "Job status retrieved",
		Data:    statusData,
	})
}
