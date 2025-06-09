package main

import (
	"flag"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"baca-komik-api/config"
	"baca-komik-api/database"
	"baca-komik-api/internal/autoupdate"
	"baca-komik-api/internal/crawler"
)

func main() {
	var (
		interval      = flag.Duration("interval", 5*time.Minute, "Update check interval")
		maxPages      = flag.Int("max-pages", 5, "Maximum pages to check for updates")
		pageSize      = flag.Int("page-size", 24, "Page size for API requests")
		crawlChapters = flag.Bool("crawl-chapters", true, "Automatically crawl new chapters")
		crawlPages    = flag.Bool("crawl-pages", false, "Automatically crawl new pages")
		verbose       = flag.Bool("verbose", true, "Verbose logging")
		help          = flag.Bool("help", false, "Show help")
	)
	flag.Parse()

	if *help {
		showHelp()
		os.Exit(0)
	}

	log.Printf("🔄 Auto-Updater Starting...")
	log.Printf("   Interval: %v", *interval)
	log.Printf("   Max Pages: %d", *maxPages)
	log.Printf("   Page Size: %d", *pageSize)
	log.Printf("   Crawl Chapters: %v", *crawlChapters)
	log.Printf("   Crawl Pages: %v", *crawlPages)
	log.Printf("   Verbose: %v", *verbose)
	log.Println("")

	// Load configuration
	cfg := config.Load()

	// Initialize database
	db, err := database.NewConnection(cfg)
	if err != nil {
		log.Fatalf("❌ Failed to connect to database: %v", err)
	}
	defer db.Close()

	// Initialize crawler
	crawlerConfig := &crawler.Config{
		BaseURL:   "https://api.shngm.io/v1",
		BatchSize: 10,
		DryRun:    false,
		Verbose:   *verbose,
		Headers: map[string]string{
			"User-Agent":       "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36",
			"Origin":           "https://app.shinigami.asia",
			"Referer":          "https://app.shinigami.asia/",
			"Sec-Fetch-Mode":   "cors",
			"Sec-Fetch-Site":   "cross-site",
		},
	}
	crawlerInstance := crawler.New(db, crawlerConfig)

	// Initialize auto-update service
	autoUpdateService := autoupdate.NewAutoUpdateService(db, crawlerInstance)

	// Update configuration
	config := &autoupdate.Config{
		BaseURL:       "https://api.shngm.io/v1",
		Interval:      *interval,
		PageSize:      *pageSize,
		MaxPages:      *maxPages,
		Enabled:       true,
		CrawlChapters: *crawlChapters,
		CrawlPages:    *crawlPages,
	}
	autoUpdateService.UpdateConfig(config)

	// Start the service
	if err := autoUpdateService.Start(); err != nil {
		log.Fatalf("❌ Failed to start auto-update service: %v", err)
	}

	// Setup graceful shutdown
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)

	log.Println("✅ Auto-Updater is running. Press Ctrl+C to stop.")
	log.Println("📊 Monitoring for new manga and chapters...")
	log.Println("")

	// Wait for shutdown signal
	<-c
	log.Println("")
	log.Println("🛑 Shutdown signal received...")

	// Stop the service
	autoUpdateService.Stop()

	log.Println("✅ Auto-Updater stopped gracefully")
}

func showHelp() {
	log.Println("🔄 Auto-Updater - Automatic manga and chapter updates")
	log.Println("")
	log.Println("Usage:")
	log.Println("  go run cmd/auto-updater/main.go [options]")
	log.Println("")
	log.Println("Options:")
	log.Println("  -interval duration     Update check interval (default: 5m)")
	log.Println("  -max-pages int         Maximum pages to check (default: 5)")
	log.Println("  -page-size int         Page size for API requests (default: 24)")
	log.Println("  -crawl-chapters        Automatically crawl new chapters (default: true)")
	log.Println("  -crawl-pages           Automatically crawl new pages (default: false)")
	log.Println("  -verbose               Verbose logging (default: true)")
	log.Println("  -help                  Show this help")
	log.Println("")
	log.Println("Examples:")
	log.Println("  # Default settings (check every 5 minutes)")
	log.Println("  go run cmd/auto-updater/main.go")
	log.Println("")
	log.Println("  # Check every 2 minutes with pages crawling")
	log.Println("  go run cmd/auto-updater/main.go -interval=2m -crawl-pages")
	log.Println("")
	log.Println("  # Production mode (every 10 minutes, no verbose)")
	log.Println("  go run cmd/auto-updater/main.go -interval=10m -verbose=false")
	log.Println("")
	log.Println("Features:")
	log.Println("  ✅ Automatic detection of new manga")
	log.Println("  ✅ Automatic detection of new chapters")
	log.Println("  ✅ Configurable crawling of chapters and pages")
	log.Println("  ✅ Rate limiting and error handling")
	log.Println("  ✅ Graceful shutdown with Ctrl+C")
	log.Println("")
	log.Println("API Endpoint:")
	log.Println("  https://api.shngm.io/v1/manga/list?is_update=true&sort=latest")
}
