package services

import (
	"context"
	"time"

	"github.com/sirupsen/logrus"
	"baca-komik-api/database"
	"baca-komik-api/models"
)

// ChapterService provides chapter-related functionality
type ChapterService struct {
	*BaseService
}

// NewChapterService creates a new chapter service
func NewChapterService(db *database.DB) *ChapterService {
	return &ChapterService{
		BaseService: NewBaseService(db),
	}
}

// GetChapterDetails retrieves detailed information about a specific chapter
func (s *ChapterService) GetChapterDetails(id string) (*models.ChapterWithComic, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting chapter details", logrus.Fields{
		"chapter_id": id,
	})

	// Get chapter with comic information - exactly like Next.js (no c.title column)
	query := `
		SELECT
			c.id, c.id_komik, c.chapter_number, c.release_date,
			c.rating, c.view_count, c.vote_count, c.thumbnail_image_url, c.created_date,
			k.id, k.title, k.alternative_title, k.cover_image_url
		FROM "mChapter" c
		JOIN "mKomik" k ON c.id_komik = k.id
		WHERE c.id = $1
	`

	var chapter models.ChapterWithComic
	err := s.GetDB().QueryRow(ctx, query, id).Scan(
		&chapter.ID, &chapter.IDKomik, &chapter.ChapterNumber,
		&chapter.ReleaseDate, &chapter.Rating, &chapter.ViewCount, &chapter.VoteCount,
		&chapter.ThumbnailImageURL, &chapter.CreatedDate,
		&chapter.Comic.ID, &chapter.Comic.Title, &chapter.Comic.AlternativeTitle,
		&chapter.Comic.CoverImageURL,
	)
	if err != nil {
		s.LogError(err, "Failed to get chapter details", logrus.Fields{
			"chapter_id": id,
		})
		return nil, err
	}

	s.LogInfo("Successfully retrieved chapter details", logrus.Fields{
		"chapter_id": id,
		"comic_id":   chapter.IDKomik,
	})

	return &chapter, nil
}

// GetCompleteChapterDetails retrieves complete chapter details with pages, navigation, and user data
func (s *ChapterService) GetCompleteChapterDetails(id string, userID *string) (*models.ChapterComplete, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting complete chapter details", logrus.Fields{
		"chapter_id": id,
		"user_id":    userID,
	})

	// Get chapter details
	chapter, err := s.GetChapterDetails(id)
	if err != nil {
		return nil, err
	}

	result := &models.ChapterComplete{
		Chapter: *chapter,
	}

	// Load pages
	pages, err := s.getChapterPages(ctx, id)
	if err != nil {
		s.LogError(err, "Failed to load chapter pages", logrus.Fields{
			"chapter_id": id,
		})
		return nil, err
	}
	result.Pages = pages

	// Load navigation (next/prev chapters)
	navigation, err := s.getChapterNavigation(ctx, chapter.IDKomik, chapter.ChapterNumber)
	if err != nil {
		s.LogError(err, "Failed to load chapter navigation", logrus.Fields{
			"chapter_id": id,
			"comic_id":   chapter.IDKomik,
		})
		// Don't return error, just log it
	} else {
		result.Navigation = *navigation
	}

	// Load user data if user is authenticated
	if userID != nil {
		userData, err := s.loadUserChapterData(ctx, id, *userID)
		if err != nil {
			s.LogError(err, "Failed to load user chapter data", logrus.Fields{
				"chapter_id": id,
				"user_id":    *userID,
			})
		} else {
			result.UserData = userData
		}
	}

	s.LogInfo("Successfully retrieved complete chapter details", logrus.Fields{
		"chapter_id":  id,
		"pages_count": len(result.Pages),
		"user_id":     userID,
	})

	return result, nil
}

