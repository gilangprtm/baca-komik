package crawler

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"baca-komik-api/database"
)

// saveGenres saves genres to database
func (c *Crawler) saveGenres(genres []ExternalGenre) error {
	ctx := context.Background()
	tx, err := c.db.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	for _, genre := range genres {
		query := `
			INSERT INTO "mGenre" (id, name, created_at, updated_at)
			VALUES ($1, $2, NOW(), NOW())
			ON CONFLICT (name) DO UPDATE SET
				name = EXCLUDED.name,
				updated_at = NOW()
		`

		genreID := generateUUID()
		if _, err := tx.Exec(ctx, query, genreID, genre.Name); err != nil {
			return fmt.Errorf("failed to insert genre %s: %w", genre.Name, err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	log.Printf("Successfully saved %d genres", len(genres))
	return nil
}

// saveFormats saves formats to database
func (c *Crawler) saveFormats(formats []ExternalFormat) error {
	ctx := context.Background()
	tx, err := c.db.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	for _, format := range formats {
		query := `
			INSERT INTO "mFormat" (id, name, created_at, updated_at)
			VALUES ($1, $2, NOW(), NOW())
			ON CONFLICT (name) DO UPDATE SET
				name = EXCLUDED.name,
				updated_at = NOW()
		`

		formatID := generateUUID()
		if _, err := tx.Exec(ctx, query, formatID, format.Name); err != nil {
			return fmt.Errorf("failed to insert format %s: %w", format.Name, err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	log.Printf("Successfully saved %d formats", len(formats))
	return nil
}

// saveTypes saves types to database
func (c *Crawler) saveTypes(types []ExternalType) error {
	ctx := context.Background()
	tx, err := c.db.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	for _, typ := range types {
		query := `
			INSERT INTO "mType" (id, name, created_at, updated_at)
			VALUES ($1, $2, NOW(), NOW())
			ON CONFLICT (name) DO UPDATE SET
				name = EXCLUDED.name,
				updated_at = NOW()
		`

		typeID := generateUUID()
		if _, err := tx.Exec(ctx, query, typeID, typ.Name); err != nil {
			return fmt.Errorf("failed to insert type %s: %w", typ.Name, err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	log.Printf("Successfully saved %d types", len(types))
	return nil
}

// saveAuthors saves authors to database
func (c *Crawler) saveAuthors(authors []ExternalAuthor) error {
	ctx := context.Background()
	tx, err := c.db.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	for _, author := range authors {
		query := `
			INSERT INTO "mAuthor" (id, name, created_at, updated_at)
			VALUES ($1, $2, NOW(), NOW())
			ON CONFLICT (name) DO UPDATE SET
				name = EXCLUDED.name,
				updated_at = NOW()
		`

		authorID := generateUUID()
		if _, err := tx.Exec(ctx, query, authorID, author.Name); err != nil {
			return fmt.Errorf("failed to insert author %s: %w", author.Name, err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	log.Printf("Successfully saved %d authors", len(authors))
	return nil
}

// saveArtists saves artists to database
func (c *Crawler) saveArtists(artists []ExternalArtist) error {
	ctx := context.Background()
	tx, err := c.db.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	for _, artist := range artists {
		query := `
			INSERT INTO "mArtist" (id, name, created_at, updated_at)
			VALUES ($1, $2, NOW(), NOW())
			ON CONFLICT (name) DO UPDATE SET
				name = EXCLUDED.name,
				updated_at = NOW()
		`

		artistID := generateUUID()
		if _, err := tx.Exec(ctx, query, artistID, artist.Name); err != nil {
			return fmt.Errorf("failed to insert artist %s: %w", artist.Name, err)
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	log.Printf("Successfully saved %d artists", len(artists))
	return nil
}

// saveMangaList saves manga list to database with duplicate detection
func (c *Crawler) saveMangaList(mangaList []ExternalManga) error {
	ctx := context.Background()
	tx, err := c.db.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	savedCount := 0
	skippedCount := 0

	for _, manga := range mangaList {
		// Check for potential duplicates
		duplicates, err := c.checkMangaDuplicates(ctx, tx, manga.Title, manga.ID)
		if err != nil {
			log.Printf("Warning: Failed to check duplicates for %s: %v", manga.Title, err)
		}

		if len(duplicates) > 0 {
			// Found potential duplicate
			bestMatch := duplicates[0]
			if bestMatch.SimilarityScore >= 0.9 {
				log.Printf("Skipping duplicate manga: %s (matches existing: %s, score: %.2f)",
					manga.Title, bestMatch.Title, bestMatch.SimilarityScore)

				// Update external_id if not set
				if bestMatch.ExternalID == "" {
					updateQuery := `UPDATE "mKomik" SET external_id = $1, data_source = 'crawled_mapped', updated_at = NOW() WHERE id = $2`
					if _, err := tx.Exec(ctx, updateQuery, manga.ID, bestMatch.ID); err != nil {
						log.Printf("Warning: Failed to update external_id for %s: %v", bestMatch.ID, err)
					} else {
						log.Printf("Updated external_id for existing manga: %s", bestMatch.Title)
					}
				}
				skippedCount++
				continue
			}
		}
		// Convert release year from string to int
		var releaseYear *int
		if manga.ReleaseYear != nil && *manga.ReleaseYear != "" {
			if year, err := strconv.Atoi(*manga.ReleaseYear); err == nil {
				releaseYear = &year
			}
		}

		// Convert status from int to enum string
		var statusStr string
		switch manga.Status {
		case 1:
			statusStr = "On Going"
		case 2:
			statusStr = "End"
		case 3:
			statusStr = "Hiatus"
		case 4:
			statusStr = "Break"
		default:
			statusStr = "On Going" // Default fallback
		}

		// Convert country code to match database enum
		var countryStr string
		switch manga.CountryID {
		case "JP":
			countryStr = "JPN"
		case "KR":
			countryStr = "KR"
		case "CN":
			countryStr = "CN"
		default:
			countryStr = manga.CountryID // Use as-is for others
		}

		// Check if manga with this external_id already exists
		var existingID string
		checkQuery := `SELECT id FROM "mKomik" WHERE external_id = $1`
		err = tx.QueryRow(ctx, checkQuery, manga.ID).Scan(&existingID)

		if err == nil {
			// Manga exists, update it
			updateQuery := `
				UPDATE "mKomik" SET
					title = $2,
					alternative_title = $3,
					description = $4,
					status = $5,
					view_count = $6,
					vote_count = $7,
					bookmark_count = $8,
					cover_image_url = $9,
					rank = $10,
					release_year = $11,
					data_source = $12,
					updated_at = NOW()
				WHERE external_id = $1
			`

			if _, err := tx.Exec(ctx, updateQuery,
				manga.ID, manga.Title, manga.AlternativeTitle, manga.Description,
				statusStr, manga.ViewCount, manga.VoteCount,
				manga.BookmarkCount, manga.CoverImageURL,
				manga.Rank, releaseYear, "crawled",
			); err != nil {
				return fmt.Errorf("failed to update manga %s: %w", manga.ID, err)
			}

			if c.config.Verbose {
				log.Printf("Updated existing manga: %s", manga.Title)
			}
		} else {
			// Manga doesn't exist, insert new
			insertQuery := `
				INSERT INTO "mKomik" (
					id, title, alternative_title, description, status, country_id,
					view_count, vote_count, bookmark_count, cover_image_url,
					created_date, rank, release_year, external_id, data_source
				)
				VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
			`

			newID := generateUUID()
			if _, err := tx.Exec(ctx, insertQuery,
				newID, manga.Title, manga.AlternativeTitle, manga.Description,
				statusStr, countryStr, manga.ViewCount, manga.VoteCount,
				manga.BookmarkCount, manga.CoverImageURL, manga.CreatedAt,
				manga.Rank, releaseYear, manga.ID, "crawled",
			); err != nil {
				return fmt.Errorf("failed to insert manga %s: %w", manga.ID, err)
			}

			existingID = newID
			if c.config.Verbose {
				log.Printf("Inserted new manga: %s", manga.Title)
			}
		}

		savedCount++
		actualID := existingID

		// Save relationships if they exist in the response
		if manga.Taxonomy != nil {
			if len(manga.Taxonomy.Genre) > 0 {
				if err := c.saveMangaGenres(ctx, tx, actualID, manga.Taxonomy.Genre); err != nil {
					return fmt.Errorf("failed to save genres for manga %s: %w", manga.ID, err)
				}
			}

			if len(manga.Taxonomy.Author) > 0 {
				if err := c.saveMangaAuthors(ctx, tx, actualID, manga.Taxonomy.Author); err != nil {
					return fmt.Errorf("failed to save authors for manga %s: %w", manga.ID, err)
				}
			}

			if len(manga.Taxonomy.Artist) > 0 {
				if err := c.saveMangaArtists(ctx, tx, actualID, manga.Taxonomy.Artist); err != nil {
					return fmt.Errorf("failed to save artists for manga %s: %w", manga.ID, err)
				}
			}

			if len(manga.Taxonomy.Format) > 0 {
				if err := c.saveMangaFormats(ctx, tx, actualID, manga.Taxonomy.Format); err != nil {
					return fmt.Errorf("failed to save formats for manga %s: %w", manga.ID, err)
				}
			}
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	log.Printf("Manga processing completed: %d saved, %d skipped (duplicates)", savedCount, skippedCount)
	return nil
}

// Duplicate detection structures
type DuplicateMatch struct {
	ID              string  `db:"id"`
	Title           string  `db:"title"`
	ExternalID      string  `db:"external_id"`
	SimilarityScore float64 `db:"similarity_score"`
}

// checkMangaDuplicates checks for potential duplicate manga
func (c *Crawler) checkMangaDuplicates(ctx context.Context, tx pgx.Tx, title, externalID string) ([]DuplicateMatch, error) {
	query := `
		SELECT
			id,
			title,
			COALESCE(external_id, '') as external_id,
			CASE
				WHEN external_id = $2 AND $2 != '' THEN 1.0
				WHEN LOWER(title) = LOWER($1) THEN 0.9
				WHEN LOWER(title) LIKE '%' || LOWER($1) || '%' THEN 0.7
				WHEN LOWER($1) LIKE '%' || LOWER(title) || '%' THEN 0.7
				ELSE 0.0
			END as similarity_score
		FROM "mKomik"
		WHERE
			(external_id = $2 AND $2 != '')
			OR LOWER(title) LIKE '%' || LOWER($1) || '%'
			OR LOWER($1) LIKE '%' || LOWER(title) || '%'
		ORDER BY similarity_score DESC
		LIMIT 5
	`

	rows, err := tx.Query(ctx, query, title, externalID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var matches []DuplicateMatch
	for rows.Next() {
		var match DuplicateMatch
		if err := rows.Scan(&match.ID, &match.Title, &match.ExternalID, &match.SimilarityScore); err != nil {
			return nil, err
		}
		if match.SimilarityScore > 0.5 { // Only include meaningful matches
			matches = append(matches, match)
		}
	}

	return matches, rows.Err()
}

// Helper functions for manga relationships
func (c *Crawler) saveMangaGenres(ctx context.Context, tx pgx.Tx, mangaID string, genres []ExternalGenre) error {
	// Delete existing relationships
	if _, err := tx.Exec(ctx, `DELETE FROM "trGenre" WHERE id_komik = $1`, mangaID); err != nil {
		return err
	}

	// Insert new relationships
	for _, genre := range genres {
		// Get genre ID by name
		var genreID string
		err := tx.QueryRow(ctx, `SELECT id FROM "mGenre" WHERE name = $1`, genre.Name).Scan(&genreID)
		if err != nil {
			log.Printf("Warning: Genre not found: %s", genre.Name)
			continue
		}

		query := `INSERT INTO "trGenre" (id_komik, id_genre) VALUES ($1, $2) ON CONFLICT DO NOTHING`
		if _, err := tx.Exec(ctx, query, mangaID, genreID); err != nil {
			return err
		}
	}
	return nil
}

func (c *Crawler) saveMangaAuthors(ctx context.Context, tx pgx.Tx, mangaID string, authors []ExternalAuthor) error {
	// Delete existing relationships
	if _, err := tx.Exec(ctx, `DELETE FROM "trAuthor" WHERE id_komik = $1`, mangaID); err != nil {
		return err
	}

	// Insert new relationships
	for _, author := range authors {
		// Get author ID by name
		var authorID string
		err := tx.QueryRow(ctx, `SELECT id FROM "mAuthor" WHERE name = $1`, author.Name).Scan(&authorID)
		if err != nil {
			log.Printf("Warning: Author not found: %s", author.Name)
			continue
		}

		query := `INSERT INTO "trAuthor" (id_komik, id_author) VALUES ($1, $2) ON CONFLICT DO NOTHING`
		if _, err := tx.Exec(ctx, query, mangaID, authorID); err != nil {
			return err
		}
	}
	return nil
}

func (c *Crawler) saveMangaArtists(ctx context.Context, tx pgx.Tx, mangaID string, artists []ExternalArtist) error {
	// Delete existing relationships
	if _, err := tx.Exec(ctx, `DELETE FROM "trArtist" WHERE id_komik = $1`, mangaID); err != nil {
		return err
	}

	// Insert new relationships
	for _, artist := range artists {
		// Get artist ID by name
		var artistID string
		err := tx.QueryRow(ctx, `SELECT id FROM "mArtist" WHERE name = $1`, artist.Name).Scan(&artistID)
		if err != nil {
			log.Printf("Warning: Artist not found: %s", artist.Name)
			continue
		}

		query := `INSERT INTO "trArtist" (id_komik, id_artist) VALUES ($1, $2) ON CONFLICT DO NOTHING`
		if _, err := tx.Exec(ctx, query, mangaID, artistID); err != nil {
			return err
		}
	}
	return nil
}

func (c *Crawler) saveMangaFormats(ctx context.Context, tx pgx.Tx, mangaID string, formats []ExternalFormat) error {
	// Delete existing relationships
	if _, err := tx.Exec(ctx, `DELETE FROM "trFormat" WHERE id_komik = $1`, mangaID); err != nil {
		return err
	}

	// Insert new relationships
	for _, format := range formats {
		// Get format ID by name
		var formatID string
		err := tx.QueryRow(ctx, `SELECT id FROM "mFormat" WHERE name = $1`, format.Name).Scan(&formatID)
		if err != nil {
			log.Printf("Warning: Format not found: %s", format.Name)
			continue
		}

		query := `INSERT INTO "trFormat" (id_komik, id_format) VALUES ($1, $2) ON CONFLICT DO NOTHING`
		if _, err := tx.Exec(ctx, query, mangaID, formatID); err != nil {
			return err
		}
	}
	return nil
}

// saveChaptersList saves chapters to database
func (c *Crawler) saveChaptersList(chapters []ExternalChapter, mangaID string) error {
	ctx := context.Background()
	tx, err := c.db.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	// Get internal manga ID
	var internalMangaID string
	err = tx.QueryRow(ctx, `SELECT id FROM "mKomik" WHERE external_id = $1`, mangaID).Scan(&internalMangaID)
	if err != nil {
		return fmt.Errorf("failed to get internal manga ID for %s: %w", mangaID, err)
	}

	for _, chapter := range chapters {
		// Check if chapter already exists by external_id OR by (id_komik, chapter_number)
		var existingID string
		checkQuery := `
			SELECT id FROM "mChapter"
			WHERE external_id = $1 OR (id_komik = $2 AND chapter_number = $3)
			LIMIT 1
		`
		err := tx.QueryRow(ctx, checkQuery, chapter.ID, internalMangaID, chapter.ChapterNumber).Scan(&existingID)

		if err != nil && err != pgx.ErrNoRows {
			return fmt.Errorf("failed to check existing chapter %s: %w", chapter.ID, err)
		}

		if existingID != "" {
			// Update existing chapter
			updateQuery := `
				UPDATE "mChapter" SET
					chapter_number = $1,
					chapter_title = $2,
					release_date = $3,
					view_count = $4,
					thumbnail_image_url = $5,
					external_id = $6,
					updated_at = NOW()
				WHERE id = $7
			`
			if _, err := tx.Exec(ctx, updateQuery,
				chapter.ChapterNumber, chapter.ChapterTitle, chapter.ReleaseDate,
				chapter.ViewCount, chapter.ThumbnailImageURL, chapter.ID, existingID,
			); err != nil {
				return fmt.Errorf("failed to update chapter %s: %w", chapter.ID, err)
			}
		} else {
			// Insert new chapter
			insertQuery := `
				INSERT INTO "mChapter" (
					id, id_komik, chapter_number, chapter_title, release_date,
					view_count, thumbnail_image_url, created_date, external_id
				)
				VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
			`
			newID := generateUUID()
			if _, err := tx.Exec(ctx, insertQuery,
				newID, internalMangaID, chapter.ChapterNumber, chapter.ChapterTitle,
				chapter.ReleaseDate, chapter.ViewCount, chapter.ThumbnailImageURL,
				chapter.CreatedAt, chapter.ID,
			); err != nil {
				return fmt.Errorf("failed to insert chapter %s: %w", chapter.ID, err)
			}
		}
	}

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	return nil
}

// crawlPagesForChapter crawls and saves pages for a specific chapter
func (c *Crawler) crawlPagesForChapter(chapterID string) error {
	url := fmt.Sprintf("%s/chapter/detail/%s", c.config.BaseURL, chapterID)

	var response struct {
		RetCode int     `json:"retcode"`
		Message string  `json:"message"`
		Meta    APIMeta `json:"meta"`
		Data    ExternalChapterDetail `json:"data"`
	}

	if err := c.fetchJSON(url, &response); err != nil {
		return fmt.Errorf("failed to fetch chapter detail: %w", err)
	}

	if c.config.DryRun {
		log.Printf("DRY RUN: Would save pages for chapter %s", chapterID)
		return nil
	}

	// Save chapter pages data
	return c.saveChapterPages(chapterID, &response.Data)
}

// saveChapterPages saves chapter pages data to trChapter table
func (c *Crawler) saveChapterPages(externalChapterID string, detail *ExternalChapterDetail) error {
	ctx := context.Background()
	tx, err := c.db.Pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("failed to begin transaction: %w", err)
	}
	defer tx.Rollback(ctx)

	// Get internal chapter ID
	var internalChapterID string
	err = tx.QueryRow(ctx, `SELECT id FROM "mChapter" WHERE external_id = $1`, externalChapterID).Scan(&internalChapterID)
	if err != nil {
		return fmt.Errorf("failed to get internal chapter ID for %s: %w", externalChapterID, err)
	}

	log.Printf("Found internal chapter ID %s for external ID %s", internalChapterID, externalChapterID)

	// Delete existing pages for this chapter
	deleteQuery := `DELETE FROM "trChapter" WHERE id_chapter = $1`
	if _, err := tx.Exec(ctx, deleteQuery, internalChapterID); err != nil {
		return fmt.Errorf("failed to delete existing pages: %w", err)
	}

	// Insert each page as separate record in trChapter
	insertQuery := `
		INSERT INTO "trChapter" (
			id, id_chapter, page_number, image_url, image_url_low, created_date
		) VALUES ($1, $2, $3, $4, $5, NOW())
	`

	for i, filename := range detail.Chapter.Data {
		pageID := generateUUID()
		pageNumber := i + 1

		// Construct full image URLs
		imageURL := detail.BaseURL + detail.Chapter.Path + filename
		imageURLLow := detail.BaseURLLow + detail.Chapter.Path + filename

		if _, err := tx.Exec(ctx, insertQuery,
			pageID, internalChapterID, pageNumber, imageURL, imageURLLow,
		); err != nil {
			return fmt.Errorf("failed to insert page %d for chapter %s: %w", pageNumber, externalChapterID, err)
		}
	}

	log.Printf("Inserted %d pages for chapter %s", len(detail.Chapter.Data), externalChapterID)

	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("failed to commit transaction: %w", err)
	}

	return nil
}

// Helper functions to get IDs from database
func (c *Crawler) getAllMangaIDs() ([]string, error) {
	ctx := context.Background()
	rows, err := c.db.Pool.Query(ctx, `SELECT external_id FROM "mKomik" WHERE external_id IS NOT NULL`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}

	return ids, rows.Err()
}

func (c *Crawler) getAllChapterIDs() ([]string, error) {
	ctx := context.Background()
	query := `
		SELECT mc.external_id
		FROM "mChapter" mc
		LEFT JOIN "trChapter" tc ON mc.id = tc.id_chapter
		WHERE mc.external_id IS NOT NULL
		AND tc.id_chapter IS NULL
	`
	rows, err := c.db.Pool.Query(ctx, query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}

	return ids, rows.Err()
}

// Helper function to generate UUID
func generateUUID() string {
	return uuid.New().String()
}
