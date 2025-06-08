package models

import (
	"time"
)

// User represents the mUser table structure
type User struct {
	ID        string    `json:"id" db:"id"`
	Name      string    `json:"name" db:"name"`
	Email     string    `json:"email" db:"email"`
	AvatarURL *string   `json:"avatar_url" db:"avatar_url"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// Bookmark represents the trUserBookmark table structure
type Bookmark struct {
	IDUser    string    `json:"id_user" db:"id_user"`
	IDKomik   string    `json:"id_komik" db:"id_komik"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

// BookmarkWithComic represents bookmark with comic details
type BookmarkWithComic struct {
	Bookmark
	Comic ComicWithDetails `json:"mKomik"`
}

// BookmarkDetails represents detailed bookmark response
type BookmarkDetails struct {
	BookmarkID string               `json:"bookmark_id"`
	Comic      ComicWithLatestChapter `json:"comic"`
}

// ComicWithLatestChapter represents comic with latest chapter info
type ComicWithLatestChapter struct {
	Comic
	LatestChapter *Chapter `json:"latest_chapter,omitempty"`
}

// Vote represents vote tables (mKomikVote and trChapterVote)
type Vote struct {
	IDUser    string    `json:"id_user" db:"id_user"`
	IDKomik   *string   `json:"id_komik,omitempty" db:"id_komik"`
	IDChapter *string   `json:"id_chapter,omitempty" db:"id_chapter"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
}

// Comment represents the mComment table structure
type Comment struct {
	ID          string    `json:"id" db:"id"`
	Content     string    `json:"content" db:"content"`
	IDUser      string    `json:"id_user" db:"id_user"`
	IDKomik     *string   `json:"id_komik" db:"id_komik"`
	IDChapter   *string   `json:"id_chapter" db:"id_chapter"`
	ParentID    *string   `json:"parent_id" db:"parent_id"`
	CreatedDate time.Time `json:"created_date" db:"created_date"`
}

// CommentWithUser represents comment with user information
type CommentWithUser struct {
	Comment
	User    User                `json:"mUser"`
	Replies []CommentWithUser   `json:"replies,omitempty"`
}

// CreateBookmarkRequest represents request to create bookmark
type CreateBookmarkRequest struct {
	IDKomik string `json:"id_komik" validate:"required"`
}

// CreateVoteRequest represents request to create vote
type CreateVoteRequest struct {
	IDKomik   *string `json:"id_komik,omitempty"`
	IDChapter *string `json:"id_chapter,omitempty"`
}

// CreateCommentRequest represents request to create comment
type CreateCommentRequest struct {
	Content   string  `json:"content" validate:"required"`
	IDKomik   *string `json:"id_komik,omitempty"`
	IDChapter *string `json:"id_chapter,omitempty"`
	ParentID  *string `json:"parent_id,omitempty"`
}

// SuccessResponse represents simple success response
type SuccessResponse struct {
	Success bool `json:"success"`
}