// GetChapterPages retrieves pages for a specific chapter
func (s *ChapterService) GetChapterPages(id string) (*models.ChapterPages, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting chapter pages", logrus.Fields{
		"chapter_id": id,
	})

	// First, verify chapter exists and get basic info
	chapterQuery := `
		SELECT c.id, c.chapter_number, k.id, k.title
		FROM "mChapter" c
		JOIN "mKomik" k ON c.id_komik = k.id
		WHERE c.id = $1
	`

	var chapterBasic models.ChapterBasic
	err := s.GetDB().QueryRow(ctx, chapterQuery, id).Scan(
		&chapterBasic.ID, &chapterBasic.ChapterNumber,
		&chapterBasic.Comic.ID, &chapterBasic.Comic.Title,
	)
	if err != nil {
		s.LogError(err, "Chapter not found", logrus.Fields{
			"chapter_id": id,
		})
		return nil, err
	}

	// Get pages
	pages, err := s.getChapterPages(ctx, id)
	if err != nil {
		return nil, err
	}

	result := &models.ChapterPages{
		Chapter: chapterBasic.Comic, // Note: API documentation shows comic info here
		Pages:   pages,
		Count:   len(pages),
	}

	s.LogInfo("Successfully retrieved chapter pages", logrus.Fields{
		"chapter_id":  id,
		"pages_count": len(pages),
	})

	return result, nil
}

// getChapterPages is a helper function to get pages for a chapter
func (s *ChapterService) getChapterPages(ctx context.Context, chapterID string) ([]models.Page, error) {
	query := `
		SELECT id_chapter, page_number, page_url
		FROM "mPage"
		WHERE id_chapter = $1
		ORDER BY page_number ASC
	`

	rows, err := s.GetDB().Query(ctx, query, chapterID)
	if err != nil {
		s.LogError(err, "Failed to get chapter pages", logrus.Fields{
			"chapter_id": chapterID,
		})
		return nil, err
	}
	defer rows.Close()

	var pages []models.Page
	for rows.Next() {
		var page models.Page
		err := rows.Scan(&page.IDChapter, &page.PageNumber, &page.PageURL)
		if err != nil {
			s.LogError(err, "Failed to scan page row", nil)
			continue
		}
		pages = append(pages, page)
	}

	return pages, nil
}

// getChapterNavigation gets next and previous chapters for navigation
func (s *ChapterService) getChapterNavigation(ctx context.Context, comicID string, currentChapterNumber float64) (*models.Navigation, error) {
	navigation := &models.Navigation{}

	// Get next chapter
	nextQuery := `
		SELECT id, chapter_number
		FROM "mChapter"
		WHERE id_komik = $1 AND chapter_number > $2
		ORDER BY chapter_number ASC
		LIMIT 1
	`

	var nextChapter models.ChapterNav
	err := s.GetDB().QueryRow(ctx, nextQuery, comicID, currentChapterNumber).Scan(
		&nextChapter.ID, &nextChapter.ChapterNumber,
	)
	if err == nil {
		navigation.NextChapter = &nextChapter
	}
	// Ignore error if no next chapter found

	// Get previous chapter
	prevQuery := `
		SELECT id, chapter_number
		FROM "mChapter"
		WHERE id_komik = $1 AND chapter_number < $2
		ORDER BY chapter_number DESC
		LIMIT 1
	`

	var prevChapter models.ChapterNav
	err = s.GetDB().QueryRow(ctx, prevQuery, comicID, currentChapterNumber).Scan(
		&prevChapter.ID, &prevChapter.ChapterNumber,
	)
	if err == nil {
		navigation.PrevChapter = &prevChapter
	}
	// Ignore error if no previous chapter found

	return navigation, nil
}

// loadUserChapterData loads user-specific data for a chapter
func (s *ChapterService) loadUserChapterData(ctx context.Context, chapterID, userID string) (*models.UserData, error) {
	userData := &models.UserData{}

	// Check if chapter is voted
	voteQuery := `
		SELECT EXISTS(
			SELECT 1 FROM "trChapterVote" 
			WHERE id_user = $1 AND id_chapter = $2
		)
	`
	err := s.GetDB().QueryRow(ctx, voteQuery, userID, chapterID).Scan(&userData.IsVoted)
	if err != nil {
		return nil, err
	}

	// Check if chapter is read
	readQuery := `
		SELECT EXISTS(
			SELECT 1 FROM "trUserReadHistory" 
			WHERE id_user = $1 AND id_chapter = $2
		)
	`
	var isRead bool
	err = s.GetDB().QueryRow(ctx, readQuery, userID, chapterID).Scan(&isRead)
	if err == nil {
		userData.IsRead = &isRead
	}
	// Ignore error if no read history table

	return userData, nil
}

