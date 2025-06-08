package services

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
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

	// Get basic comic information - EXACTLY like Next.js: SELECT * (include release_year!)
	query := `
		SELECT
			k.id, k.title, k.alternative_title, k.description, k.status,
			k.country_id, k.view_count, k.vote_count, k.bookmark_count,
			k.cover_image_url, k.created_date, k.rank, k.release_year,
			(SELECT COUNT(*) FROM "mChapter" c WHERE c.id_komik = k.id) as chapter_count
		FROM "mKomik" k
		WHERE k.id = $1
	`

	var comic models.ComicWithDetails
	err := s.GetDB().QueryRow(ctx, query, id).Scan(
		&comic.ID, &comic.Title, &comic.AlternativeTitle, &comic.Description,
		&comic.Status, &comic.CountryID, &comic.ViewCount, &comic.VoteCount,
		&comic.BookmarkCount, &comic.CoverImageURL, &comic.CreatedDate,
		&comic.Rank, &comic.ReleaseYear, &comic.ChapterCount,
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

// GetCompleteComicDetails - EXACT COPY from Next.js /api/comics/[id]/complete/route.ts
func (s *ComicService) GetCompleteComicDetails(id string, userID *string) (*models.ComicCompleteResponse, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting complete comic details", logrus.Fields{
		"comic_id": id,
		"user_id":  userID,
	})

	// Fetch comic with related data - EXACTLY like Next.js lines 31-51
	query := `
		SELECT
			k.id, k.title, k.alternative_title, k.description, k.status,
			k.country_id, k.view_count, k.vote_count, k.bookmark_count,
			k.cover_image_url, k.created_date, k.rank, k.release_year
		FROM "mKomik" k
		WHERE k.id = $1
	`

	var comic models.ComicCompleteData
	err := s.GetDB().QueryRow(ctx, query, id).Scan(
		&comic.ID, &comic.Title, &comic.AlternativeTitle, &comic.Description,
		&comic.Status, &comic.CountryID, &comic.ViewCount, &comic.VoteCount,
		&comic.BookmarkCount, &comic.CoverImageURL, &comic.CreatedDate,
		&comic.Rank, &comic.ReleaseYear,
	)
	if err != nil {
		if err == pgx.ErrNoRows {
			return nil, fmt.Errorf("comic not found")
		}
		s.LogError(err, "Failed to fetch comic", logrus.Fields{
			"comic_id": id,
		})
		return nil, err
	}

	// Load trGenre, trAuthor, trArtist, trFormat - EXACTLY like Next.js lines 36-47
	if err := s.loadComicRelationsForComplete(ctx, &comic); err != nil {
		s.LogError(err, "Failed to load comic relations", nil)
		// Continue even if relations fail
	}

	// Initialize user data - EXACTLY like Next.js lines 78-83
	userData := models.UserDataComplete{
		IsBookmarked:    false,
		IsVoted:         false,
		LastReadChapter: nil,
	}

	// If user is authenticated, fetch user-specific data - EXACTLY like Next.js lines 85-118
	if userID != nil {
		// Check if comic is bookmarked - EXACTLY like Next.js lines 87-93
		var bookmarkExists bool
		bookmarkQuery := `SELECT EXISTS(SELECT 1 FROM "trUserBookmark" WHERE id_user = $1 AND id_komik = $2)`
		err = s.GetDB().QueryRow(ctx, bookmarkQuery, *userID, id).Scan(&bookmarkExists)
		if err != nil {
			s.LogError(err, "Failed to check bookmark", nil)
		}

		// Check if comic is voted - EXACTLY like Next.js lines 95-101
		var voteExists bool
		voteQuery := `SELECT EXISTS(SELECT 1 FROM "mKomikVote" WHERE id_user = $1 AND id_komik = $2)`
		err = s.GetDB().QueryRow(ctx, voteQuery, *userID, id).Scan(&voteExists)
		if err != nil {
			s.LogError(err, "Failed to check vote", nil)
		}

		// Get last read chapter - EXACTLY like Next.js lines 103-111
		var lastReadChapter *string
		lastReadQuery := `
			SELECT id_chapter
			FROM "trUserHistory"
			WHERE id_user = $1 AND id_komik = $2
			ORDER BY created_date DESC
			LIMIT 1
		`
		err = s.GetDB().QueryRow(ctx, lastReadQuery, *userID, id).Scan(&lastReadChapter)
		if err != nil && err != pgx.ErrNoRows {
			s.LogError(err, "Failed to get last read chapter", nil)
		}

		// Set user data - EXACTLY like Next.js lines 113-117
		userData = models.UserDataComplete{
			IsBookmarked:    bookmarkExists,
			IsVoted:         voteExists,
			LastReadChapter: lastReadChapter,
		}
	}

	// Increment view count - EXACTLY like Next.js line 121
	_, err = s.GetDB().Exec(ctx, `SELECT increment_comic_view_count($1)`, id)
	if err != nil {
		s.LogError(err, "Failed to increment view count", nil)
		// Continue even if increment fails
	}

	// Return response - EXACTLY like Next.js lines 124-127
	result := &models.ComicCompleteResponse{
		Comic:    comic,
		UserData: userData,
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

// loadComicRelationsComplete loads trGenre, trAuthor, trArtist, trFormat - EXACTLY like Next.js lines 36-47
func (s *ComicService) loadComicRelationsComplete(ctx context.Context, comic *models.ComicWithDetails) error {
	// Load trGenre - EXACTLY like Next.js trGenre!trGenre_id_komik_fkey (mGenre!inner (id, name))
	genreQuery := `
		SELECT g.id, g.name
		FROM "trGenre" tg
		JOIN "mGenre" g ON tg.id_genre = g.id
		WHERE tg.id_komik = $1
		ORDER BY g.name
	`
	genreRows, err := s.GetDB().Query(ctx, genreQuery, comic.ID)
	if err != nil {
		return err
	}
	defer genreRows.Close()

	var genres []models.Genre
	for genreRows.Next() {
		var genre models.Genre
		if err := genreRows.Scan(&genre.ID, &genre.Name); err != nil {
			continue
		}
		genres = append(genres, genre)
	}
	comic.Genres = genres

	// Load trAuthor - EXACTLY like Next.js trAuthor!trAuthor_id_komik_fkey (mAuthor!inner (id, name))
	authorQuery := `
		SELECT a.id, a.name
		FROM "trAuthor" ta
		JOIN "mAuthor" a ON ta.id_author = a.id
		WHERE ta.id_komik = $1
		ORDER BY a.name
	`
	authorRows, err := s.GetDB().Query(ctx, authorQuery, comic.ID)
	if err != nil {
		return err
	}
	defer authorRows.Close()

	var authors []models.Author
	for authorRows.Next() {
		var author models.Author
		if err := authorRows.Scan(&author.ID, &author.Name); err != nil {
			continue
		}
		authors = append(authors, author)
	}
	comic.Authors = authors

	// Load trArtist - EXACTLY like Next.js trArtist!trArtist_id_komik_fkey (mArtist!inner (id, name))
	artistQuery := `
		SELECT a.id, a.name
		FROM "trArtist" ta
		JOIN "mArtist" a ON ta.id_artist = a.id
		WHERE ta.id_komik = $1
		ORDER BY a.name
	`
	artistRows, err := s.GetDB().Query(ctx, artistQuery, comic.ID)
	if err != nil {
		return err
	}
	defer artistRows.Close()

	var artists []models.Artist
	for artistRows.Next() {
		var artist models.Artist
		if err := artistRows.Scan(&artist.ID, &artist.Name); err != nil {
			continue
		}
		artists = append(artists, artist)
	}
	comic.Artists = artists

	// Load trFormat - EXACTLY like Next.js trFormat!trFormat_id_komik_fkey (mFormat!inner (id, name))
	formatQuery := `
		SELECT f.id, f.name
		FROM "trFormat" tf
		JOIN "mFormat" f ON tf.id_format = f.id
		WHERE tf.id_komik = $1
		ORDER BY f.name
	`
	formatRows, err := s.GetDB().Query(ctx, formatQuery, comic.ID)
	if err != nil {
		return err
	}
	defer formatRows.Close()

	var formats []models.Format
	for formatRows.Next() {
		var format models.Format
		if err := formatRows.Scan(&format.ID, &format.Name); err != nil {
			continue
		}
		formats = append(formats, format)
	}
	comic.Formats = formats

	return nil
}

// loadComicRelationsForComplete loads relations for ComicCompleteData - EXACTLY like Next.js
func (s *ComicService) loadComicRelationsForComplete(ctx context.Context, comic *models.ComicCompleteData) error {
	// Load trGenre - EXACTLY like Next.js trGenre!trGenre_id_komik_fkey (mGenre!inner (id, name))
	genreQuery := `
		SELECT g.id, g.name
		FROM "trGenre" tg
		JOIN "mGenre" g ON tg.id_genre = g.id
		WHERE tg.id_komik = $1
		ORDER BY g.name
	`
	genreRows, err := s.GetDB().Query(ctx, genreQuery, comic.ID)
	if err != nil {
		return err
	}
	defer genreRows.Close()

	var genres []models.Genre
	for genreRows.Next() {
		var genre models.Genre
		if err := genreRows.Scan(&genre.ID, &genre.Name); err != nil {
			continue
		}
		genres = append(genres, genre)
	}
	comic.Genres = genres

	// Load trAuthor - EXACTLY like Next.js trAuthor!trAuthor_id_komik_fkey (mAuthor!inner (id, name))
	authorQuery := `
		SELECT a.id, a.name
		FROM "trAuthor" ta
		JOIN "mAuthor" a ON ta.id_author = a.id
		WHERE ta.id_komik = $1
		ORDER BY a.name
	`
	authorRows, err := s.GetDB().Query(ctx, authorQuery, comic.ID)
	if err != nil {
		return err
	}
	defer authorRows.Close()

	var authors []models.Author
	for authorRows.Next() {
		var author models.Author
		if err := authorRows.Scan(&author.ID, &author.Name); err != nil {
			continue
		}
		authors = append(authors, author)
	}
	comic.Authors = authors

	// Load trArtist - EXACTLY like Next.js trArtist!trArtist_id_komik_fkey (mArtist!inner (id, name))
	artistQuery := `
		SELECT a.id, a.name
		FROM "trArtist" ta
		JOIN "mArtist" a ON ta.id_artist = a.id
		WHERE ta.id_komik = $1
		ORDER BY a.name
	`
	artistRows, err := s.GetDB().Query(ctx, artistQuery, comic.ID)
	if err != nil {
		return err
	}
	defer artistRows.Close()

	var artists []models.Artist
	for artistRows.Next() {
		var artist models.Artist
		if err := artistRows.Scan(&artist.ID, &artist.Name); err != nil {
			continue
		}
		artists = append(artists, artist)
	}
	comic.Artists = artists

	// Load trFormat - EXACTLY like Next.js trFormat!trFormat_id_komik_fkey (mFormat!inner (id, name))
	formatQuery := `
		SELECT f.id, f.name
		FROM "trFormat" tf
		JOIN "mFormat" f ON tf.id_format = f.id
		WHERE tf.id_komik = $1
		ORDER BY f.name
	`
	formatRows, err := s.GetDB().Query(ctx, formatQuery, comic.ID)
	if err != nil {
		return err
	}
	defer formatRows.Close()

	var formats []models.Format
	for formatRows.Next() {
		var format models.Format
		if err := formatRows.Scan(&format.ID, &format.Name); err != nil {
			continue
		}
		formats = append(formats, format)
	}
	comic.Formats = formats

	return nil
}

// loadComicRelationsOld loads genres, authors, artists, formats for a comic - exactly like Next.js
func (s *ComicService) loadComicRelationsOld(ctx context.Context, comic *models.ComicWithDetails) error {
	// Load genres
	genreQuery := `
		SELECT g.id, g.name
		FROM "trGenre" tg
		JOIN "mGenre" g ON tg.id_genre = g.id
		WHERE tg.id_komik = $1
		ORDER BY g.name
	`
	genreRows, err := s.GetDB().Query(ctx, genreQuery, comic.ID)
	if err != nil {
		return err
	}
	defer genreRows.Close()

	var genres []models.Genre
	for genreRows.Next() {
		var genre models.Genre
		if err := genreRows.Scan(&genre.ID, &genre.Name); err != nil {
			continue
		}
		genres = append(genres, genre)
	}
	comic.Genres = genres

	// Load authors
	authorQuery := `
		SELECT a.id, a.name
		FROM "trAuthor" ta
		JOIN "mAuthor" a ON ta.id_author = a.id
		WHERE ta.id_komik = $1
		ORDER BY a.name
	`
	authorRows, err := s.GetDB().Query(ctx, authorQuery, comic.ID)
	if err != nil {
		return err
	}
	defer authorRows.Close()

	var authors []models.Author
	for authorRows.Next() {
		var author models.Author
		if err := authorRows.Scan(&author.ID, &author.Name); err != nil {
			continue
		}
		authors = append(authors, author)
	}
	comic.Authors = authors

	// Load artists
	artistQuery := `
		SELECT a.id, a.name
		FROM "trArtist" ta
		JOIN "mArtist" a ON ta.id_artist = a.id
		WHERE ta.id_komik = $1
		ORDER BY a.name
	`
	artistRows, err := s.GetDB().Query(ctx, artistQuery, comic.ID)
	if err != nil {
		return err
	}
	defer artistRows.Close()

	var artists []models.Artist
	for artistRows.Next() {
		var artist models.Artist
		if err := artistRows.Scan(&artist.ID, &artist.Name); err != nil {
			continue
		}
		artists = append(artists, artist)
	}
	comic.Artists = artists

	// Load formats
	formatQuery := `
		SELECT f.id, f.name
		FROM "trFormat" tf
		JOIN "mFormat" f ON tf.id_format = f.id
		WHERE tf.id_komik = $1
		ORDER BY f.name
	`
	formatRows, err := s.GetDB().Query(ctx, formatQuery, comic.ID)
	if err != nil {
		return err
	}
	defer formatRows.Close()

	var formats []models.Format
	for formatRows.Next() {
		var format models.Format
		if err := formatRows.Scan(&format.ID, &format.Name); err != nil {
			continue
		}
		formats = append(formats, format)
	}
	comic.Formats = formats

	return nil
}
