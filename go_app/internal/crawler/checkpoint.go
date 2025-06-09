package crawler

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"
)

// CrawlCheckpoint represents the current state of crawling
type CrawlCheckpoint struct {
	Phase           string    `json:"phase"`           // "manga", "chapters", "pages"
	CurrentPage     int       `json:"current_page"`    // Current page being processed
	TotalProcessed  int       `json:"total_processed"` // Total items processed so far
	LastMangaID     string    `json:"last_manga_id"`   // Last manga ID processed (for chapters)
	LastChapterID   string    `json:"last_chapter_id"` // Last chapter ID processed (for pages)
	StartTime       time.Time `json:"start_time"`      // When crawling started
	LastUpdateTime  time.Time `json:"last_update"`     // Last checkpoint update
	EstimatedTotal  int       `json:"estimated_total"` // Estimated total items to process
	ErrorCount      int       `json:"error_count"`     // Number of errors encountered
	SuccessCount    int       `json:"success_count"`   // Number of successful operations
}

const checkpointFile = "crawler_checkpoint.json"

// SaveCheckpoint saves the current crawling state
func (c *Crawler) SaveCheckpoint(checkpoint CrawlCheckpoint) error {
	checkpoint.LastUpdateTime = time.Now()
	
	data, err := json.MarshalIndent(checkpoint, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal checkpoint: %w", err)
	}
	
	// Create backup of existing checkpoint
	if _, err := os.Stat(checkpointFile); err == nil {
		backupFile := fmt.Sprintf("%s.backup", checkpointFile)
		if err := os.Rename(checkpointFile, backupFile); err != nil {
			log.Printf("Warning: failed to create checkpoint backup: %v", err)
		}
	}
	
	if err := os.WriteFile(checkpointFile, data, 0644); err != nil {
		return fmt.Errorf("failed to write checkpoint file: %w", err)
	}
	
	log.Printf("📊 Checkpoint saved: %s - Page %d - Processed %d/%d (%.1f%%)",
		checkpoint.Phase, checkpoint.CurrentPage, checkpoint.TotalProcessed,
		checkpoint.EstimatedTotal, float64(checkpoint.TotalProcessed)/float64(checkpoint.EstimatedTotal)*100)
	
	return nil
}

// LoadCheckpoint loads the last saved crawling state
func (c *Crawler) LoadCheckpoint() (*CrawlCheckpoint, error) {
	if _, err := os.Stat(checkpointFile); os.IsNotExist(err) {
		return nil, nil // No checkpoint exists
	}
	
	data, err := os.ReadFile(checkpointFile)
	if err != nil {
		return nil, fmt.Errorf("failed to read checkpoint file: %w", err)
	}
	
	var checkpoint CrawlCheckpoint
	if err := json.Unmarshal(data, &checkpoint); err != nil {
		return nil, fmt.Errorf("failed to unmarshal checkpoint: %w", err)
	}
	
	log.Printf("📂 Checkpoint loaded: %s - Page %d - Processed %d/%d",
		checkpoint.Phase, checkpoint.CurrentPage, checkpoint.TotalProcessed, checkpoint.EstimatedTotal)
	
	return &checkpoint, nil
}

// ClearCheckpoint removes the checkpoint file
func (c *Crawler) ClearCheckpoint() error {
	if err := os.Remove(checkpointFile); err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("failed to remove checkpoint file: %w", err)
	}
	log.Println("🗑️ Checkpoint cleared")
	return nil
}

// GetProgressReport generates a detailed progress report
func (c *Crawler) GetProgressReport(checkpoint CrawlCheckpoint) string {
	elapsed := time.Since(checkpoint.StartTime)
	
	var eta string
	if checkpoint.TotalProcessed > 0 && checkpoint.EstimatedTotal > 0 {
		rate := float64(checkpoint.TotalProcessed) / elapsed.Seconds()
		remaining := checkpoint.EstimatedTotal - checkpoint.TotalProcessed
		etaSeconds := float64(remaining) / rate
		eta = time.Duration(etaSeconds * float64(time.Second)).Round(time.Minute).String()
	} else {
		eta = "calculating..."
	}
	
	successRate := float64(checkpoint.SuccessCount) / float64(checkpoint.SuccessCount+checkpoint.ErrorCount) * 100
	if checkpoint.SuccessCount+checkpoint.ErrorCount == 0 {
		successRate = 100
	}
	
	return fmt.Sprintf(`
🚀 CRAWLING PROGRESS REPORT
========================
📊 Phase: %s
📄 Current Page: %d
✅ Processed: %d/%d (%.1f%%)
⏱️ Elapsed: %s
⏳ ETA: %s
✅ Success: %d
❌ Errors: %d
📈 Success Rate: %.1f%%
🔄 Last Update: %s
`, 
		checkpoint.Phase,
		checkpoint.CurrentPage,
		checkpoint.TotalProcessed,
		checkpoint.EstimatedTotal,
		float64(checkpoint.TotalProcessed)/float64(checkpoint.EstimatedTotal)*100,
		elapsed.Round(time.Second),
		eta,
		checkpoint.SuccessCount,
		checkpoint.ErrorCount,
		successRate,
		checkpoint.LastUpdateTime.Format("2006-01-02 15:04:05"),
	)
}