// GetAdjacentChapters retrieves adjacent chapters for navigation (used by Flutter app)
func (s *ChapterService) GetAdjacentChapters(chapterID string, limit int) (*models.AdjacentChaptersResponse, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting adjacent chapters", logrus.Fields{
		"chapter_id": chapterID,
		"limit":      limit,
	})

	// First get current chapter info
	currentChapterQuery := `
		SELECT id, id_komik, chapter_number
		FROM "mChapter"
		WHERE id = $1
	`

	var currentChapter struct {
		ID            string
		ComicID       string
		ChapterNumber float64
	}

	err := s.GetDB().QueryRow(ctx, currentChapterQuery, chapterID).Scan(
		&currentChapter.ID, &currentChapter.ComicID, &currentChapter.ChapterNumber,
	)
	if err != nil {
		s.LogError(err, "Current chapter not found", logrus.Fields{
			"chapter_id": chapterID,
		})
		return nil, err
	}

	// Get previous chapters - exactly like Next.js (no title column)
	prevQuery := `
		SELECT id, chapter_number, release_date, thumbnail_image_url, created_date
		FROM "mChapter"
		WHERE id_komik = $1 AND chapter_number < $2
		ORDER BY chapter_number DESC
		LIMIT $3
	`

	prevRows, err := s.GetDB().Query(ctx, prevQuery, currentChapter.ComicID, currentChapter.ChapterNumber, limit)
	if err != nil {
		s.LogError(err, "Failed to get previous chapters", nil)
		return nil, err
	}
	defer prevRows.Close()

	var prevChapters []models.Chapter
	for prevRows.Next() {
		var chapter models.Chapter
		err := prevRows.Scan(
			&chapter.ID, &chapter.ChapterNumber,
			&chapter.ReleaseDate, &chapter.ThumbnailImageURL, &chapter.CreatedDate,
		)
		if err != nil {
			continue
		}
		chapter.IDKomik = currentChapter.ComicID
		prevChapters = append(prevChapters, chapter)
	}

	// Get next chapters - exactly like Next.js (no title column)
	nextQuery := `
		SELECT id, chapter_number, release_date, thumbnail_image_url, created_date
		FROM "mChapter"
		WHERE id_komik = $1 AND chapter_number > $2
		ORDER BY chapter_number ASC
		LIMIT $3
	`

	nextRows, err := s.GetDB().Query(ctx, nextQuery, currentChapter.ComicID, currentChapter.ChapterNumber, limit)
	if err != nil {
		s.LogError(err, "Failed to get next chapters", nil)
		return nil, err
	}
	defer nextRows.Close()

	var nextChapters []models.Chapter
	for nextRows.Next() {
		var chapter models.Chapter
		err := nextRows.Scan(
			&chapter.ID, &chapter.ChapterNumber,
			&chapter.ReleaseDate, &chapter.ThumbnailImageURL, &chapter.CreatedDate,
		)
		if err != nil {
			continue
		}
		chapter.IDKomik = currentChapter.ComicID
		nextChapters = append(nextChapters, chapter)
	}

	response := &models.AdjacentChaptersResponse{
		CurrentChapterID: chapterID,
		PrevChapters:     prevChapters,
		NextChapters:     nextChapters,
	}

	s.LogInfo("Successfully retrieved adjacent chapters", logrus.Fields{
		"chapter_id":      chapterID,
		"prev_count":      len(prevChapters),
		"next_count":      len(nextChapters),
	})

	return response, nil
}
