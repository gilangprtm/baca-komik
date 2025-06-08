package models

import (
	"time"
)

// Comic represents the mKomik table structure (exact match with Next.js database types)
type Comic struct {
	ID               string    `json:"id" db:"id"`
	Title            string    `json:"title" db:"title"`
	AlternativeTitle *string   `json:"alternative_title" db:"alternative_title"`
	Description      *string   `json:"description" db:"description"`
	Status           string    `json:"status" db:"status"`
	CountryID        string    `json:"country_id" db:"country_id"`
	ViewCount        *int      `json:"view_count" db:"view_count"`
	VoteCount        *int      `json:"vote_count" db:"vote_count"`
	BookmarkCount    *int      `json:"bookmark_count" db:"bookmark_count"`
	CoverImageURL    *string   `json:"cover_image_url" db:"cover_image_url"`
	CreatedDate      *time.Time `json:"created_date" db:"created_date"`
	Rank             *float64  `json:"rank" db:"rank"`
	ReleaseYear      *int      `json:"release_year" db:"release_year"`
}

// ComicWithDetails represents comic with additional details
type ComicWithDetails struct {
	Comic
	ChapterCount    int             `json:"chapter_count"`
	LatestChapters  []Chapter       `json:"latest_chapters,omitempty"`
	Genres          []Genre         `json:"genres,omitempty"`
	Authors         []Author        `json:"authors,omitempty"`
	Artists         []Artist        `json:"artists,omitempty"`
	Formats         []Format        `json:"formats,omitempty"`
}

// ComicComplete represents complete comic response format (old)
type ComicComplete struct {
	Comic    ComicWithDetails `json:"comic"`
	UserData *UserData        `json:"user_data,omitempty"`
}

// ComicCompleteResponse - EXACT response format from Next.js /api/comics/[id]/complete
type ComicCompleteResponse struct {
	Comic    ComicCompleteData `json:"comic"`
	UserData UserDataComplete  `json:"user_data"`
}

// ComicCompleteData - Comic data for /complete endpoint (NO chapter_count like Next.js)
type ComicCompleteData struct {
	ID               string     `json:"id"`
	Title            string     `json:"title"`
	AlternativeTitle *string    `json:"alternative_title"`
	Description      *string    `json:"description"`
	Status           string     `json:"status"`
	CountryID        string     `json:"country_id"`
	ViewCount        *int       `json:"view_count"`
	VoteCount        *int       `json:"vote_count"`
	BookmarkCount    *int       `json:"bookmark_count"`
	CoverImageURL    *string    `json:"cover_image_url"`
	CreatedDate      *time.Time `json:"created_date"`
	Rank             *float64   `json:"rank"`
	ReleaseYear      *int       `json:"release_year"`
	// Relations - EXACTLY like Next.js formatting
	Genres  []Genre  `json:"genres"`
	Authors []Author `json:"authors"`
	Artists []Artist `json:"artists"`
	Formats []Format `json:"formats"`
}

// UserDataComplete - EXACT user data format from Next.js /api/comics/[id]/complete
type UserDataComplete struct {
	IsBookmarked    bool    `json:"is_bookmarked"`
	IsVoted         bool    `json:"is_voted"`
	LastReadChapter *string `json:"last_read_chapter"`
}

// UserData represents user-specific data for comics/chapters
type UserData struct {
	IsBookmarked     bool    `json:"is_bookmarked"`
	IsVoted          bool    `json:"is_voted"`
	LastReadChapter  *string `json:"last_read_chapter,omitempty"`
	IsRead           *bool   `json:"is_read,omitempty"`
}

// Genre represents the mGenre table
type Genre struct {
	ID   string `json:"id" db:"id"`
	Name string `json:"name" db:"name"`
}

// Author represents the mAuthor table
type Author struct {
	ID   string `json:"id" db:"id"`
	Name string `json:"name" db:"name"`
}

// Artist represents the mArtist table
type Artist struct {
	ID   string `json:"id" db:"id"`
	Name string `json:"name" db:"name"`
}

// Format represents the mFormat table
type Format struct {
	ID   string `json:"id" db:"id"`
	Name string `json:"name" db:"name"`
}

// PopularComic represents popular comic from mPopular table
type PopularComic struct {
	Comic
	Type string `json:"type" db:"type"`
}

// RecommendedComic represents recommended comic from mRecomed table
type RecommendedComic struct {
	Comic
}

// SuccessResponse represents a generic success response
type SuccessResponse struct {
	Success bool `json:"success"`
}

// SetupResponse - EXACT response format from Next.js /api/setup
type SetupResponse struct {
	Message string    `json:"message"`
	User    SetupUser `json:"user"`
}

// SetupUser - User data in setup response
type SetupUser struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}
