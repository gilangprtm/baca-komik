package services

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
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

// GetChapterDetails - EXACT COPY from Next.js /api/chapters/[id]/route.ts
func (s *ChapterService) GetChapterDetails(id string) (*models.ChapterDetailsResponse, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting chapter details", logrus.Fields{
		"chapter_id": id,
	})

	// Fetch chapter with comic information - EXACTLY like Next.js lines 23-37
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
		if err == pgx.ErrNoRows {
			return nil, fmt.Errorf("chapter not found")
		}
		s.LogError(err, "Failed to get chapter details", logrus.Fields{
			"chapter_id": id,
		})
		return nil, err
	}

	// Increment view count - EXACTLY like Next.js line 54
	_, err = s.GetDB().Exec(ctx, `SELECT increment_chapter_view_count($1)`, id)
	if err != nil {
		s.LogError(err, "Failed to increment view count", nil)
		// Continue even if increment fails
	}

	// Fetch next and previous chapters for navigation - EXACTLY like Next.js lines 56-88
	var prevChapter *models.ChapterNav
	var nextChapter *models.ChapterNav

	// Get previous chapter - EXACTLY like Next.js lines 60-73
	prevQuery := `
		SELECT id, chapter_number
		FROM "mChapter"
		WHERE id_komik = $1 AND chapter_number < $2
		ORDER BY chapter_number DESC
		LIMIT 1
	`
	var prev models.ChapterNav
	err = s.GetDB().QueryRow(ctx, prevQuery, chapter.IDKomik, chapter.ChapterNumber).Scan(
		&prev.ID, &prev.ChapterNumber,
	)
	if err == nil {
		prevChapter = &prev
	}

	// Get next chapter - EXACTLY like Next.js lines 75-88
	nextQuery := `
		SELECT id, chapter_number
		FROM "mChapter"
		WHERE id_komik = $1 AND chapter_number > $2
		ORDER BY chapter_number ASC
		LIMIT 1
	`
	var next models.ChapterNav
	err = s.GetDB().QueryRow(ctx, nextQuery, chapter.IDKomik, chapter.ChapterNumber).Scan(
		&next.ID, &next.ChapterNumber,
	)
	if err == nil {
		nextChapter = &next
	}

	// Format response - EXACTLY like Next.js lines 90-98
	result := &models.ChapterDetailsResponse{
		ID:                chapter.ID,
		IDKomik:           chapter.IDKomik,
		ChapterNumber:     chapter.ChapterNumber,
		ReleaseDate:       chapter.ReleaseDate,
		Rating:            chapter.Rating,
		ViewCount:         chapter.ViewCount,
		VoteCount:         chapter.VoteCount,
		ThumbnailImageURL: chapter.ThumbnailImageURL,
		CreatedDate:       chapter.CreatedDate,
		Comic:             chapter.Comic,
		NextChapter:       nextChapter,
		PrevChapter:       prevChapter,
	}

	s.LogInfo("Successfully retrieved chapter details", logrus.Fields{
		"chapter_id": id,
		"comic_id":   chapter.IDKomik,
	})

	return result, nil
}

