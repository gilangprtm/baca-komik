package crawler

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/google/uuid"
	"baca-komik-api/database"
)

type Crawler struct {
	db     *database.DB
	config *Config
	client *http.Client
}

func New(db *database.DB, config *Config) *Crawler {
	return &Crawler{
		db:     db,
		config: config,
		client: &http.Client{
			Timeout: 30 * time.Second,
		},
	}
}

// makeRequest makes HTTP request with proper headers
func (c *Crawler) makeRequest(url string) (*http.Response, error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %w", err)
	}

	// Add headers
	for key, value := range c.config.Headers {
		req.Header.Set(key, value)
	}

	if c.config.Verbose {
		log.Printf("Making request to: %s", url)
	}

	resp, err := c.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to make request: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		resp.Body.Close()
		return nil, fmt.Errorf("API returned status %d for URL: %s", resp.StatusCode, url)
	}

	return resp, nil
}

// fetchJSON fetches and unmarshals JSON response
func (c *Crawler) fetchJSON(url string, target interface{}) error {
	resp, err := c.makeRequest(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response body: %w", err)
	}

	if err := json.Unmarshal(body, target); err != nil {
		return fmt.Errorf("failed to unmarshal JSON: %w", err)
	}

	return nil
}

// CrawlGenres crawls all genres
func (c *Crawler) CrawlGenres() error {
	log.Println("Starting to crawl genres...")
	
	url := fmt.Sprintf("%s/genre/list", c.config.BaseURL)
	var response APIResponse
	
	if err := c.fetchJSON(url, &response); err != nil {
		return fmt.Errorf("failed to fetch genres: %w", err)
	}

	// Parse genres data
	genresData, err := json.Marshal(response.Data)
	if err != nil {
		return fmt.Errorf("failed to marshal genres data: %w", err)
	}

	var genres []ExternalGenre
	if err := json.Unmarshal(genresData, &genres); err != nil {
		return fmt.Errorf("failed to unmarshal genres: %w", err)
	}

	log.Printf("Found %d genres to process", len(genres))

	if c.config.DryRun {
		log.Println("DRY RUN: Would save genres to database")
		for _, genre := range genres {
			log.Printf("  - %s: %s", genre.Slug, genre.Name)
		}
		return nil
	}

	// Save to database
	return c.saveGenres(genres)
}

// CrawlFormats crawls all formats (simple endpoint with no pagination)
func (c *Crawler) CrawlFormats() error {
	log.Println("Starting to crawl formats...")

	var allFormats []ExternalFormat
	formatMap := make(map[string]bool) // To detect duplicates
	page := 1
	consecutiveDuplicatePages := 0
	maxConsecutiveDuplicates := 3 // Stop after 3 pages with no new data

	for {
		log.Printf("Fetching formats page %d...", page)
		url := fmt.Sprintf("%s/format/list?page=%d", c.config.BaseURL, page)
		var response APIResponse

		if err := c.fetchJSON(url, &response); err != nil {
			return fmt.Errorf("failed to fetch formats page %d: %w", page, err)
		}

		// Parse formats data
		formatsData, err := json.Marshal(response.Data)
		if err != nil {
			return fmt.Errorf("failed to marshal formats data: %w", err)
		}

		var formats []ExternalFormat
		if err := json.Unmarshal(formatsData, &formats); err != nil {
			return fmt.Errorf("failed to unmarshal formats: %w", err)
		}

		if len(formats) == 0 {
			log.Printf("No formats found on page %d, stopping", page)
			break
		}

		// Add unique formats
		newCount := 0
		for _, format := range formats {
			if !formatMap[format.Name] {
				formatMap[format.Name] = true
				allFormats = append(allFormats, format)
				newCount++
			}
		}

		log.Printf("Found %d formats (%d new) on page %d", len(formats), newCount, page)

		// Check for consecutive pages with no new data
		if newCount == 0 {
			consecutiveDuplicatePages++
			log.Printf("No new formats on page %d (%d consecutive duplicate pages)", page, consecutiveDuplicatePages)

			if consecutiveDuplicatePages >= maxConsecutiveDuplicates {
				log.Printf("Stopping after %d consecutive pages with no new data", maxConsecutiveDuplicates)
				break
			}
		} else {
			consecutiveDuplicatePages = 0 // Reset counter
		}

		page++
		time.Sleep(200 * time.Millisecond) // Rate limiting
	}

	log.Printf("Total unique formats found: %d", len(allFormats))

	if c.config.DryRun {
		log.Println("DRY RUN: Would save formats to database")
		for _, format := range allFormats {
			log.Printf("  - %s: %s", format.Slug, format.Name)
		}
		return nil
	}

	// Save to database
	return c.saveFormats(allFormats)
}

