package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"baca-komik-api/config"
	"baca-komik-api/database"
)

func main() {
	var (
		oldBaseURL = flag.String("old", "", "Old base URL to replace (e.g., https://old-storage.shngm.id)")
		newBaseURL = flag.String("new", "", "New base URL to use (e.g., https://new-storage.shngm.id)")
		dryRun     = flag.Bool("dry-run", true, "Dry run mode (default: true)")
		verbose    = flag.Bool("verbose", false, "Verbose logging")
	)
	flag.Parse()

	if *oldBaseURL == "" || *newBaseURL == "" {
		fmt.Println("Usage: go run cmd/url-updater/main.go -old=<old_url> -new=<new_url> [-dry-run=false] [-verbose]")
		fmt.Println("")
		fmt.Println("Examples:")
		fmt.Println("  # Dry run (preview changes)")
		fmt.Println("  go run cmd/url-updater/main.go -old=https://storage.shngm.id -new=https://new-storage.shngm.id")
		fmt.Println("")
		fmt.Println("  # Actually update URLs")
		fmt.Println("  go run cmd/url-updater/main.go -old=https://storage.shngm.id -new=https://new-storage.shngm.id -dry-run=false")
		os.Exit(1)
	}

	// Load configuration
	cfg := config.Load()

	// Initialize database
	db, err := database.NewConnection(cfg)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	updater := &URLUpdater{
		db:         db,
		oldBaseURL: *oldBaseURL,
		newBaseURL: *newBaseURL,
		dryRun:     *dryRun,
		verbose:    *verbose,
	}

	log.Printf("🔄 URL Updater Starting...")
	log.Printf("Old Base URL: %s", *oldBaseURL)
	log.Printf("New Base URL: %s", *newBaseURL)
	log.Printf("Dry Run: %v", *dryRun)
	log.Printf("Verbose: %v", *verbose)
	log.Println("")

	if err := updater.UpdateAllURLs(); err != nil {
		log.Fatalf("Failed to update URLs: %v", err)
	}

	log.Println("✅ URL update completed successfully!")
}

type URLUpdater struct {
	db         *database.Database
	oldBaseURL string
	newBaseURL string
	dryRun     bool
	verbose    bool
}

func (u *URLUpdater) UpdateAllURLs() error {
	ctx := context.Background()

	// Update mKomik cover_image_url
	if err := u.updateMangaCoverURLs(ctx); err != nil {
		return fmt.Errorf("failed to update manga cover URLs: %w", err)
	}

	// Update mChapter thumbnail_image_url
	if err := u.updateChapterThumbnailURLs(ctx); err != nil {
		return fmt.Errorf("failed to update chapter thumbnail URLs: %w", err)
	}

	// Update trChapter image URLs
	if err := u.updateChapterPageURLs(ctx); err != nil {
		return fmt.Errorf("failed to update chapter page URLs: %w", err)
	}

	return nil
}

func (u *URLUpdater) updateMangaCoverURLs(ctx context.Context) error {
	log.Println("📚 Updating manga cover URLs...")

	// Get count of affected records
	countQuery := `SELECT COUNT(*) FROM "mKomik" WHERE cover_image_url LIKE $1`
	var count int
	if err := u.db.Pool.QueryRow(ctx, countQuery, u.oldBaseURL+"%").Scan(&count); err != nil {
		return err
	}

	log.Printf("Found %d manga records to update", count)

	if count == 0 {
		log.Println("No manga records need updating")
		return nil
	}

	if u.dryRun {
		// Show sample of what would be updated
		sampleQuery := `
			SELECT id, title, cover_image_url 
			FROM "mKomik" 
			WHERE cover_image_url LIKE $1 
			LIMIT 5
		`
		rows, err := u.db.Pool.Query(ctx, sampleQuery, u.oldBaseURL+"%")
		if err != nil {
			return err
		}
		defer rows.Close()

		log.Println("Sample records that would be updated:")
		for rows.Next() {
			var id, title, oldURL string
			if err := rows.Scan(&id, &title, &oldURL); err != nil {
				return err
			}
			newURL := strings.Replace(oldURL, u.oldBaseURL, u.newBaseURL, 1)
			log.Printf("  %s: %s", title, oldURL)
			log.Printf("  -> %s", newURL)
			log.Println()
		}
		return nil
	}

	// Actually update the URLs
	updateQuery := `
		UPDATE "mKomik" 
		SET cover_image_url = REPLACE(cover_image_url, $1, $2),
		    updated_at = NOW()
		WHERE cover_image_url LIKE $3
	`

	result, err := u.db.Pool.Exec(ctx, updateQuery, u.oldBaseURL, u.newBaseURL, u.oldBaseURL+"%")
	if err != nil {
		return err
	}

	rowsAffected := result.RowsAffected()
	log.Printf("✅ Updated %d manga cover URLs", rowsAffected)

	return nil
}

