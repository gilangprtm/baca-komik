package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"baca-komik-api/config"
	"baca-komik-api/database"
	"baca-komik-api/internal/crawler"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Define command line flags
	var (
		mode      = flag.String("mode", "", "Crawling mode: genres, formats, types, authors, artists, manga, chapters, pages, resume, status")
		startPage = flag.Int("start-page", 1, "Start page for pagination")
		endPage   = flag.Int("end-page", 1, "End page for pagination")
		batchSize = flag.Int("batch-size", 10, "Batch size for processing")
		mangaID   = flag.String("manga-id", "", "Specific manga ID to crawl (for chapters/pages)")
		dryRun    = flag.Bool("dry-run", false, "Run without saving to database")
		verbose   = flag.Bool("verbose", false, "Enable verbose logging")
		clearCheckpoint = flag.Bool("clear-checkpoint", false, "Clear existing checkpoint")
	)
	flag.Parse()

	if *mode == "" {
		fmt.Println("Usage: crawler --mode=<mode> [options]")
		fmt.Println("\nAvailable modes:")
		fmt.Println("  genres    - Crawl all genres")
		fmt.Println("  formats   - Crawl all formats")
		fmt.Println("  types     - Crawl all types")
		fmt.Println("  authors   - Crawl all authors")
		fmt.Println("  artists   - Crawl all artists")
		fmt.Println("  manga     - Crawl manga list")
		fmt.Println("  chapters  - Crawl chapters for manga")
		fmt.Println("  pages     - Crawl pages for chapters")
		fmt.Println("  all       - Crawl everything (master data first)")
		fmt.Println("  auto      - Auto crawl all master data (full pagination)")
		fmt.Println("  resume    - Resume from last checkpoint")
		fmt.Println("  status    - Show current crawling status")
		fmt.Println("\nExamples:")
		fmt.Println("  crawler --mode=genres")
		fmt.Println("  crawler --mode=manga --start-page=1 --end-page=10 --batch-size=20")
		fmt.Println("  crawler --mode=manga --start-page=1 --end-page=-1  # Crawl ALL pages")
		fmt.Println("  crawler --mode=chapters --manga-id=all --batch-size=5")
		fmt.Println("  crawler --mode=auto --dry-run  # Auto crawl all master data")
		fmt.Println("  crawler --mode=all --dry-run")
		fmt.Println("  crawler --mode=resume  # Resume interrupted crawling")
		fmt.Println("  crawler --mode=status  # Check crawling progress")
		fmt.Println("  crawler --clear-checkpoint  # Clear saved progress")
		os.Exit(1)
	}

	// Initialize configuration
	cfg := config.Load()

	// Initialize database connection
	db, err := database.Connect(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Initialize crawler
	crawlerConfig := &crawler.Config{
		BaseURL:   "https://api.shngm.io/v1",
		BatchSize: *batchSize,
		DryRun:    *dryRun,
		Verbose:   *verbose,
		Headers: map[string]string{
			"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36",
			"Origin":     "https://app.shinigami.asia",
			"Referer":    "https://app.shinigami.asia/",
			"Sec-Fetch-Mode": "cors",
			"Sec-Fetch-Site": "cross-site",
		},
	}

	c := crawler.New(db, crawlerConfig)

	// Handle checkpoint operations
	if *clearCheckpoint {
		if err := c.ClearCheckpoint(); err != nil {
			log.Fatalf("Failed to clear checkpoint: %v", err)
		}
		log.Println("Checkpoint cleared successfully!")
		return
	}

	// Execute crawling based on mode
	switch *mode {
	case "genres":
		if err := c.CrawlGenres(); err != nil {
			log.Fatalf("Failed to crawl genres: %v", err)
		}
	case "formats":
		if err := c.CrawlFormats(); err != nil {
			log.Fatalf("Failed to crawl formats: %v", err)
		}
	case "types":
		if err := c.CrawlTypes(); err != nil {
			log.Fatalf("Failed to crawl types: %v", err)
		}
	case "authors":
		if err := c.CrawlAuthors(); err != nil {
			log.Fatalf("Failed to crawl authors: %v", err)
		}
	case "artists":
		if err := c.CrawlArtists(); err != nil {
			log.Fatalf("Failed to crawl artists: %v", err)
		}
	case "manga":
		if err := c.CrawlManga(*startPage, *endPage); err != nil {
			log.Fatalf("Failed to crawl manga: %v", err)
		}
	case "chapters":
		if *mangaID == "all" {
			if err := c.CrawlAllChapters(); err != nil {
				log.Fatalf("Failed to crawl all chapters: %v", err)
			}
		} else if *mangaID != "" {
			if err := c.CrawlChaptersForManga(*mangaID); err != nil {
				log.Fatalf("Failed to crawl chapters for manga %s: %v", *mangaID, err)
			}
		} else {
			log.Fatal("Please specify --manga-id=<id> or --manga-id=all")
		}
	case "pages":
		if err := c.CrawlAllPages(); err != nil {
			log.Fatalf("Failed to crawl pages: %v", err)
		}
	case "all":
		if err := c.CrawlAll(); err != nil {
			log.Fatalf("Failed to crawl all data: %v", err)
		}
	case "auto":
		if err := c.CrawlAllMasterData(); err != nil {
			log.Fatalf("Failed to auto crawl master data: %v", err)
		}
	case "resume":
		checkpoint, err := c.LoadCheckpoint()
		if err != nil {
			log.Fatalf("Failed to load checkpoint: %v", err)
		}
		if checkpoint == nil {
			log.Println("No checkpoint found. Nothing to resume.")
			return
		}
		log.Printf("Resuming %s crawling from page %d...", checkpoint.Phase, checkpoint.CurrentPage)
		// TODO: Implement resume logic based on checkpoint.Phase
		log.Println("Resume functionality will be implemented in the next update")
	case "status":
		checkpoint, err := c.LoadCheckpoint()
		if err != nil {
			log.Fatalf("Failed to load checkpoint: %v", err)
		}
		if checkpoint == nil {
			log.Println("No active crawling session found.")
			return
		}
		fmt.Print(c.GetProgressReport(*checkpoint))
	default:
		log.Fatalf("Unknown mode: %s", *mode)
	}

	log.Println("Crawling completed successfully!")
}