// CrawlTypes crawls all types (simple endpoint with no pagination)
func (c *Crawler) CrawlTypes() error {
	log.Println("Starting to crawl types...")

	var allTypes []ExternalType
	typeMap := make(map[string]bool) // To detect duplicates
	page := 1
	consecutiveDuplicatePages := 0
	maxConsecutiveDuplicates := 3 // Stop after 3 pages with no new data

	for {
		log.Printf("Fetching types page %d...", page)
		url := fmt.Sprintf("%s/type/list?page=%d", c.config.BaseURL, page)
		var response APIResponse

		if err := c.fetchJSON(url, &response); err != nil {
			return fmt.Errorf("failed to fetch types page %d: %w", page, err)
		}

		// Parse types data
		typesData, err := json.Marshal(response.Data)
		if err != nil {
			return fmt.Errorf("failed to marshal types data: %w", err)
		}

		var types []ExternalType
		if err := json.Unmarshal(typesData, &types); err != nil {
			return fmt.Errorf("failed to unmarshal types: %w", err)
		}

		if len(types) == 0 {
			log.Printf("No types found on page %d, stopping", page)
			break
		}

		// Add unique types
		newCount := 0
		for _, typ := range types {
			if !typeMap[typ.Name] {
				typeMap[typ.Name] = true
				allTypes = append(allTypes, typ)
				newCount++
			}
		}

		log.Printf("Found %d types (%d new) on page %d", len(types), newCount, page)

		// Check for consecutive pages with no new data
		if newCount == 0 {
			consecutiveDuplicatePages++
			log.Printf("No new types on page %d (%d consecutive duplicate pages)", page, consecutiveDuplicatePages)

			if consecutiveDuplicatePages >= maxConsecutiveDuplicates {
				log.Printf("Stopping after %d consecutive pages with no new data", maxConsecutiveDuplicates)
				break
			}
		} else {
			consecutiveDuplicatePages = 0 // Reset counter
		}

		page++
		time.Sleep(200 * time.Millisecond) // Rate limiting
	}

	log.Printf("Total unique types found: %d", len(allTypes))

	if c.config.DryRun {
		log.Println("DRY RUN: Would save types to database")
		for _, typ := range allTypes {
			log.Printf("  - %s: %s", typ.Slug, typ.Name)
		}
		return nil
	}

	// Save to database
	return c.saveTypes(allTypes)
}

// CrawlAuthors crawls all authors with auto-pagination and multiple search queries
func (c *Crawler) CrawlAuthors() error {
	log.Println("Starting to crawl authors...")

	var allAuthors []ExternalAuthor
	authorMap := make(map[string]bool) // To avoid duplicates

	// Search queries to get more comprehensive results (limited for efficiency)
	searchQueries := []string{"", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}

	for _, query := range searchQueries {
		log.Printf("Searching authors with query: '%s'", query)
		page := 1
		totalPages := 0

		for {
			log.Printf("Fetching authors page %d for query '%s'...", page, query)
			url := fmt.Sprintf("%s/author/list?q=%s&page=%d", c.config.BaseURL, query, page)
			var response APIResponse

			if err := c.fetchJSON(url, &response); err != nil {
				log.Printf("Failed to fetch authors page %d for query '%s': %v", page, query, err)
				break
			}

			// Get pagination info from meta
			if response.Meta.TotalPage != nil {
				totalPages = *response.Meta.TotalPage
				if page == 1 && totalPages > 0 {
					log.Printf("Query '%s' has %d pages available", query, totalPages)
				}
			}

			// Parse authors data
			authorsData, err := json.Marshal(response.Data)
			if err != nil {
				log.Printf("Failed to marshal authors data: %v", err)
				break
			}

			var authors []ExternalAuthor
			if err := json.Unmarshal(authorsData, &authors); err != nil {
				log.Printf("Failed to unmarshal authors: %v", err)
				break
			}

			if len(authors) == 0 {
				log.Printf("No more authors found on page %d for query '%s'", page, query)
				break
			}

			// Add unique authors
			newCount := 0
			for _, author := range authors {
				if !authorMap[author.Name] {
					authorMap[author.Name] = true
					allAuthors = append(allAuthors, author)
					newCount++
				}
			}

			log.Printf("Found %d authors (%d new) on page %d/%d for query '%s'", len(authors), newCount, page, totalPages, query)

			// Check if we've reached the last page
			if totalPages > 0 && page >= totalPages {
				log.Printf("Reached last page (%d) for query '%s'", totalPages, query)
				break
			}

			page++
			time.Sleep(100 * time.Millisecond) // Rate limiting
		}

		time.Sleep(300 * time.Millisecond) // Rate limiting between queries
	}

	log.Printf("Total unique authors found: %d", len(allAuthors))

	if c.config.DryRun {
		log.Println("DRY RUN: Would save authors to database")
		for i, author := range allAuthors {
			if i < 10 { // Show first 10
				log.Printf("  - %s: %s", author.Slug, author.Name)
			}
		}
		if len(allAuthors) > 10 {
			log.Printf("  ... and %d more authors", len(allAuthors)-10)
		}
		return nil
	}

	// Save to database
	return c.saveAuthors(allAuthors)
}

