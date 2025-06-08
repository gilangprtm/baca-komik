package services

import (
	"context"
	"errors"
	"time"

	"github.com/sirupsen/logrus"
	"baca-komik-api/database"
	"baca-komik-api/models"
)

// CommentService provides comment-related functionality
type CommentService struct {
	*BaseService
}

// NewCommentService creates a new comment service
func NewCommentService(db *database.DB) *CommentService {
	return &CommentService{
		BaseService: NewBaseService(db),
	}
}

// GetComments retrieves comments for a comic or chapter
func (s *CommentService) GetComments(targetID, commentType string, page, limit int, parentOnly bool) ([]models.CommentWithUser, int, error) {
	ctx, cancel := s.WithTimeout(30 * time.Second)
	defer cancel()

	s.LogInfo("Getting comments", logrus.Fields{
		"target_id":   targetID,
		"type":        commentType,
		"page":        page,
		"limit":       limit,
		"parent_only": parentOnly,
	})

	// Validate comment type
	if commentType != "comic" && commentType != "chapter" {
		return nil, 0, errors.New("invalid type, must be 'comic' or 'chapter'")
	}

	// Calculate offset
	offset := (page - 1) * limit

	// Build query based on type and parent_only
	var query string
	var countQuery string
	var args []interface{}

	if commentType == "comic" {
		if parentOnly {
			query = `
				SELECT 
					c.id, c.content, c.id_user, c.id_komik, c.id_chapter, 
					c.parent_id, c.created_date,
					u.id, u.name, u.avatar_url
				FROM "mComment" c
				JOIN "mUser" u ON c.id_user = u.id
				WHERE c.id_komik = $1 AND c.parent_id IS NULL
				ORDER BY c.created_date DESC
				LIMIT $2 OFFSET $3
			`
			countQuery = `SELECT COUNT(*) FROM "mComment" WHERE id_komik = $1 AND parent_id IS NULL`
		} else {
			query = `
				SELECT 
					c.id, c.content, c.id_user, c.id_komik, c.id_chapter, 
					c.parent_id, c.created_date,
					u.id, u.name, u.avatar_url
				FROM "mComment" c
				JOIN "mUser" u ON c.id_user = u.id
				WHERE c.id_komik = $1
				ORDER BY c.created_date DESC
				LIMIT $2 OFFSET $3
			`
			countQuery = `SELECT COUNT(*) FROM "mComment" WHERE id_komik = $1`
		}
		args = []interface{}{targetID, limit, offset}
	} else {
		if parentOnly {
			query = `
				SELECT 
					c.id, c.content, c.id_user, c.id_komik, c.id_chapter, 
					c.parent_id, c.created_date,
					u.id, u.name, u.avatar_url
				FROM "mComment" c
				JOIN "mUser" u ON c.id_user = u.id
				WHERE c.id_chapter = $1 AND c.parent_id IS NULL
				ORDER BY c.created_date DESC
				LIMIT $2 OFFSET $3
			`
			countQuery = `SELECT COUNT(*) FROM "mComment" WHERE id_chapter = $1 AND parent_id IS NULL`
		} else {
			query = `
				SELECT 
					c.id, c.content, c.id_user, c.id_komik, c.id_chapter, 
					c.parent_id, c.created_date,
					u.id, u.name, u.avatar_url
				FROM "mComment" c
				JOIN "mUser" u ON c.id_user = u.id
				WHERE c.id_chapter = $1
				ORDER BY c.created_date DESC
				LIMIT $2 OFFSET $3
			`
			countQuery = `SELECT COUNT(*) FROM "mComment" WHERE id_chapter = $1`
		}
		args = []interface{}{targetID, limit, offset}
	}

	// Execute main query
	rows, err := s.GetDB().Query(ctx, query, args...)
	if err != nil {
		s.LogError(err, "Failed to get comments", logrus.Fields{
			"target_id": targetID,
			"type":      commentType,
		})
		return nil, 0, err
	}
	defer rows.Close()

	var comments []models.CommentWithUser
	for rows.Next() {
		var comment models.CommentWithUser
		err := rows.Scan(
			&comment.ID, &comment.Content, &comment.IDUser, &comment.IDKomik,
			&comment.IDChapter, &comment.ParentID, &comment.CreatedDate,
			&comment.User.ID, &comment.User.Name, &comment.User.AvatarURL,
		)
		if err != nil {
			s.LogError(err, "Failed to scan comment row", nil)
			continue
		}
		comments = append(comments, comment)
	}

	// Get total count
	var total int
	countArgs := []interface{}{targetID}
	err = s.GetDB().QueryRow(ctx, countQuery, countArgs...).Scan(&total)
	if err != nil {
		s.LogError(err, "Failed to get comments count", logrus.Fields{
			"target_id": targetID,
			"type":      commentType,
		})
		return nil, 0, err
	}

	// Load replies for parent comments if not parent_only
	if !parentOnly {
		if err := s.loadCommentReplies(ctx, comments); err != nil {
			s.LogError(err, "Failed to load comment replies", nil)
		}
	}

	s.LogInfo("Successfully retrieved comments", logrus.Fields{
		"target_id": targetID,
		"type":      commentType,
		"count":     len(comments),
		"total":     total,
	})

	return comments, total, nil
}