func (u *URLUpdater) updateChapterThumbnailURLs(ctx context.Context) error {
	log.Println("📖 Updating chapter thumbnail URLs...")

	// Get count of affected records
	countQuery := `SELECT COUNT(*) FROM "mChapter" WHERE thumbnail_image_url LIKE $1`
	var count int
	if err := u.db.Pool.QueryRow(ctx, countQuery, u.oldBaseURL+"%").Scan(&count); err != nil {
		return err
	}

	log.Printf("Found %d chapter records to update", count)

	if count == 0 {
		log.Println("No chapter records need updating")
		return nil
	}

	if u.dryRun {
		// Show sample of what would be updated
		sampleQuery := `
			SELECT c.id, c.chapter_number, c.thumbnail_image_url, m.title
			FROM "mChapter" c
			LEFT JOIN "mKomik" m ON c.id_komik = m.id
			WHERE c.thumbnail_image_url LIKE $1 
			LIMIT 5
		`
		rows, err := u.db.Pool.Query(ctx, sampleQuery, u.oldBaseURL+"%")
		if err != nil {
			return err
		}
		defer rows.Close()

		log.Println("Sample records that would be updated:")
		for rows.Next() {
			var id, oldURL, title string
			var chapterNumber int
			if err := rows.Scan(&id, &chapterNumber, &oldURL, &title); err != nil {
				return err
			}
			newURL := strings.Replace(oldURL, u.oldBaseURL, u.newBaseURL, 1)
			log.Printf("  %s Ch.%d: %s", title, chapterNumber, oldURL)
			log.Printf("  -> %s", newURL)
			log.Println()
		}
		return nil
	}

	// Actually update the URLs
	updateQuery := `
		UPDATE "mChapter" 
		SET thumbnail_image_url = REPLACE(thumbnail_image_url, $1, $2),
		    updated_at = NOW()
		WHERE thumbnail_image_url LIKE $3
	`

	result, err := u.db.Pool.Exec(ctx, updateQuery, u.oldBaseURL, u.newBaseURL, u.oldBaseURL+"%")
	if err != nil {
		return err
	}

	rowsAffected := result.RowsAffected()
	log.Printf("✅ Updated %d chapter thumbnail URLs", rowsAffected)

	return nil
}

func (u *URLUpdater) updateMangaCoverURLs(ctx context.Context) error {
	log.Println("📚 Updating manga cover URLs...")

	// Get count of affected records
	countQuery := `SELECT COUNT(*) FROM "mKomik" WHERE cover_image_url LIKE $1`
	var count int
	if err := u.db.Pool.QueryRow(ctx, countQuery, u.oldBaseURL+"%").Scan(&count); err != nil {
		return err
	}

	if count == 0 {
		if u.verbose {
			log.Println("   No manga records need updating")
		}
		return nil
	}

	log.Printf("   Found %d manga records to update", count)

	if u.dryRun {
		return u.showMangaSample(ctx)
	}

	// Actually update the URLs
	updateQuery := `
		UPDATE "mKomik"
		SET cover_image_url = REPLACE(cover_image_url, $1, $2),
		    updated_at = NOW()
		WHERE cover_image_url LIKE $3
	`

	result, err := u.db.Pool.Exec(ctx, updateQuery, u.oldBaseURL, u.newBaseURL, u.oldBaseURL+"%")
	if err != nil {
		return err
	}

	rowsAffected := result.RowsAffected()
	log.Printf("   ✅ Updated %d manga cover URLs", rowsAffected)

	return nil
}

func (u *URLUpdater) updateChapterThumbnailURLs(ctx context.Context) error {
	log.Println("📖 Updating chapter thumbnail URLs...")

	// Get count of affected records
	countQuery := `SELECT COUNT(*) FROM "mChapter" WHERE thumbnail_image_url LIKE $1`
	var count int
	if err := u.db.Pool.QueryRow(ctx, countQuery, u.oldBaseURL+"%").Scan(&count); err != nil {
		return err
	}

	if count == 0 {
		if u.verbose {
			log.Println("   No chapter records need updating")
		}
		return nil
	}

	log.Printf("   Found %d chapter records to update", count)

	if u.dryRun {
		return u.showChapterSample(ctx)
	}

	// Actually update the URLs
	updateQuery := `
		UPDATE "mChapter"
		SET thumbnail_image_url = REPLACE(thumbnail_image_url, $1, $2),
		    updated_at = NOW()
		WHERE thumbnail_image_url LIKE $3
	`

	result, err := u.db.Pool.Exec(ctx, updateQuery, u.oldBaseURL, u.newBaseURL, u.oldBaseURL+"%")
	if err != nil {
		return err
	}

	rowsAffected := result.RowsAffected()
	log.Printf("   ✅ Updated %d chapter thumbnail URLs", rowsAffected)

	return nil
}