// CrawlArtists crawls all artists with auto-pagination and multiple search queries
func (c *Crawler) CrawlArtists() error {
	log.Println("Starting to crawl artists...")

	var allArtists []ExternalArtist
	artistMap := make(map[string]bool) // To avoid duplicates

	// Search queries to get more comprehensive results (limited for efficiency)
	searchQueries := []string{"", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}

	for _, query := range searchQueries {
		log.Printf("Searching artists with query: '%s'", query)
		page := 1
		totalPages := 0

		for {
			log.Printf("Fetching artists page %d for query '%s'...", page, query)
			url := fmt.Sprintf("%s/artist/list?q=%s&page=%d", c.config.BaseURL, query, page)
			var response APIResponse

			if err := c.fetchJSON(url, &response); err != nil {
				log.Printf("Failed to fetch artists page %d for query '%s': %v", page, query, err)
				break
			}

			// Get pagination info from meta
			if response.Meta.TotalPage != nil {
				totalPages = *response.Meta.TotalPage
				if page == 1 && totalPages > 0 {
					log.Printf("Query '%s' has %d pages available", query, totalPages)
				}
			}

			// Parse artists data
			artistsData, err := json.Marshal(response.Data)
			if err != nil {
				log.Printf("Failed to marshal artists data: %v", err)
				break
			}

			var artists []ExternalArtist
			if err := json.Unmarshal(artistsData, &artists); err != nil {
				log.Printf("Failed to unmarshal artists: %v", err)
				break
			}

			if len(artists) == 0 {
				log.Printf("No more artists found on page %d for query '%s'", page, query)
				break
			}

			// Add unique artists
			newCount := 0
			for _, artist := range artists {
				if !artistMap[artist.Name] {
					artistMap[artist.Name] = true
					allArtists = append(allArtists, artist)
					newCount++
				}
			}

			log.Printf("Found %d artists (%d new) on page %d/%d for query '%s'", len(artists), newCount, page, totalPages, query)

			// Check if we've reached the last page
			if totalPages > 0 && page >= totalPages {
				log.Printf("Reached last page (%d) for query '%s'", totalPages, query)
				break
			}

			page++
			time.Sleep(100 * time.Millisecond) // Rate limiting
		}

		time.Sleep(300 * time.Millisecond) // Rate limiting between queries
	}

	log.Printf("Total unique artists found: %d", len(allArtists))

	if c.config.DryRun {
		log.Println("DRY RUN: Would save artists to database")
		for i, artist := range allArtists {
			if i < 10 { // Show first 10
				log.Printf("  - %s: %s", artist.Slug, artist.Name)
			}
		}
		if len(allArtists) > 10 {
			log.Printf("  ... and %d more artists", len(allArtists)-10)
		}
		return nil
	}

	// Save to database
	return c.saveArtists(allArtists)
}

// CrawlAllMasterData crawls all master data with full auto-pagination
func (c *Crawler) CrawlAllMasterData() error {
	log.Println("🚀 Starting AUTO master data crawl (full pagination)...")

	// Step 1: Genres
	log.Println("📚 Phase 1: Auto-crawling genres...")
	if err := c.CrawlGenres(); err != nil {
		return fmt.Errorf("failed to crawl genres: %w", err)
	}

	// Step 2: Formats
	log.Println("📝 Phase 2: Auto-crawling formats...")
	if err := c.CrawlFormats(); err != nil {
		return fmt.Errorf("failed to crawl formats: %w", err)
	}

	// Step 3: Types
	log.Println("🏷️ Phase 3: Auto-crawling types...")
	if err := c.CrawlTypes(); err != nil {
		return fmt.Errorf("failed to crawl types: %w", err)
	}

	// Step 4: Authors (comprehensive search)
	log.Println("✍️ Phase 4: Auto-crawling authors (comprehensive search)...")
	if err := c.CrawlAuthors(); err != nil {
		return fmt.Errorf("failed to crawl authors: %w", err)
	}

	// Step 5: Artists (comprehensive search)
	log.Println("🎨 Phase 5: Auto-crawling artists (comprehensive search)...")
	if err := c.CrawlArtists(); err != nil {
		return fmt.Errorf("failed to crawl artists: %w", err)
	}

	log.Println("✅ All master data phases completed successfully!")
	return nil
}