// AddComment adds a new comment
func (s *CommentService) AddComment(userID string, request *models.CreateCommentRequest) (*models.Comment, error) {
	ctx, cancel := s.WithTimeout(15 * time.Second)
	defer cancel()

	s.LogInfo("Adding comment", logrus.Fields{
		"user_id":    userID,
		"comic_id":   request.IDKomik,
		"chapter_id": request.IDChapter,
		"parent_id":  request.ParentID,
	})

	// Validate request - exactly one of comic_id or chapter_id must be provided
	if (request.IDKomik == nil && request.IDChapter == nil) ||
		(request.IDKomik != nil && request.IDChapter != nil) {
		return nil, errors.New("provide either comic_id or chapter_id, not both")
	}

	// Validate target exists
	if request.IDKomik != nil {
		var exists bool
		checkQuery := `SELECT EXISTS(SELECT 1 FROM "mKomik" WHERE id = $1)`
		err := s.GetDB().QueryRow(ctx, checkQuery, *request.IDKomik).Scan(&exists)
		if err != nil || !exists {
			return nil, errors.New("comic not found")
		}
	} else {
		var exists bool
		checkQuery := `SELECT EXISTS(SELECT 1 FROM "mChapter" WHERE id = $1)`
		err := s.GetDB().QueryRow(ctx, checkQuery, *request.IDChapter).Scan(&exists)
		if err != nil || !exists {
			return nil, errors.New("chapter not found")
		}
	}

	// Validate parent comment if provided
	if request.ParentID != nil {
		var parentComicID, parentChapterID *string
		checkParentQuery := `SELECT id_komik, id_chapter FROM "mComment" WHERE id = $1`
		err := s.GetDB().QueryRow(ctx, checkParentQuery, *request.ParentID).Scan(&parentComicID, &parentChapterID)
		if err != nil {
			return nil, errors.New("parent comment not found")
		}

		// Ensure parent comment is for the same target
		if request.IDKomik != nil && (parentComicID == nil || *parentComicID != *request.IDKomik) {
			return nil, errors.New("parent comment is not for the same comic")
		}
		if request.IDChapter != nil && (parentChapterID == nil || *parentChapterID != *request.IDChapter) {
			return nil, errors.New("parent comment is not for the same chapter")
		}
	}

	// Insert comment
	insertQuery := `
		INSERT INTO "mComment" (content, id_user, id_komik, id_chapter, parent_id, created_date)
		VALUES ($1, $2, $3, $4, $5, NOW())
		RETURNING id, content, id_user, id_komik, id_chapter, parent_id, created_date
	`

	var comment models.Comment
	err := s.GetDB().QueryRow(ctx, insertQuery, request.Content, userID, request.IDKomik, request.IDChapter, request.ParentID).Scan(
		&comment.ID, &comment.Content, &comment.IDUser, &comment.IDKomik,
		&comment.IDChapter, &comment.ParentID, &comment.CreatedDate,
	)
	if err != nil {
		s.LogError(err, "Failed to insert comment", logrus.Fields{
			"user_id":    userID,
			"comic_id":   request.IDKomik,
			"chapter_id": request.IDChapter,
		})
		return nil, err
	}

	s.LogInfo("Successfully added comment", logrus.Fields{
		"comment_id": comment.ID,
		"user_id":    userID,
		"comic_id":   request.IDKomik,
		"chapter_id": request.IDChapter,
	})

	return &comment, nil
}

// loadCommentReplies loads replies for parent comments
func (s *CommentService) loadCommentReplies(ctx context.Context, comments []models.CommentWithUser) error {
	if len(comments) == 0 {
		return nil
	}

	// Get all parent comment IDs
	var parentIDs []string
	for _, comment := range comments {
		if comment.ParentID == nil {
			parentIDs = append(parentIDs, comment.ID)
		}
	}

	if len(parentIDs) == 0 {
		return nil
	}

	// Get replies for all parent comments
	query := `
		SELECT 
			c.id, c.content, c.id_user, c.id_komik, c.id_chapter, 
			c.parent_id, c.created_date,
			u.id, u.name, u.avatar_url
		FROM "mComment" c
		JOIN "mUser" u ON c.id_user = u.id
		WHERE c.parent_id = ANY($1)
		ORDER BY c.created_date ASC
	`

	rows, err := s.GetDB().Query(ctx, query, parentIDs)
	if err != nil {
		return err
	}
	defer rows.Close()

	// Group replies by parent ID
	repliesMap := make(map[string][]models.CommentWithUser)
	for rows.Next() {
		var reply models.CommentWithUser
		err := rows.Scan(
			&reply.ID, &reply.Content, &reply.IDUser, &reply.IDKomik,
			&reply.IDChapter, &reply.ParentID, &reply.CreatedDate,
			&reply.User.ID, &reply.User.Name, &reply.User.AvatarURL,
		)
		if err != nil {
			continue
		}

		if reply.ParentID != nil {
			repliesMap[*reply.ParentID] = append(repliesMap[*reply.ParentID], reply)
		}
	}

	// Assign replies to parent comments
	for i := range comments {
		if comments[i].ParentID == nil {
			comments[i].Replies = repliesMap[comments[i].ID]
		}
	}

	return nil
}