// GetCompleteChapterDetails - EXACT COPY from Next.js /api/chapters/[id]/complete/route.ts
func (s *ChapterService) GetCompleteChapterDetails(id string, userID *string) (*models.ChapterCompleteResponse, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting complete chapter details", logrus.Fields{
		"chapter_id": id,
		"user_id":    userID,
	})

	// Fetch chapter with comic information - EXACTLY like Next.js lines 28-42
	chapterQuery := `
		SELECT
			c.id, c.id_komik, c.chapter_number, c.release_date,
			c.rating, c.view_count, c.vote_count, c.thumbnail_image_url, c.created_date,
			k.id, k.title, k.alternative_title, k.cover_image_url
		FROM "mChapter" c
		JOIN "mKomik" k ON c.id_komik = k.id
		WHERE c.id = $1
	`

	var chapterData models.ChapterWithComic
	err := s.GetDB().QueryRow(ctx, chapterQuery, id).Scan(
		&chapterData.ID, &chapterData.IDKomik, &chapterData.ChapterNumber,
		&chapterData.ReleaseDate, &chapterData.Rating, &chapterData.ViewCount,
		&chapterData.VoteCount, &chapterData.ThumbnailImageURL, &chapterData.CreatedDate,
		&chapterData.Comic.ID, &chapterData.Comic.Title,
		&chapterData.Comic.AlternativeTitle, &chapterData.Comic.CoverImageURL,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, fmt.Errorf("chapter not found")
		}
		s.LogError(err, "Failed to fetch chapter", logrus.Fields{
			"chapter_id": id,
		})
		return nil, err
	}

	// Fetch pages for the chapter - EXACTLY like Next.js lines 58-63
	pagesQuery := `
		SELECT id_chapter, page_number, page_url
		FROM "trChapter"
		WHERE id_chapter = $1
		ORDER BY page_number ASC
	`

	pagesRows, err := s.GetDB().Query(ctx, pagesQuery, id)
	if err != nil {
		s.LogError(err, "Failed to fetch pages", logrus.Fields{
			"chapter_id": id,
		})
		return nil, err
	}
	defer pagesRows.Close()

	var pagesData []models.ChapterPage
	for pagesRows.Next() {
		var page models.ChapterPage
		err := pagesRows.Scan(&page.IDChapter, &page.PageNumber, &page.PageURL)
		if err != nil {
			continue
		}
		pagesData = append(pagesData, page)
	}

	// Fetch next and previous chapters for navigation - EXACTLY like Next.js lines 69-101
	var prevChapter *models.ChapterNav
	var nextChapter *models.ChapterNav

	// Get previous chapter - EXACTLY like Next.js lines 74-86
	prevQuery := `
		SELECT id, chapter_number
		FROM "mChapter"
		WHERE id_komik = $1 AND chapter_number < $2
		ORDER BY chapter_number DESC
		LIMIT 1
	`
	var prev models.ChapterNav
	err = s.GetDB().QueryRow(ctx, prevQuery, chapterData.IDKomik, chapterData.ChapterNumber).Scan(
		&prev.ID, &prev.ChapterNumber,
	)
	if err == nil {
		prevChapter = &prev
	}

	// Get next chapter - EXACTLY like Next.js lines 88-100
	nextQuery := `
		SELECT id, chapter_number
		FROM "mChapter"
		WHERE id_komik = $1 AND chapter_number > $2
		ORDER BY chapter_number ASC
		LIMIT 1
	`
	var next models.ChapterNav
	err = s.GetDB().QueryRow(ctx, nextQuery, chapterData.IDKomik, chapterData.ChapterNumber).Scan(
		&next.ID, &next.ChapterNumber,
	)
	if err == nil {
		nextChapter = &next
	}

	// Initialize user data - EXACTLY like Next.js lines 103-107
	userData := models.ChapterUserData{
		IsVoted: false,
		IsRead:  false,
	}

	// If user is authenticated, fetch user-specific data - EXACTLY like Next.js lines 109-152
	if userID != nil {
		// Check if chapter is voted - EXACTLY like Next.js lines 111-117
		var voteExists bool
		voteQuery := `SELECT EXISTS(SELECT 1 FROM "trChapterVote" WHERE id_user = $1 AND id_chapter = $2)`
		err = s.GetDB().QueryRow(ctx, voteQuery, *userID, id).Scan(&voteExists)
		if err != nil {
			s.LogError(err, "Failed to check vote", nil)
		}

		// Check if chapter is marked as read - EXACTLY like Next.js lines 119-125
		var isRead bool
		readQuery := `SELECT COALESCE(is_read, false) FROM "trUserHistory" WHERE id_user = $1 AND id_chapter = $2`
		err = s.GetDB().QueryRow(ctx, readQuery, *userID, id).Scan(&isRead)
		if err != nil && err != pgx.ErrNoRows {
			s.LogError(err, "Failed to check read status", nil)
		}

		userData = models.ChapterUserData{
			IsVoted: voteExists,
			IsRead:  isRead,
		}

		// Update reading history - EXACTLY like Next.js lines 132-151
		var existingHistory bool
		historyCheckQuery := `SELECT EXISTS(SELECT 1 FROM "trUserHistory" WHERE id_user = $1 AND id_chapter = $2)`
		err = s.GetDB().QueryRow(ctx, historyCheckQuery, *userID, id).Scan(&existingHistory)
		if err != nil {
			s.LogError(err, "Failed to check history", nil)
		}

		if !existingHistory {
			// Create new reading history - EXACTLY like Next.js lines 143-149
			insertHistoryQuery := `
				INSERT INTO "trUserHistory" (id_user, id_komik, id_chapter, is_read, created_date)
				VALUES ($1, $2, $3, false, NOW())
			`
			_, err = s.GetDB().Exec(ctx, insertHistoryQuery, *userID, chapterData.IDKomik, id)
			if err != nil {
				s.LogError(err, "Failed to create reading history", nil)
			}
		}
	}

	// Increment view count - EXACTLY like Next.js line 155
	_, err = s.GetDB().Exec(ctx, `SELECT increment_chapter_view_count($1)`, id)
	if err != nil {
		s.LogError(err, "Failed to increment view count", nil)
		// Continue even if increment fails
	}

	// Format response - EXACTLY like Next.js lines 158-172
	result := &models.ChapterCompleteResponse{
		Chapter: chapterData,
		Pages:   pagesData,
		Navigation: models.ChapterNavigation{
			PrevChapter: prevChapter,
			NextChapter: nextChapter,
		},
		UserData: userData,
	}

	s.LogInfo("Successfully retrieved complete chapter details", logrus.Fields{
		"chapter_id":  id,
		"pages_count": len(pagesData),
		"user_id":     userID,
	})

	return result, nil
}

