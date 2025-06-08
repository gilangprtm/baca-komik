package services

import (
	"context"
	"fmt"
	"strings"
	"time"

	"github.com/sirupsen/logrus"
	"baca-komik-api/database"
	"baca-komik-api/models"
)

// ComicService provides comic-related functionality
type ComicService struct {
	*BaseService
}

// NewComicService creates a new comic service
func NewComicService(db *database.DB) *ComicService {
	return &ComicService{
		BaseService: NewBaseService(db),
	}
}

// GetComics retrieves comics with pagination and filtering
func (s *ComicService) GetComics(page, limit int, search, genre, country, sort, order string) ([]models.ComicWithDetails, int, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting comics", logrus.Fields{
		"page":    page,
		"limit":   limit,
		"search":  search,
		"genre":   genre,
		"country": country,
		"sort":    sort,
		"order":   order,
	})

	// Calculate offset
	offset := (page - 1) * limit

	// Build base query - exactly like Next.js: SELECT *, mChapter count, trGenre
	baseQuery := `
		SELECT DISTINCT
			k.id, k.title, k.alternative_title, k.description, k.status,
			k.country_id, k.view_count, k.vote_count, k.bookmark_count,
			k.cover_image_url, k.created_date, k.rank, k.release_year,
			(SELECT COUNT(*) FROM "mChapter" c WHERE c.id_komik = k.id) as chapter_count
		FROM "mKomik" k
	`

	// Build WHERE conditions
	var conditions []string
	var args []interface{}
	argIndex := 1

	// Search condition - exactly like Next.js: title.ilike OR alternative_title.ilike
	if search != "" {
		conditions = append(conditions, fmt.Sprintf("(k.title ILIKE $%d OR k.alternative_title ILIKE $%d)", argIndex, argIndex+1))
		searchPattern := "%" + search + "%"
		args = append(args, searchPattern, searchPattern)
		argIndex += 2
	}

	// Genre filter
	if genre != "" {
		conditions = append(conditions, fmt.Sprintf(`EXISTS (
			SELECT 1 FROM "trGenre" tg 
			WHERE tg.id_komik = k.id AND tg.id_genre = $%d
		)`, argIndex))
		args = append(args, genre)
		argIndex++
	}

	// Country filter
	if country != "" {
		conditions = append(conditions, fmt.Sprintf("k.country_id = $%d", argIndex))
		args = append(args, country)
		argIndex++
	}

	// Add WHERE clause if conditions exist
	if len(conditions) > 0 {
		baseQuery += " WHERE " + strings.Join(conditions, " AND ")
	}

	// Add ORDER BY
	orderClause := "ORDER BY "
	switch sort {
	case "title":
		orderClause += "k.title"
	case "created_date":
		orderClause += "k.created_date"
	case "updated_date":
		orderClause += "k.created_date" // fallback to created_date since updated_date doesn't exist
	case "view_count":
		orderClause += "k.view_count"
	case "vote_count":
		orderClause += "k.vote_count"
	case "bookmark_count":
		orderClause += "k.bookmark_count"
	case "rank":
		orderClause += "k.rank"
	default:
		orderClause += "k.rank"
	}

	if strings.ToLower(order) == "asc" {
		orderClause += " ASC"
	} else {
		orderClause += " DESC"
	}

	// Add LIMIT and OFFSET
	limitClause := fmt.Sprintf(" %s LIMIT $%d OFFSET $%d", orderClause, argIndex, argIndex+1)
	args = append(args, limit, offset)

	// Execute main query
	query := baseQuery + limitClause
	rows, err := s.GetDB().Query(ctx, query, args...)
	if err != nil {
		s.LogError(err, "Failed to execute comics query", logrus.Fields{
			"query": query,
			"args":  args,
		})
		return nil, 0, err
	}
	defer rows.Close()

	var comics []models.ComicWithDetails
	for rows.Next() {
		var comic models.ComicWithDetails
		err := rows.Scan(
			&comic.ID, &comic.Title, &comic.AlternativeTitle, &comic.Description,
			&comic.Status, &comic.CountryID, &comic.ViewCount, &comic.VoteCount,
			&comic.BookmarkCount, &comic.CoverImageURL, &comic.CreatedDate,
			&comic.Rank, &comic.ReleaseYear, &comic.ChapterCount,
		)
		if err != nil {
			s.LogError(err, "Failed to scan comic row", nil)
			continue
		}
		comics = append(comics, comic)
	}

	// Get total count for pagination
	countQuery := strings.Replace(baseQuery, `SELECT DISTINCT
			k.id, k.title, k.alternative_title, k.description, k.status,
			k.country_id, k.view_count, k.vote_count, k.bookmark_count,
			k.cover_image_url, k.created_date, k.rank, k.release_year,
			(SELECT COUNT(*) FROM "mChapter" c WHERE c.id_komik = k.id) as chapter_count`, "SELECT COUNT(DISTINCT k.id)", 1)

	var total int
	countArgs := args[:len(args)-2] // Remove LIMIT and OFFSET args
	err = s.GetDB().QueryRow(ctx, countQuery, countArgs...).Scan(&total)
	if err != nil {
		s.LogError(err, "Failed to get comics count", logrus.Fields{
			"query": countQuery,
			"args":  countArgs,
		})
		return nil, 0, err
	}

	// Load genres for each comic
	if err := s.loadComicsGenres(ctx, comics); err != nil {
		s.LogError(err, "Failed to load comics genres", nil)
		// Don't return error, just log it
	}

	s.LogInfo("Successfully retrieved comics", logrus.Fields{
		"count": len(comics),
		"total": total,
	})

	return comics, total, nil
}

