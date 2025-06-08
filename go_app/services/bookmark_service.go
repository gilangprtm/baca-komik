package services

import (
	"time"

	"github.com/sirupsen/logrus"
	"baca-komik-api/database"
	"baca-komik-api/models"
)

// BookmarkService provides bookmark-related functionality
type BookmarkService struct {
	*BaseService
}

// NewBookmarkService creates a new bookmark service
func NewBookmarkService(db *database.DB) *BookmarkService {
	return &BookmarkService{
		BaseService: NewBaseService(db),
	}
}

// GetUserBookmarks retrieves user bookmarks with pagination
func (s *BookmarkService) GetUserBookmarks(userID string, page, limit int) ([]models.BookmarkWithComic, int, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting user bookmarks", logrus.Fields{
		"user_id": userID,
		"page":    page,
		"limit":   limit,
	})

	// Calculate offset
	offset := (page - 1) * limit

	// Get bookmarks with comic information
	query := `
		SELECT 
			b.id_user, b.id_komik, b.created_at,
			k.id, k.title, k.cover_image_url, k.alternative_title,
			k.description, k.rank, k.status, k.country_id
		FROM "trUserBookmark" b
		JOIN "mKomik" k ON b.id_komik = k.id
		WHERE b.id_user = $1
		ORDER BY b.created_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := s.GetDB().Query(ctx, query, userID, limit, offset)
	if err != nil {
		s.LogError(err, "Failed to get user bookmarks", logrus.Fields{
			"user_id": userID,
		})
		return nil, 0, err
	}
	defer rows.Close()

	var bookmarks []models.BookmarkWithComic
	for rows.Next() {
		var bookmark models.BookmarkWithComic
		err := rows.Scan(
			&bookmark.IDUser, &bookmark.IDKomik, &bookmark.CreatedAt,
			&bookmark.Comic.ID, &bookmark.Comic.Title, &bookmark.Comic.CoverImageURL,
			&bookmark.Comic.AlternativeTitle, &bookmark.Comic.Description,
			&bookmark.Comic.Rank, &bookmark.Comic.Status, &bookmark.Comic.CountryID,
		)
		if err != nil {
			s.LogError(err, "Failed to scan bookmark row", nil)
			continue
		}
		bookmarks = append(bookmarks, bookmark)
	}

	// Get total count
	countQuery := `SELECT COUNT(*) FROM "trUserBookmark" WHERE id_user = $1`
	var total int
	err = s.GetDB().QueryRow(ctx, countQuery, userID).Scan(&total)
	if err != nil {
		s.LogError(err, "Failed to get bookmarks count", logrus.Fields{
			"user_id": userID,
		})
		return nil, 0, err
	}

	s.LogInfo("Successfully retrieved user bookmarks", logrus.Fields{
		"user_id": userID,
		"count":   len(bookmarks),
		"total":   total,
	})

	return bookmarks, total, nil
}

// GetDetailedBookmarks retrieves bookmarks with comic details and latest chapter
func (s *BookmarkService) GetDetailedBookmarks(userID string, page, limit int) ([]models.BookmarkDetails, int, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting detailed bookmarks", logrus.Fields{
		"user_id": userID,
		"page":    page,
		"limit":   limit,
	})

	// Calculate offset
	offset := (page - 1) * limit

	// Get bookmarks with comic details and latest chapter
	query := `
		SELECT 
			b.id_user || '-' || b.id_komik as bookmark_id,
			k.id, k.title, k.alternative_title, k.description, k.status,
			k.country_id, k.view_count, k.vote_count, k.bookmark_count,
			k.cover_image_url, k.created_date,
			lc.id, lc.chapter_number, lc.title, lc.release_date
		FROM "trUserBookmark" b
		JOIN "mKomik" k ON b.id_komik = k.id
		LEFT JOIN LATERAL (
			SELECT id, chapter_number, title, release_date
			FROM "mChapter" c
			WHERE c.id_komik = k.id
			ORDER BY c.release_date DESC, c.chapter_number DESC
			LIMIT 1
		) lc ON true
		WHERE b.id_user = $1
		ORDER BY b.created_at DESC
		LIMIT $2 OFFSET $3
	`

	rows, err := s.GetDB().Query(ctx, query, userID, limit, offset)
	if err != nil {
		s.LogError(err, "Failed to get detailed bookmarks", logrus.Fields{
			"user_id": userID,
		})
		return nil, 0, err
	}
	defer rows.Close()

	var bookmarks []models.BookmarkDetails
	for rows.Next() {
		var bookmark models.BookmarkDetails
		var latestChapter models.Chapter
		var hasLatestChapter bool

		err := rows.Scan(
			&bookmark.BookmarkID,
			&bookmark.Comic.ID, &bookmark.Comic.Title, &bookmark.Comic.AlternativeTitle,
			&bookmark.Comic.Description, &bookmark.Comic.Status, &bookmark.Comic.CountryID,
			&bookmark.Comic.ViewCount, &bookmark.Comic.VoteCount, &bookmark.Comic.BookmarkCount,
			&bookmark.Comic.CoverImageURL, &bookmark.Comic.CreatedDate,
			&latestChapter.ID, &latestChapter.ChapterNumber, &latestChapter.Title, &latestChapter.ReleaseDate,
		)
		if err != nil {
			s.LogError(err, "Failed to scan detailed bookmark row", nil)
			continue
		}

		// Check if latest chapter exists
		if latestChapter.ID != "" {
			hasLatestChapter = true
			bookmark.Comic.LatestChapter = &latestChapter
		}

		if hasLatestChapter {
			bookmarks = append(bookmarks, bookmark)
		}
	}

	// Get total count
	countQuery := `SELECT COUNT(*) FROM "trUserBookmark" WHERE id_user = $1`
	var total int
	err = s.GetDB().QueryRow(ctx, countQuery, userID).Scan(&total)
	if err != nil {
		s.LogError(err, "Failed to get detailed bookmarks count", logrus.Fields{
			"user_id": userID,
		})
		return nil, 0, err
	}

	s.LogInfo("Successfully retrieved detailed bookmarks", logrus.Fields{
		"user_id": userID,
		"count":   len(bookmarks),
		"total":   total,
	})

	return bookmarks, total, nil
}

// AddBookmark adds a comic to user bookmarks
func (s *BookmarkService) AddBookmark(userID, comicID string) (*models.Bookmark, error) {
	ctx, cancel := s.WithTimeout(10 * time.Second)
	defer cancel()

	s.LogInfo("Adding bookmark", logrus.Fields{
		"user_id":  userID,
		"comic_id": comicID,
	})

	// Check if comic exists
	var exists bool
	checkQuery := `SELECT EXISTS(SELECT 1 FROM "mKomik" WHERE id = $1)`
	err := s.GetDB().QueryRow(ctx, checkQuery, comicID).Scan(&exists)
	if err != nil {
		s.LogError(err, "Failed to check comic existence", logrus.Fields{
			"comic_id": comicID,
		})
		return nil, err
	}

	if !exists {
		s.LogError(nil, "Comic not found", logrus.Fields{
			"comic_id": comicID,
		})
		return nil, err
	}

	// Check if bookmark already exists
	checkBookmarkQuery := `SELECT EXISTS(SELECT 1 FROM "trUserBookmark" WHERE id_user = $1 AND id_komik = $2)`
	err = s.GetDB().QueryRow(ctx, checkBookmarkQuery, userID, comicID).Scan(&exists)
	if err != nil {
		s.LogError(err, "Failed to check bookmark existence", nil)
		return nil, err
	}

	if exists {
		s.LogError(nil, "Bookmark already exists", logrus.Fields{
			"user_id":  userID,
			"comic_id": comicID,
		})
		return nil, err
	}

	// Insert bookmark
	insertQuery := `
		INSERT INTO "trUserBookmark" (id_user, id_komik, created_at)
		VALUES ($1, $2, NOW())
		RETURNING id_user, id_komik, created_at
	`

	var bookmark models.Bookmark
	err = s.GetDB().QueryRow(ctx, insertQuery, userID, comicID).Scan(
		&bookmark.IDUser, &bookmark.IDKomik, &bookmark.CreatedAt,
	)
	if err != nil {
		s.LogError(err, "Failed to insert bookmark", logrus.Fields{
			"user_id":  userID,
			"comic_id": comicID,
		})
		return nil, err
	}

	s.LogInfo("Successfully added bookmark", logrus.Fields{
		"user_id":  userID,
		"comic_id": comicID,
	})

	return &bookmark, nil
}

// RemoveBookmark removes a comic from user bookmarks
func (s *BookmarkService) RemoveBookmark(userID, comicID string) error {
	ctx, cancel := s.WithTimeout(10 * time.Second)
	defer cancel()

	s.LogInfo("Removing bookmark", logrus.Fields{
		"user_id":  userID,
		"comic_id": comicID,
	})

	// Delete bookmark
	deleteQuery := `DELETE FROM "trUserBookmark" WHERE id_user = $1 AND id_komik = $2`
	result, err := s.GetDB().Exec(ctx, deleteQuery, userID, comicID)
	if err != nil {
		s.LogError(err, "Failed to delete bookmark", logrus.Fields{
			"user_id":  userID,
			"comic_id": comicID,
		})
		return err
	}

	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		s.LogError(nil, "Bookmark not found", logrus.Fields{
			"user_id":  userID,
			"comic_id": comicID,
		})
		return err
	}

	s.LogInfo("Successfully removed bookmark", logrus.Fields{
		"user_id":  userID,
		"comic_id": comicID,
	})

	return nil
}
