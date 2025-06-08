package services

import (
	"context"
	"errors"
	"time"

	"github.com/sirupsen/logrus"
	"baca-komik-api/database"
	"baca-komik-api/models"
)

// VoteService provides vote-related functionality
type VoteService struct {
	*BaseService
}

// NewVoteService creates a new vote service
func NewVoteService(db *database.DB) *VoteService {
	return &VoteService{
		BaseService: NewBaseService(db),
	}
}

// AddVote adds a vote for comic or chapter
func (s *VoteService) AddVote(userID string, request *models.CreateVoteRequest) (*models.Vote, error) {
	ctx, cancel := s.WithTimeout(15 * time.Second)
	defer cancel()

	s.LogInfo("Adding vote", logrus.Fields{
		"user_id":    userID,
		"comic_id":   request.IDKomik,
		"chapter_id": request.IDChapter,
	})

	// Validate request - exactly one of comic_id or chapter_id must be provided
	if (request.IDKomik == nil && request.IDChapter == nil) ||
		(request.IDKomik != nil && request.IDChapter != nil) {
		return nil, errors.New("provide either comic_id or chapter_id, not both")
	}

	if request.IDKomik != nil {
		return s.addComicVote(ctx, userID, *request.IDKomik)
	} else {
		return s.addChapterVote(ctx, userID, *request.IDChapter)
	}
}

// addComicVote adds a vote for a comic
func (s *VoteService) addComicVote(ctx context.Context, userID, comicID string) (*models.Vote, error) {
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
		return nil, errors.New("comic not found")
	}

	// Check if vote already exists
	checkVoteQuery := `SELECT EXISTS(SELECT 1 FROM "mKomikVote" WHERE id_user = $1 AND id_komik = $2)`
	err = s.GetDB().QueryRow(ctx, checkVoteQuery, userID, comicID).Scan(&exists)
	if err != nil {
		s.LogError(err, "Failed to check vote existence", nil)
		return nil, err
	}

	if exists {
		return nil, errors.New("vote already exists")
	}

	// Insert vote
	insertQuery := `
		INSERT INTO "mKomikVote" (id_user, id_komik, created_at)
		VALUES ($1, $2, NOW())
		RETURNING id_user, id_komik, created_at
	`

	var vote models.Vote
	err = s.GetDB().QueryRow(ctx, insertQuery, userID, comicID).Scan(
		&vote.IDUser, &vote.IDKomik, &vote.CreatedAt,
	)
	if err != nil {
		s.LogError(err, "Failed to insert comic vote", logrus.Fields{
			"user_id":  userID,
			"comic_id": comicID,
		})
		return nil, err
	}

	// Update comic vote count (if function exists)
	s.updateComicVoteCount(ctx, comicID)

	s.LogInfo("Successfully added comic vote", logrus.Fields{
		"user_id":  userID,
		"comic_id": comicID,
	})

	return &vote, nil
}

// addChapterVote adds a vote for a chapter
func (s *VoteService) addChapterVote(ctx context.Context, userID, chapterID string) (*models.Vote, error) {
	// Check if chapter exists
	var exists bool
	checkQuery := `SELECT EXISTS(SELECT 1 FROM "mChapter" WHERE id = $1)`
	err := s.GetDB().QueryRow(ctx, checkQuery, chapterID).Scan(&exists)
	if err != nil {
		s.LogError(err, "Failed to check chapter existence", logrus.Fields{
			"chapter_id": chapterID,
		})
		return nil, err
	}

	if !exists {
		return nil, errors.New("chapter not found")
	}

	// Check if vote already exists
	checkVoteQuery := `SELECT EXISTS(SELECT 1 FROM "trChapterVote" WHERE id_user = $1 AND id_chapter = $2)`
	err = s.GetDB().QueryRow(ctx, checkVoteQuery, userID, chapterID).Scan(&exists)
	if err != nil {
		s.LogError(err, "Failed to check chapter vote existence", nil)
		return nil, err
	}

	if exists {
		return nil, errors.New("vote already exists")
	}

	// Insert vote
	insertQuery := `
		INSERT INTO "trChapterVote" (id_user, id_chapter, created_at)
		VALUES ($1, $2, NOW())
		RETURNING id_user, id_chapter, created_at
	`

	var vote models.Vote
	err = s.GetDB().QueryRow(ctx, insertQuery, userID, chapterID).Scan(
		&vote.IDUser, &vote.IDChapter, &vote.CreatedAt,
	)
	if err != nil {
		s.LogError(err, "Failed to insert chapter vote", logrus.Fields{
			"user_id":    userID,
			"chapter_id": chapterID,
		})
		return nil, err
	}

	// Update chapter vote count (if function exists)
	s.updateChapterVoteCount(ctx, chapterID)

	s.LogInfo("Successfully added chapter vote", logrus.Fields{
		"user_id":    userID,
		"chapter_id": chapterID,
	})

	return &vote, nil
}