// loadComicsGenres loads genres for multiple comics
func (s *ComicService) loadComicsGenres(ctx context.Context, comics []models.ComicWithDetails) error {
	if len(comics) == 0 {
		return nil
	}

	// Get all comic IDs
	var comicIDs []string
	for _, comic := range comics {
		comicIDs = append(comicIDs, comic.ID)
	}

	// Build query to get all genres for these comics
	query := `
		SELECT tg.id_komik, g.id, g.name
		FROM "trGenre" tg
		JOIN "mGenre" g ON tg.id_genre = g.id
		WHERE tg.id_komik = ANY($1)
		ORDER BY tg.id_komik, g.name
	`

	rows, err := s.GetDB().Query(ctx, query, comicIDs)
	if err != nil {
		return err
	}
	defer rows.Close()

	// Group genres by comic ID
	genreMap := make(map[string][]models.Genre)
	for rows.Next() {
		var comicID string
		var genre models.Genre
		if err := rows.Scan(&comicID, &genre.ID, &genre.Name); err != nil {
			continue
		}
		genreMap[comicID] = append(genreMap[comicID], genre)
	}

	// Assign genres to comics
	for i := range comics {
		comics[i].Genres = genreMap[comics[i].ID]
	}

	return nil
}

// GetHomeComics retrieves comics for home page with latest chapters
func (s *ComicService) GetHomeComics(page, limit int, sort, order string) ([]models.ComicWithDetails, int, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting home comics", logrus.Fields{
		"page":  page,
		"limit": limit,
		"sort":  sort,
		"order": order,
	})

	// Calculate offset
	offset := (page - 1) * limit

	// Query for home comics - exactly like Next.js: order by created_date, then sort by latest chapters
	query := `
		SELECT
			k.id, k.title, k.alternative_title, k.description, k.status,
			k.country_id, k.view_count, k.vote_count, k.bookmark_count,
			k.cover_image_url, k.created_date, k.rank, k.release_year,
			(SELECT COUNT(*) FROM "mChapter" c WHERE c.id_komik = k.id) as chapter_count
		FROM "mKomik" k
		ORDER BY k.created_date DESC
		LIMIT $1 OFFSET $2
	`

	rows, err := s.GetDB().Query(ctx, query, limit, offset)
	if err != nil {
		s.LogError(err, "Failed to execute home comics query", nil)
		return nil, 0, err
	}
	defer rows.Close()

	var comics []models.ComicWithDetails
	for rows.Next() {
		var comic models.ComicWithDetails
		err := rows.Scan(
			&comic.ID, &comic.Title, &comic.AlternativeTitle, &comic.Description,
			&comic.Status, &comic.CountryID, &comic.ViewCount, &comic.VoteCount,
			&comic.BookmarkCount, &comic.CoverImageURL, &comic.CreatedDate,
			&comic.Rank, &comic.ReleaseYear, &comic.ChapterCount,
		)
		if err != nil {
			s.LogError(err, "Failed to scan home comic row", nil)
			continue
		}
		comics = append(comics, comic)
	}

	// Get total count
	countQuery := `SELECT COUNT(*) FROM "mKomik"`

	var total int
	err = s.GetDB().QueryRow(ctx, countQuery).Scan(&total)
	if err != nil {
		s.LogError(err, "Failed to get home comics count", nil)
		return nil, 0, err
	}

	// Load latest chapters for each comic
	if err := s.loadLatestChapters(ctx, comics); err != nil {
		s.LogError(err, "Failed to load latest chapters", nil)
	}

	// Load genres for each comic
	if err := s.loadComicsGenres(ctx, comics); err != nil {
		s.LogError(err, "Failed to load comics genres", nil)
	}

	s.LogInfo("Successfully retrieved home comics", logrus.Fields{
		"count": len(comics),
		"total": total,
	})

	return comics, total, nil
}