// CrawlAll crawls everything in proper order
func (c *Crawler) CrawlAll() error {
	log.Println("Starting complete crawl process...")

	// Step 1: Master data
	log.Println("Phase 1: Crawling master data...")
	if err := c.CrawlAllMasterData(); err != nil {
		return fmt.Errorf("failed to crawl master data: %w", err)
	}

	log.Println("Phase 1 completed: Master data crawled successfully")

	// Step 2: Manga data (start with first 10 pages)
	log.Println("Phase 2: Crawling manga data...")
	if err := c.CrawlManga(1, 10); err != nil {
		return fmt.Errorf("failed to crawl manga: %w", err)
	}

	log.Println("Phase 2 completed: Manga data crawled successfully")

	// Step 3: Chapters (for crawled manga)
	log.Println("Phase 3: Crawling chapters...")
	if err := c.CrawlAllChapters(); err != nil {
		return fmt.Errorf("failed to crawl chapters: %w", err)
	}

	log.Println("Phase 3 completed: Chapters crawled successfully")

	// Step 4: Pages
	log.Println("Phase 4: Crawling pages...")
	if err := c.CrawlAllPages(); err != nil {
		return fmt.Errorf("failed to crawl pages: %w", err)
	}

	log.Println("All phases completed successfully!")
	return nil
}

// CrawlManga crawls manga list with auto-pagination (if endPage = -1, crawl all)
func (c *Crawler) CrawlManga(startPage, endPage int) error {
	if endPage == -1 {
		log.Printf("Starting to crawl ALL manga from page %d...", startPage)
	} else {
		log.Printf("Starting to crawl manga from page %d to %d...", startPage, endPage)
	}

	totalProcessed := 0
	totalSuccess := 0
	totalFailed := 0
	page := startPage

	for {
		if endPage != -1 && page > endPage {
			log.Printf("Reached specified end page (%d), stopping", endPage)
			break
		}

		log.Printf("Processing manga page %d...", page)

		url := fmt.Sprintf("%s/manga/list?type=&page=%d&page_size=24&is_update=true&sort=latest&sort_order=desc",
			c.config.BaseURL, page)

		var response MangaListResponse
		if err := c.fetchJSON(url, &response); err != nil {
			log.Printf("Failed to fetch manga page %d: %v", page, err)
			totalFailed++
			page++
			continue
		}

		mangaList := response.Data
		if len(mangaList) == 0 {
			log.Printf("No more manga found on page %d, stopping", page)
			break
		}

		log.Printf("Found %d manga on page %d", len(mangaList), page)
		totalProcessed += len(mangaList)

		if c.config.DryRun {
			log.Printf("DRY RUN: Would save %d manga from page %d", len(mangaList), page)
			for i, manga := range mangaList {
				if i < 3 { // Show first 3
					log.Printf("  - %s: %s", manga.ID, manga.Title)
				}
			}
			if len(mangaList) > 3 {
				log.Printf("  ... and %d more manga", len(mangaList)-3)
			}
			totalSuccess += len(mangaList)
		} else {
			// Save manga to database
			if err := c.saveMangaList(mangaList); err != nil {
				log.Printf("Failed to save manga from page %d: %v", page, err)
				totalFailed += len(mangaList)
			} else {
				log.Printf("Successfully processed %d manga from page %d", len(mangaList), page)
				totalSuccess += len(mangaList)
			}
		}

		// Check if we've reached the last page from API response
		if response.Meta.TotalPage != nil && page >= *response.Meta.TotalPage {
			log.Printf("Reached last page (%d) from API, stopping", *response.Meta.TotalPage)
			break
		}

		page++
		time.Sleep(500 * time.Millisecond) // Rate limiting
	}

	log.Printf("Manga crawling completed: %d processed, %d success, %d failed",
		totalProcessed, totalSuccess, totalFailed)
	return nil
}