// RemoveVote removes a vote for comic or chapter
func (s *VoteService) RemoveVote(userID, targetID, voteType string) error {
	ctx, cancel := s.WithTimeout(15 * time.Second)
	defer cancel()

	s.LogInfo("Removing vote", logrus.Fields{
		"user_id":   userID,
		"target_id": targetID,
		"type":      voteType,
	})

	if voteType == "comic" {
		return s.removeComicVote(ctx, userID, targetID)
	} else if voteType == "chapter" {
		return s.removeChapterVote(ctx, userID, targetID)
	} else {
		return errors.New("invalid vote type, must be 'comic' or 'chapter'")
	}
}

// removeComicVote removes a vote for a comic
func (s *VoteService) removeComicVote(ctx context.Context, userID, comicID string) error {
	deleteQuery := `DELETE FROM "mKomikVote" WHERE id_user = $1 AND id_komik = $2`
	result, err := s.GetDB().Exec(ctx, deleteQuery, userID, comicID)
	if err != nil {
		s.LogError(err, "Failed to delete comic vote", logrus.Fields{
			"user_id":  userID,
			"comic_id": comicID,
		})
		return err
	}

	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		return errors.New("vote not found")
	}

	// Update comic vote count (if function exists)
	s.updateComicVoteCount(ctx, comicID)

	s.LogInfo("Successfully removed comic vote", logrus.Fields{
		"user_id":  userID,
		"comic_id": comicID,
	})

	return nil
}

// removeChapterVote removes a vote for a chapter
func (s *VoteService) removeChapterVote(ctx context.Context, userID, chapterID string) error {
	deleteQuery := `DELETE FROM "trChapterVote" WHERE id_user = $1 AND id_chapter = $2`
	result, err := s.GetDB().Exec(ctx, deleteQuery, userID, chapterID)
	if err != nil {
		s.LogError(err, "Failed to delete chapter vote", logrus.Fields{
			"user_id":    userID,
			"chapter_id": chapterID,
		})
		return err
	}

	rowsAffected := result.RowsAffected()
	if rowsAffected == 0 {
		return errors.New("vote not found")
	}

	// Update chapter vote count (if function exists)
	s.updateChapterVoteCount(ctx, chapterID)

	s.LogInfo("Successfully removed chapter vote", logrus.Fields{
		"user_id":    userID,
		"chapter_id": chapterID,
	})

	return nil
}

// updateComicVoteCount updates the vote count for a comic
func (s *VoteService) updateComicVoteCount(ctx context.Context, comicID string) {
	// Try to call stored procedure if it exists
	_, err := s.GetDB().Exec(ctx, `SELECT update_comic_vote_count($1)`, comicID)
	if err != nil {
		// If stored procedure doesn't exist, update manually
		updateQuery := `
			UPDATE "mKomik" 
			SET vote_count = (
				SELECT COUNT(*) FROM "mKomikVote" WHERE id_komik = $1
			)
			WHERE id = $1
		`
		_, err = s.GetDB().Exec(ctx, updateQuery, comicID)
		if err != nil {
			s.LogError(err, "Failed to update comic vote count", logrus.Fields{
				"comic_id": comicID,
			})
		}
	}
}

// updateChapterVoteCount updates the vote count for a chapter
func (s *VoteService) updateChapterVoteCount(ctx context.Context, chapterID string) {
	// Try to call stored procedure if it exists
	_, err := s.GetDB().Exec(ctx, `SELECT update_chapter_vote_count($1)`, chapterID)
	if err != nil {
		// If stored procedure doesn't exist, update manually
		updateQuery := `
			UPDATE "mChapter" 
			SET vote_count = (
				SELECT COUNT(*) FROM "trChapterVote" WHERE id_chapter = $1
			)
			WHERE id = $1
		`
		_, err = s.GetDB().Exec(ctx, updateQuery, chapterID)
		if err != nil {
			s.LogError(err, "Failed to update chapter vote count", logrus.Fields{
				"chapter_id": chapterID,
			})
		}
	}
}
