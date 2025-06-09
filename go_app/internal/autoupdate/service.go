package autoupdate

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"baca-komik-api/database"
	"baca-komik-api/internal/crawler"
)

// AutoUpdateService handles automatic updates from external API
type AutoUpdateService struct {
	db       *database.Database
	crawler  *crawler.Crawler
	config   *Config
	stopChan chan bool
	running  bool
}

// Config for auto-update service
type Config struct {
	BaseURL      string        `json:"base_url"`
	Interval     time.Duration `json:"interval"`
	PageSize     int           `json:"page_size"`
	MaxPages     int           `json:"max_pages"`
	Enabled      bool          `json:"enabled"`
	CrawlChapters bool         `json:"crawl_chapters"`
	CrawlPages   bool          `json:"crawl_pages"`
}

// UpdateResponse from external API
type UpdateResponse struct {
	RetCode int     `json:"retcode"`
	Message string  `json:"message"`
	Meta    APIMeta `json:"meta"`
	Data    struct {
		Data       []UpdatedManga `json:"data"`
		Pagination Pagination     `json:"pagination"`
	} `json:"data"`
}

type APIMeta struct {
	RequestID   string `json:"request_id"`
	Timestamp   int64  `json:"timestamp"`
	ProcessTime string `json:"process_time"`
	Page        *int   `json:"page"`
	PageSize    *int   `json:"page_size"`
	TotalPage   *int   `json:"total_page"`
	TotalRecord *int   `json:"total_record"`
}

type Pagination struct {
	TotalPage   int `json:"total_page"`
	PageSize    int `json:"page_size"`
	TotalRecord int `json:"total_record"`
}