// CrawlAllChapters crawls chapters for all manga in database
func (c *Crawler) CrawlAllChapters() error {
	log.Println("Starting to crawl chapters for all manga...")

	// Get all manga IDs from database
	mangaIDs, err := c.getAllMangaIDs()
	if err != nil {
		return fmt.Errorf("failed to get manga IDs: %w", err)
	}

	log.Printf("Found %d manga to process chapters for", len(mangaIDs))

	totalProcessed := 0
	totalSuccess := 0
	totalFailed := 0

	for i, mangaID := range mangaIDs {
		log.Printf("Processing chapters for manga %d/%d (ID: %s)...", i+1, len(mangaIDs), mangaID)

		if err := c.CrawlChaptersForManga(mangaID); err != nil {
			log.Printf("ERROR: Failed to crawl chapters for manga %s: %v", mangaID, err)
			totalFailed++
		} else {
			log.Printf("SUCCESS: Crawled chapters for manga %s", mangaID)
			totalSuccess++
		}
		totalProcessed++

		// Rate limiting
		time.Sleep(500 * time.Millisecond)
	}

	log.Printf("Chapter crawling completed: %d manga processed, %d success, %d failed",
		totalProcessed, totalSuccess, totalFailed)
	return nil
}

// CrawlChaptersForManga crawls chapters for specific manga
func (c *Crawler) CrawlChaptersForManga(mangaID string) error {
	log.Printf("Starting to crawl chapters for manga: %s", mangaID)
	page := 1
	totalChapters := 0

	for {
		url := fmt.Sprintf("%s/v1/chapter/%s/list?page=%d&page_size=24&sort_by=chapter_number&sort_order=desc",
			c.config.BaseURL, mangaID, page)

		log.Printf("Fetching chapters from URL: %s", url)

		var response ChaptersResponse
		if err := c.fetchJSON(url, &response); err != nil {
			log.Printf("ERROR: Failed to fetch from URL %s: %v", url, err)
			return fmt.Errorf("failed to fetch chapters for manga %s page %d: %w", mangaID, page, err)
		}

		log.Printf("API Response retcode: %d, message: %s", response.RetCode, response.Message)

		// Chapters are directly in response.Data
		chapters := response.Data

		log.Printf("Found %d chapters on page %d for manga %s", len(chapters), page, mangaID)

		if len(chapters) == 0 {
			log.Printf("No more chapters found, breaking loop")
			break // No more chapters
		}

		if c.config.Verbose {
			log.Printf("Found %d chapters on page %d for manga %s", len(chapters), page, mangaID)
		}

		if !c.config.DryRun {
			if err := c.saveChaptersList(chapters, mangaID); err != nil {
				return fmt.Errorf("failed to save chapters: %w", err)
			}
		}

		totalChapters += len(chapters)
		page++

		// Check if we've reached the last page using pagination metadata from Meta
		if response.Meta.TotalPage != nil && page > *response.Meta.TotalPage {
			log.Printf("Reached last page (%d/%d), breaking loop", page-1, *response.Meta.TotalPage)
			break
		}

		// Rate limiting
		time.Sleep(200 * time.Millisecond)
	}

	if c.config.Verbose {
		log.Printf("Crawled %d chapters for manga %s", totalChapters, mangaID)
	}
	return nil
}

// CrawlAllPages crawls pages for all chapters
func (c *Crawler) CrawlAllPages() error {
	log.Println("Starting to crawl pages for all chapters...")

	// Get all chapter IDs from database
	chapterIDs, err := c.getAllChapterIDs()
	if err != nil {
		return fmt.Errorf("failed to get chapter IDs: %w", err)
	}

	log.Printf("Found %d chapters to process pages for", len(chapterIDs))

	totalProcessed := 0
	totalSuccess := 0
	totalFailed := 0

	for i, chapterID := range chapterIDs {
		if i%100 == 0 {
			log.Printf("Processing pages for chapter %d/%d...", i+1, len(chapterIDs))
		}

		if err := c.crawlPagesForChapter(chapterID); err != nil {
			if c.config.Verbose {
				log.Printf("Failed to crawl pages for chapter %s: %v", chapterID, err)
			}
			totalFailed++
		} else {
			totalSuccess++
		}
		totalProcessed++

		// Rate limiting
		time.Sleep(100 * time.Millisecond)
	}

	log.Printf("Pages crawling completed: %d chapters processed, %d success, %d failed",
		totalProcessed, totalSuccess, totalFailed)
	return nil
}

// Helper function to generate UUID
func generateUUID() string {
	return uuid.New().String()
}