// GetChapterPages - EXACT COPY from Next.js /api/chapters/[id]/pages/route.ts
func (s *ChapterService) GetChapterPages(id string) (*models.ChapterPagesResponse, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting chapter pages", logrus.Fields{
		"chapter_id": id,
	})

	// First, verify that the chapter exists - EXACTLY like Next.js lines 23-27
	chapterQuery := `
		SELECT id, chapter_number, id_komik
		FROM "mChapter"
		WHERE id = $1
	`

	var chapter models.ChapterBasicInfo
	err := s.GetDB().QueryRow(ctx, chapterQuery, id).Scan(
		&chapter.ID, &chapter.ChapterNumber, &chapter.IDKomik,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, fmt.Errorf("chapter not found")
		}
		s.LogError(err, "Failed to get chapter", logrus.Fields{
			"chapter_id": id,
		})
		return nil, err
	}

	// Fetch pages for the chapter, sorted by page number - EXACTLY like Next.js lines 43-47
	pagesQuery := `
		SELECT id_chapter, page_number, page_url
		FROM "trChapter"
		WHERE id_chapter = $1
		ORDER BY page_number ASC
	`

	pagesRows, err := s.GetDB().Query(ctx, pagesQuery, id)
	if err != nil {
		s.LogError(err, "Failed to get chapter pages", logrus.Fields{
			"chapter_id": id,
		})
		return nil, err
	}
	defer pagesRows.Close()

	var pages []models.ChapterPage
	for pagesRows.Next() {
		var page models.ChapterPage
		err := pagesRows.Scan(&page.IDChapter, &page.PageNumber, &page.PageURL)
		if err != nil {
			s.LogError(err, "Failed to scan page row", nil)
			continue
		}
		pages = append(pages, page)
	}

	// Fetch comic information - EXACTLY like Next.js lines 54-58
	comicQuery := `
		SELECT id, title
		FROM "mKomik"
		WHERE id = $1
	`

	var comic models.ComicBasic
	err = s.GetDB().QueryRow(ctx, comicQuery, chapter.IDKomik).Scan(
		&comic.ID, &comic.Title,
	)
	if err != nil {
		s.LogError(err, "Failed to get comic", logrus.Fields{
			"comic_id": chapter.IDKomik,
		})
		return nil, err
	}

	// Return response - EXACTLY like Next.js lines 64-72
	result := &models.ChapterPagesResponse{
		Chapter: models.ChapterInfo{
			ID:            chapter.ID,
			ChapterNumber: chapter.ChapterNumber,
			Comic:         comic,
		},
		Pages: pages,
		Count: len(pages),
	}

	s.LogInfo("Successfully retrieved chapter pages", logrus.Fields{
		"chapter_id":  id,
		"pages_count": len(pages),
	})

	return result, nil
}

// getChapterPages - EXACT COPY from Next.js: use "trChapter" table, not "mPage"
func (s *ChapterService) getChapterPages(ctx context.Context, chapterID string) ([]models.Page, error) {
	query := `
		SELECT id_chapter, page_number, page_url
		FROM "trChapter"
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
