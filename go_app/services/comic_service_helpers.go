package services

import (
	"context"
	"baca-komik-api/models"
)

// loadComicRelations loads authors, artists, and formats for a comic
func (s *ComicService) loadComicRelations(ctx context.Context, comic *models.ComicWithDetails) error {
	// Load authors
	authorsQuery := `
		SELECT a.id, a.name
		FROM "trAuthor" ta
		JOIN "mAuthor" a ON ta.id_author = a.id
		WHERE ta.id_komik = $1
		ORDER BY a.name
	`

	rows, err := s.GetDB().Query(ctx, authorsQuery, comic.ID)
	if err != nil {
		return err
	}
	defer rows.Close()

	var authors []models.Author
	for rows.Next() {
		var author models.Author
		if err := rows.Scan(&author.ID, &author.Name); err != nil {
			continue
		}
		authors = append(authors, author)
	}
	comic.Authors = authors

	// Load artists
	artistsQuery := `
		SELECT a.id, a.name
		FROM "trArtist" ta
		JOIN "mArtist" a ON ta.id_artist = a.id
		WHERE ta.id_komik = $1
		ORDER BY a.name
	`

	rows, err = s.GetDB().Query(ctx, artistsQuery, comic.ID)
	if err != nil {
		return err
	}
	defer rows.Close()

	var artists []models.Artist
	for rows.Next() {
		var artist models.Artist
		if err := rows.Scan(&artist.ID, &artist.Name); err != nil {
			continue
		}
		artists = append(artists, artist)
	}
	comic.Artists = artists

	// Load formats
	formatsQuery := `
		SELECT f.id, f.name
		FROM "trFormat" tf
		JOIN "mFormat" f ON tf.id_format = f.id
		WHERE tf.id_komik = $1
		ORDER BY f.name
	`

	rows, err = s.GetDB().Query(ctx, formatsQuery, comic.ID)
	if err != nil {
		return err
	}
	defer rows.Close()

	var formats []models.Format
	for rows.Next() {
		var format models.Format
		if err := rows.Scan(&format.ID, &format.Name); err != nil {
			continue
		}
		formats = append(formats, format)
	}
	comic.Formats = formats

	return nil
}

// loadUserComicData loads user-specific data for a comic
func (s *ComicService) loadUserComicData(ctx context.Context, comicID, userID string) (*models.UserData, error) {
	userData := &models.UserData{}

	// Check if comic is bookmarked
	bookmarkQuery := `
		SELECT EXISTS(
			SELECT 1 FROM "trUserBookmark" 
			WHERE id_user = $1 AND id_komik = $2
		)
	`
	err := s.GetDB().QueryRow(ctx, bookmarkQuery, userID, comicID).Scan(&userData.IsBookmarked)
	if err != nil {
		return nil, err
	}

	// Check if comic is voted
	voteQuery := `
		SELECT EXISTS(
			SELECT 1 FROM "mKomikVote" 
			WHERE id_user = $1 AND id_komik = $2
		)
	`
	err = s.GetDB().QueryRow(ctx, voteQuery, userID, comicID).Scan(&userData.IsVoted)
	if err != nil {
		return nil, err
	}

	// Get last read chapter
	lastReadQuery := `
		SELECT c.id
		FROM "trUserReadHistory" urh
		JOIN "mChapter" c ON urh.id_chapter = c.id
		WHERE urh.id_user = $1 AND c.id_komik = $2
		ORDER BY urh.read_at DESC
		LIMIT 1
	`
	var lastReadChapter string
	err = s.GetDB().QueryRow(ctx, lastReadQuery, userID, comicID).Scan(&lastReadChapter)
	if err == nil {
		userData.LastReadChapter = &lastReadChapter
	}
	// Ignore error if no read history found

	return userData, nil
}
