package services

import (
	"time"

	"github.com/sirupsen/logrus"
	"baca-komik-api/models"
)

// GetRecommendedComics retrieves recommended comics from mRecomed table
func (s *ComicService) GetRecommendedComics(limit int) ([]models.RecommendedComic, int, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting recommended comics", logrus.Fields{
		"limit": limit,
	})

	query := `
		SELECT 
			k.id, k.title, k.alternative_title, k.cover_image_url,
			k.country_id, k.view_count, k.vote_count, k.bookmark_count,
			k.status, k.created_date
		FROM "mRecomed" r
		JOIN "mKomik" k ON r.id_komik = k.id
		ORDER BY k.created_date DESC
		LIMIT $1
	`

	rows, err := s.GetDB().Query(ctx, query, limit)
	if err != nil {
		s.LogError(err, "Failed to execute recommended comics query", nil)
		return nil, 0, err
	}
	defer rows.Close()

	var comics []models.RecommendedComic
	for rows.Next() {
		var comic models.RecommendedComic
		err := rows.Scan(
			&comic.ID, &comic.Title, &comic.AlternativeTitle, &comic.CoverImageURL,
			&comic.CountryID, &comic.ViewCount, &comic.VoteCount, &comic.BookmarkCount,
			&comic.Status, &comic.CreatedDate,
		)
		if err != nil {
			s.LogError(err, "Failed to scan recommended comic row", nil)
			continue
		}
		comics = append(comics, comic)
	}

	s.LogInfo("Successfully retrieved recommended comics", logrus.Fields{
		"count": len(comics),
	})

	return comics, len(comics), nil
}

// GetComicDetails retrieves detailed information about a specific comic
func (s *ComicService) GetComicDetails(id string) (*models.ComicWithDetails, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting comic details", logrus.Fields{
		"comic_id": id,
	})

	// Get basic comic information
	query := `
		SELECT 
			k.id, k.title, k.alternative_title, k.description, k.status,
			k.country_id, k.view_count, k.vote_count, k.bookmark_count,
			k.cover_image_url, k.created_date, k.rank,
			(SELECT COUNT(*) FROM "mChapter" c WHERE c.id_komik = k.id) as chapter_count
		FROM "mKomik" k
		WHERE k.id = $1
	`

	var comic models.ComicWithDetails
	err := s.GetDB().QueryRow(ctx, query, id).Scan(
		&comic.ID, &comic.Title, &comic.AlternativeTitle, &comic.Description,
		&comic.Status, &comic.CountryID, &comic.ViewCount, &comic.VoteCount,
		&comic.BookmarkCount, &comic.CoverImageURL, &comic.CreatedDate,
		&comic.Rank, &comic.ChapterCount,
	)
	if err != nil {
		s.LogError(err, "Failed to get comic details", logrus.Fields{
			"comic_id": id,
		})
		return nil, err
	}

	// Load related data
	comics := []models.ComicWithDetails{comic}
	
	// Load genres
	if err := s.loadComicsGenres(ctx, comics); err != nil {
		s.LogError(err, "Failed to load comic genres", logrus.Fields{
			"comic_id": id,
		})
	}

	// Load authors, artists, formats
	if err := s.loadComicRelations(ctx, &comics[0]); err != nil {
		s.LogError(err, "Failed to load comic relations", logrus.Fields{
			"comic_id": id,
		})
	}

	s.LogInfo("Successfully retrieved comic details", logrus.Fields{
		"comic_id": id,
	})

	return &comics[0], nil
}

// GetCompleteComicDetails retrieves complete comic details with user data
func (s *ComicService) GetCompleteComicDetails(id string, userID *string) (*models.ComicComplete, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting complete comic details", logrus.Fields{
		"comic_id": id,
		"user_id":  userID,
	})

	// Get comic details
	comic, err := s.GetComicDetails(id)
	if err != nil {
		return nil, err
	}

	result := &models.ComicComplete{
		Comic: *comic,
	}

	// Load user data if user is authenticated
	if userID != nil {
		userData, err := s.loadUserComicData(ctx, id, *userID)
		if err != nil {
			s.LogError(err, "Failed to load user comic data", logrus.Fields{
				"comic_id": id,
				"user_id":  *userID,
			})
		} else {
			result.UserData = userData
		}
	}

	s.LogInfo("Successfully retrieved complete comic details", logrus.Fields{
		"comic_id": id,
		"user_id":  userID,
	})

	return result, nil
}

// GetComicChapters retrieves chapters for a specific comic
func (s *ComicService) GetComicChapters(id string, page, limit int, sort, order string) (*models.ChaptersResponse, int, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting comic chapters", logrus.Fields{
		"comic_id": id,
		"page":     page,
		"limit":    limit,
		"sort":     sort,
		"order":    order,
	})

	// First, verify comic exists and get basic info
	comicQuery := `SELECT id, title FROM "mKomik" WHERE id = $1`
	var comic models.ComicBasic
	err := s.GetDB().QueryRow(ctx, comicQuery, id).Scan(&comic.ID, &comic.Title)
	if err != nil {
		s.LogError(err, "Comic not found", logrus.Fields{
			"comic_id": id,
		})
		return nil, 0, err
	}

	// Calculate offset
	offset := (page - 1) * limit

	// Build order clause - exactly like Next.js
	orderClause := "ORDER BY "
	switch sort {
	case "chapter_number":
		orderClause += "c.chapter_number"
	case "release_date":
		orderClause += "c.release_date"
	default:
		orderClause += "c.chapter_number" // default like Next.js
	}

	if order == "asc" {
		orderClause += " ASC"
	} else {
		orderClause += " DESC"
	}

	// Get chapters - exactly like Next.js: SELECT * from mChapter (no title column exists)
	chaptersQuery := `
		SELECT
			c.id, c.id_komik, c.chapter_number, c.release_date,
			c.rating, c.view_count, c.vote_count, c.thumbnail_image_url, c.created_date
		FROM "mChapter" c
		WHERE c.id_komik = $1
		` + orderClause + `
		LIMIT $2 OFFSET $3
	`

	rows, err := s.GetDB().Query(ctx, chaptersQuery, id, limit, offset)
	if err != nil {
		s.LogError(err, "Failed to get comic chapters", logrus.Fields{
			"comic_id": id,
		})
		return nil, 0, err
	}
	defer rows.Close()

	var chapters []models.Chapter
	for rows.Next() {
		var chapter models.Chapter
		err := rows.Scan(
			&chapter.ID, &chapter.IDKomik, &chapter.ChapterNumber,
			&chapter.ReleaseDate, &chapter.Rating, &chapter.ViewCount,
			&chapter.VoteCount, &chapter.ThumbnailImageURL, &chapter.CreatedDate,
		)
		if err != nil {
			s.LogError(err, "Failed to scan chapter row", nil)
			continue
		}
		chapters = append(chapters, chapter)
	}

	// Get total count
	countQuery := `SELECT COUNT(*) FROM "mChapter" WHERE id_komik = $1`
	var total int
	err = s.GetDB().QueryRow(ctx, countQuery, id).Scan(&total)
	if err != nil {
		s.LogError(err, "Failed to get chapters count", logrus.Fields{
			"comic_id": id,
		})
		return nil, 0, err
	}

	response := &models.ChaptersResponse{
		Comic: comic,
		Data:  chapters,
	}

	s.LogInfo("Successfully retrieved comic chapters", logrus.Fields{
		"comic_id":      id,
		"chapters_count": len(chapters),
		"total":         total,
	})

	return response, total, nil
}
