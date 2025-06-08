package models

import (
	"time"
)

// Chapter represents the mChapter table structure (exact match with Next.js database types)
type Chapter struct {
	ID                 string   `json:"id" db:"id"`
	IDKomik            string   `json:"id_komik" db:"id_komik"`
	ChapterNumber      float64  `json:"chapter_number" db:"chapter_number"`
	ReleaseDate        *time.Time `json:"release_date" db:"release_date"`
	Rating             *float64 `json:"rating" db:"rating"`
	ViewCount          *int     `json:"view_count" db:"view_count"`
	VoteCount          *int     `json:"vote_count" db:"vote_count"`
	ThumbnailImageURL  *string  `json:"thumbnail_image_url" db:"thumbnail_image_url"`
	CreatedDate        *time.Time `json:"created_date" db:"created_date"`
}

// ChapterWithComic represents chapter with comic information
type ChapterWithComic struct {
	Chapter
	Comic ComicBasic `json:"comic"`
}

// ChapterComplete represents complete chapter response format
type ChapterComplete struct {
	Chapter    ChapterWithComic `json:"chapter"`
	Pages      []Page           `json:"pages"`
	Navigation Navigation       `json:"navigation"`
	UserData   *UserData        `json:"user_data,omitempty"`
}

// ChapterPages represents chapter pages response
type ChapterPages struct {
	Chapter ComicBasic `json:"chapter"`
	Pages   []Page     `json:"pages"`
	Count   int        `json:"count"`
}

// ChapterBasic represents basic chapter information
type ChapterBasic struct {
	ID            string  `json:"id" db:"id"`
	ChapterNumber float64 `json:"chapter_number" db:"chapter_number"`
	Comic         ComicBasic `json:"comic"`
}

// ComicBasic represents basic comic information
type ComicBasic struct {
	ID               string  `json:"id" db:"id"`
	Title            string  `json:"title" db:"title"`
	AlternativeTitle *string `json:"alternative_title,omitempty" db:"alternative_title"`
	CoverImageURL    *string `json:"cover_image_url,omitempty" db:"cover_image_url"`
}

// Page represents the mPage table structure
type Page struct {
	IDChapter  string `json:"id_chapter" db:"id_chapter"`
	PageNumber int    `json:"page_number" db:"page_number"`
	PageURL    string `json:"page_url" db:"page_url"`
}

// Navigation represents chapter navigation
type Navigation struct {
	NextChapter *ChapterNav `json:"next_chapter,omitempty"`
	PrevChapter *ChapterNav `json:"prev_chapter,omitempty"`
}

// ChapterNav represents navigation chapter info
type ChapterNav struct {
	ID            string  `json:"id" db:"id"`
	ChapterNumber float64 `json:"chapter_number" db:"chapter_number"`
}

// ChaptersResponse represents comic chapters response
type ChaptersResponse struct {
	Comic ComicBasic `json:"comic"`
	Data  []Chapter  `json:"data"`
}

// AdjacentChaptersResponse represents adjacent chapters for navigation
type AdjacentChaptersResponse struct {
	CurrentChapterID string    `json:"current_chapter_id"`
	PrevChapters     []Chapter `json:"prev_chapters"`
	NextChapters     []Chapter `json:"next_chapters"`
}

// ChapterCompleteResponse - EXACT response format from Next.js /api/chapters/[id]/complete
type ChapterCompleteResponse struct {
	Chapter    ChapterWithComic  `json:"chapter"`
	Pages      []ChapterPage     `json:"pages"`
	Navigation ChapterNavigation `json:"navigation"`
	UserData   ChapterUserData   `json:"user_data"`
}

// ChapterPage - EXACT page format from Next.js trChapter table
type ChapterPage struct {
	IDChapter  string `json:"id_chapter"`
	PageNumber int    `json:"page_number"`
	PageURL    string `json:"page_url"`
}

// ChapterNavigation - EXACT navigation format from Next.js
type ChapterNavigation struct {
	PrevChapter *ChapterNav `json:"prev_chapter"`
	NextChapter *ChapterNav `json:"next_chapter"`
}

// ChapterUserData - EXACT user data format from Next.js /api/chapters/[id]/complete
type ChapterUserData struct {
	IsVoted bool `json:"is_voted"`
	IsRead  bool `json:"is_read"`
}

// ChapterPagesResponse - EXACT response format from Next.js /api/chapters/[id]/pages
type ChapterPagesResponse struct {
	Chapter ChapterInfo   `json:"chapter"`
	Pages   []ChapterPage `json:"pages"`
	Count   int           `json:"count"`
}

// ChapterInfo - Chapter info for pages response
type ChapterInfo struct {
	ID            string     `json:"id"`
	ChapterNumber float64    `json:"chapter_number"`
	Comic         ComicBasic `json:"comic"`
}

// ChapterBasicInfo - Basic chapter info from database
type ChapterBasicInfo struct {
	ID            string  `json:"id"`
	ChapterNumber float64 `json:"chapter_number"`
	IDKomik       string  `json:"id_komik"`
}

// ChapterDetailsResponse - EXACT response format from Next.js /api/chapters/[id]
type ChapterDetailsResponse struct {
	ID                string       `json:"id"`
	IDKomik           string       `json:"id_komik"`
	ChapterNumber     float64      `json:"chapter_number"`
	ReleaseDate       *time.Time   `json:"release_date"`
	Rating            *float64     `json:"rating"`
	ViewCount         *int         `json:"view_count"`
	VoteCount         *int         `json:"vote_count"`
	ThumbnailImageURL *string      `json:"thumbnail_image_url"`
	CreatedDate       *time.Time   `json:"created_date"`
	Comic             ComicBasic   `json:"comic"`
	NextChapter       *ChapterNav  `json:"next_chapter"`
	PrevChapter       *ChapterNav  `json:"prev_chapter"`
}