type UpdatedManga struct {
	ID                string    `json:"id"`
	Title             string    `json:"title"`
	AlternativeTitle  string    `json:"alternative_title"`
	Description       string    `json:"description"`
	Status            string    `json:"status"`
	Country           string    `json:"country"`
	ViewCount         int       `json:"view_count"`
	VoteCount         int       `json:"vote_count"`
	BookmarkCount     int       `json:"bookmark_count"`
	CoverImageURL     string    `json:"cover_image_url"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
	Rank              int       `json:"rank"`
	ReleaseYear       int       `json:"release_year"`
	LatestChapterID   string    `json:"latest_chapter_id"`
	LatestChapterNum  int       `json:"latest_chapter_number"`
	LatestChapterDate time.Time `json:"latest_chapter_date"`
}

// NewAutoUpdateService creates a new auto-update service
func NewAutoUpdateService(db *database.Database, crawler *crawler.Crawler) *AutoUpdateService {
	config := &Config{
		BaseURL:       "https://api.shngm.io/v1",
		Interval:      5 * time.Minute,
		PageSize:      24,
		MaxPages:      5, // Limit to first 5 pages for updates
		Enabled:       true,
		CrawlChapters: true,
		CrawlPages:    false, // Pages can be crawled separately
	}

	return &AutoUpdateService{
		db:       db,
		crawler:  crawler,
		config:   config,
		stopChan: make(chan bool),
		running:  false,
	}
}

// Start begins the auto-update service
func (s *AutoUpdateService) Start() error {
	if s.running {
		return fmt.Errorf("auto-update service is already running")
	}

	s.running = true
	log.Printf("🔄 Auto-Update Service starting...")
	log.Printf("   Interval: %v", s.config.Interval)
	log.Printf("   Max Pages: %d", s.config.MaxPages)
	log.Printf("   Crawl Chapters: %v", s.config.CrawlChapters)
	log.Printf("   Crawl Pages: %v", s.config.CrawlPages)

	go s.run()
	return nil
}

// Stop stops the auto-update service
func (s *AutoUpdateService) Stop() {
	if !s.running {
		return
	}

	log.Println("🛑 Stopping Auto-Update Service...")
	s.stopChan <- true
	s.running = false
}

// IsRunning returns whether the service is running
func (s *AutoUpdateService) IsRunning() bool {
	return s.running
}

// GetConfig returns current configuration
func (s *AutoUpdateService) GetConfig() *Config {
	return s.config
}

// UpdateConfig updates service configuration
func (s *AutoUpdateService) UpdateConfig(config *Config) {
	s.config = config
	log.Printf("🔧 Auto-Update Service config updated")
}

// run is the main service loop
func (s *AutoUpdateService) run() {
	log.Println("✅ Auto-Update Service started")
	
	// Initial update check
	s.checkForUpdates()

	ticker := time.NewTicker(s.config.Interval)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			if s.config.Enabled {
				s.checkForUpdates()
			}
		case <-s.stopChan:
			log.Println("✅ Auto-Update Service stopped")
			return
		}
	}
}

// checkForUpdates checks for new manga and chapters
func (s *AutoUpdateService) checkForUpdates() {
	log.Printf("🔍 Checking for updates... (%s)", time.Now().Format("15:04:05"))
	
	startTime := time.Now()
	newManga := 0
	newChapters := 0
	
	defer func() {
		elapsed := time.Since(startTime)
		log.Printf("✅ Update check completed in %v (New manga: %d, New chapters: %d)", 
			elapsed, newManga, newChapters)
	}()

	for page := 1; page <= s.config.MaxPages; page++ {
		updates, err := s.fetchUpdates(page)
		if err != nil {
			log.Printf("❌ Failed to fetch updates page %d: %v", page, err)
			continue
		}

		if len(updates.Data.Data) == 0 {
			log.Printf("📄 No more updates on page %d, stopping", page)
			break
		}

		for _, manga := range updates.Data.Data {
			// Check if manga exists in database
			exists, err := s.mangaExists(manga.ID)
			if err != nil {
				log.Printf("❌ Failed to check manga existence %s: %v", manga.ID, err)
				continue
			}

			if !exists {
				// New manga found
				log.Printf("🆕 New manga found: %s", manga.Title)
				if err := s.crawlNewManga(manga); err != nil {
					log.Printf("❌ Failed to crawl new manga %s: %v", manga.ID, err)
				} else {
					newManga++
				}
			} else {
				// Check for new chapters
				hasNewChapters, err := s.checkNewChapters(manga)
				if err != nil {
					log.Printf("❌ Failed to check new chapters for %s: %v", manga.ID, err)
					continue
				}

				if hasNewChapters {
					log.Printf("📖 New chapters found for: %s", manga.Title)
					if err := s.crawlNewChapters(manga.ID); err != nil {
						log.Printf("❌ Failed to crawl new chapters for %s: %v", manga.ID, err)
					} else {
						newChapters++
					}
				}
			}
		}

		// Rate limiting between pages
		time.Sleep(200 * time.Millisecond)
	}
}

// fetchUpdates fetches updates from external API
func (s *AutoUpdateService) fetchUpdates(page int) (*UpdateResponse, error) {
	url := fmt.Sprintf("%s/manga/list?type=&page=%d&page_size=%d&is_update=true&sort=latest&sort_order=desc",
		s.config.BaseURL, page, s.config.PageSize)

	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch updates: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API returned status %d", resp.StatusCode)
	}

	var response UpdateResponse
	if err := json.NewDecoder(resp.Body).Decode(&response); err != nil {
		return nil, fmt.Errorf("failed to decode response: %w", err)
	}

	return &response, nil
}

// mangaExists checks if manga exists in database
func (s *AutoUpdateService) mangaExists(externalID string) (bool, error) {
	ctx := context.Background()
	var count int

	query := `SELECT COUNT(*) FROM "mKomik" WHERE external_id = $1`
	err := s.db.Pool.QueryRow(ctx, query, externalID).Scan(&count)
	if err != nil {
		return false, err
	}

	return count > 0, nil
}

// checkNewChapters checks if manga has new chapters
func (s *AutoUpdateService) checkNewChapters(manga UpdatedManga) (bool, error) {
	ctx := context.Background()
	var latestChapterNum int

	query := `
		SELECT COALESCE(MAX(c.chapter_number), 0)
		FROM "mChapter" c
		JOIN "mKomik" m ON c.id_komik = m.id
		WHERE m.external_id = $1
	`
	err := s.db.Pool.QueryRow(ctx, query, manga.ID).Scan(&latestChapterNum)
	if err != nil {
		return false, err
	}

	// If external API shows newer chapter, we have new chapters
	return manga.LatestChapterNum > latestChapterNum, nil
}

// crawlNewManga crawls a new manga
func (s *AutoUpdateService) crawlNewManga(manga UpdatedManga) error {
	log.Printf("🚀 Crawling new manga: %s", manga.Title)

	// Convert to crawler format and save
	mangaList := []crawler.ExternalManga{
		{
			ID:               manga.ID,
			Title:            manga.Title,
			AlternativeTitle: manga.AlternativeTitle,
			Description:      manga.Description,
			Status:           manga.Status,
			Country:          manga.Country,
			ViewCount:        manga.ViewCount,
			VoteCount:        manga.VoteCount,
			BookmarkCount:    manga.BookmarkCount,
			CoverImageURL:    manga.CoverImageURL,
			CreatedAt:        manga.CreatedAt,
			Rank:             manga.Rank,
			ReleaseYear:      manga.ReleaseYear,
		},
	}

	if err := s.crawler.SaveMangaList(mangaList); err != nil {
		return fmt.Errorf("failed to save new manga: %w", err)
	}

	// If enabled, also crawl chapters
	if s.config.CrawlChapters {
		if err := s.crawler.CrawlChaptersForManga(manga.ID); err != nil {
			log.Printf("⚠️ Failed to crawl chapters for new manga %s: %v", manga.ID, err)
		}
	}

	return nil
}

// crawlNewChapters crawls new chapters for existing manga
func (s *AutoUpdateService) crawlNewChapters(mangaID string) error {
	log.Printf("📖 Crawling new chapters for manga: %s", mangaID)

	if err := s.crawler.CrawlChaptersForManga(mangaID); err != nil {
		return fmt.Errorf("failed to crawl new chapters: %w", err)
	}

	// If enabled, also crawl pages for new chapters
	if s.config.CrawlPages {
		// Get newly added chapters and crawl their pages
		if err := s.crawlPagesForNewChapters(mangaID); err != nil {
			log.Printf("⚠️ Failed to crawl pages for new chapters %s: %v", mangaID, err)
		}
	}

	return nil
}

// crawlPagesForNewChapters crawls pages for newly added chapters
func (s *AutoUpdateService) crawlPagesForNewChapters(mangaID string) error {
	ctx := context.Background()

	// Get chapters that don't have pages yet
	query := `
		SELECT c.external_id
		FROM "mChapter" c
		JOIN "mKomik" m ON c.id_komik = m.id
		LEFT JOIN "trChapter" p ON c.id = p.id_chapter
		WHERE m.external_id = $1
		AND c.external_id IS NOT NULL
		AND p.id_chapter IS NULL
	`

	rows, err := s.db.Pool.Query(ctx, query, mangaID)
	if err != nil {
		return err
	}
	defer rows.Close()

	var chapterIDs []string
	for rows.Next() {
		var chapterID string
		if err := rows.Scan(&chapterID); err != nil {
			return err
		}
		chapterIDs = append(chapterIDs, chapterID)
	}

	// Crawl pages for each new chapter
	for _, chapterID := range chapterIDs {
		if err := s.crawler.CrawlPagesForChapter(chapterID); err != nil {
			log.Printf("⚠️ Failed to crawl pages for chapter %s: %v", chapterID, err)
		}
	}

	return nil
}