func (u *URLUpdater) updateChapterPageURLs(ctx context.Context) error {
	log.Println("📄 Updating chapter page URLs...")

	// Get count of affected records
	countQuery := `SELECT COUNT(*) FROM "trChapter" WHERE image_url LIKE $1 OR image_url_low LIKE $1`
	var count int
	if err := u.db.Pool.QueryRow(ctx, countQuery, u.oldBaseURL+"%").Scan(&count); err != nil {
		return err
	}

	if count == 0 {
		if u.verbose {
			log.Println("   No page records need updating")
		}
		return nil
	}

	log.Printf("   Found %d page records to update", count)

	if u.dryRun {
		return u.showPageSample(ctx)
	}

	// Actually update the URLs
	updateQuery := `
		UPDATE "trChapter"
		SET image_url = REPLACE(image_url, $1, $2),
		    image_url_low = REPLACE(image_url_low, $1, $2)
		WHERE image_url LIKE $3 OR image_url_low LIKE $3
	`

	result, err := u.db.Pool.Exec(ctx, updateQuery, u.oldBaseURL, u.newBaseURL, u.oldBaseURL+"%")
	if err != nil {
		return err
	}

	rowsAffected := result.RowsAffected()
	log.Printf("   ✅ Updated %d page URLs", rowsAffected)

	return nil
}

func (u *URLUpdater) showMangaSample(ctx context.Context) error {
	sampleQuery := `
		SELECT id, title, cover_image_url
		FROM "mKomik"
		WHERE cover_image_url LIKE $1
		LIMIT 3
	`
	rows, err := u.db.Pool.Query(ctx, sampleQuery, u.oldBaseURL+"%")
	if err != nil {
		return err
	}
	defer rows.Close()

	log.Println("   📚 Sample manga records:")
	for rows.Next() {
		var id, title, oldURL string
		if err := rows.Scan(&id, &title, &oldURL); err != nil {
			return err
		}
		newURL := strings.Replace(oldURL, u.oldBaseURL, u.newBaseURL, 1)
		log.Printf("      📖 %s", title)
		if u.verbose {
			log.Printf("         Old: %s", oldURL)
			log.Printf("         New: %s", newURL)
		}
	}
	return nil
}

func (u *URLUpdater) showChapterSample(ctx context.Context) error {
	sampleQuery := `
		SELECT c.id, c.chapter_number, c.thumbnail_image_url, m.title
		FROM "mChapter" c
		LEFT JOIN "mKomik" m ON c.id_komik = m.id
		WHERE c.thumbnail_image_url LIKE $1
		LIMIT 3
	`
	rows, err := u.db.Pool.Query(ctx, sampleQuery, u.oldBaseURL+"%")
	if err != nil {
		return err
	}
	defer rows.Close()

	log.Println("   📖 Sample chapter records:")
	for rows.Next() {
		var id, oldURL, title string
		var chapterNumber int
		if err := rows.Scan(&id, &chapterNumber, &oldURL, &title); err != nil {
			return err
		}
		newURL := strings.Replace(oldURL, u.oldBaseURL, u.newBaseURL, 1)
		log.Printf("      📄 %s - Chapter %d", title, chapterNumber)
		if u.verbose {
			log.Printf("         Old: %s", oldURL)
			log.Printf("         New: %s", newURL)
		}
	}
	return nil
}

func (u *URLUpdater) showPageSample(ctx context.Context) error {
	sampleQuery := `
		SELECT p.id, p.page_number, p.image_url, p.image_url_low
		FROM "trChapter" p
		WHERE p.image_url LIKE $1 OR p.image_url_low LIKE $1
		LIMIT 3
	`
	rows, err := u.db.Pool.Query(ctx, sampleQuery, u.oldBaseURL+"%")
	if err != nil {
		return err
	}
	defer rows.Close()

	log.Println("   📄 Sample page records:")
	for rows.Next() {
		var id, oldURL, oldURLLow string
		var pageNumber int
		if err := rows.Scan(&id, &pageNumber, &oldURL, &oldURLLow); err != nil {
			return err
		}
		newURL := strings.Replace(oldURL, u.oldBaseURL, u.newBaseURL, 1)
		newURLLow := strings.Replace(oldURLLow, u.oldBaseURL, u.newBaseURL, 1)
		log.Printf("      🖼️  Page %d", pageNumber)
		if u.verbose {
			log.Printf("         Old: %s", oldURL)
			log.Printf("         New: %s", newURL)
			log.Printf("         Old Low: %s", oldURLLow)
			log.Printf("         New Low: %s", newURLLow)
		}
	}
	return nil
}