// loadLatestChapters loads latest chapters for multiple comics
func (s *ComicService) loadLatestChapters(ctx context.Context, comics []models.ComicWithDetails) error {
	if len(comics) == 0 {
		return nil
	}

	// Get all comic IDs
	var comicIDs []string
	for _, comic := range comics {
		comicIDs = append(comicIDs, comic.ID)
	}

	// Query to get latest chapters for each comic - exactly like Next.js (no title column)
	query := `
		SELECT DISTINCT ON (c.id_komik)
			c.id_komik, c.id, c.chapter_number, c.release_date, c.thumbnail_image_url, c.created_date
		FROM "mChapter" c
		WHERE c.id_komik = ANY($1)
		ORDER BY c.id_komik, c.release_date DESC, c.chapter_number DESC
	`

	rows, err := s.GetDB().Query(ctx, query, comicIDs)
	if err != nil {
		return err
	}
	defer rows.Close()

	// Group chapters by comic ID
	chapterMap := make(map[string][]models.Chapter)
	for rows.Next() {
		var comicID string
		var chapter models.Chapter
		if err := rows.Scan(&comicID, &chapter.ID, &chapter.ChapterNumber, &chapter.ReleaseDate, &chapter.ThumbnailImageURL, &chapter.CreatedDate); err != nil {
			continue
		}
		chapter.IDKomik = comicID
		chapterMap[comicID] = append(chapterMap[comicID], chapter)
	}

	// Assign latest chapters to comics
	for i := range comics {
		comics[i].LatestChapters = chapterMap[comics[i].ID]
	}

	return nil
}

// GetPopularComics retrieves popular comics from mPopular table (matching Next.js API)
func (s *ComicService) GetPopularComics(typeParam string, limit int) ([]models.PopularComic, int, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting popular comics", logrus.Fields{
		"type":  typeParam,
		"limit": limit,
	})

	// Query yang sama persis dengan Next.js API
	query := `
		SELECT
			k.id, k.title, k.alternative_title, k.cover_image_url,
			k.country_id, k.view_count, k.vote_count, k.bookmark_count,
			k.status, k.created_date, p.type
		FROM "mPopular" p
		JOIN "mKomik" k ON p.id_komik = k.id
		WHERE p.type = $1
		LIMIT $2
	`

	rows, err := s.GetDB().Query(ctx, query, typeParam, limit)
	if err != nil {
		s.LogError(err, "Failed to execute popular comics query", nil)
		return nil, 0, err
	}
	defer rows.Close()

	var comics []models.PopularComic
	for rows.Next() {
		var comic models.PopularComic
		err := rows.Scan(
			&comic.ID, &comic.Title, &comic.AlternativeTitle, &comic.CoverImageURL,
			&comic.CountryID, &comic.ViewCount, &comic.VoteCount, &comic.BookmarkCount,
			&comic.Status, &comic.CreatedDate, &comic.Type,
		)
		if err != nil {
			s.LogError(err, "Failed to scan popular comic row", nil)
			continue
		}
		comics = append(comics, comic)
	}

	s.LogInfo("Successfully retrieved popular comics", logrus.Fields{
		"count": len(comics),
		"type":  typeParam,
	})

	return comics, len(comics), nil
}
