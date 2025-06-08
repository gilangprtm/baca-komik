package models

import (
	"time"
)

// Chapter represents the mChapter table structure
type Chapter struct {
	ID                 string    `json:"id" db:"id"`
	IDKomik            string    `json:"id_komik" db:"id_komik"`
	ChapterNumber      float64   `json:"chapter_number" db:"chapter_number"`
	Title              *string   `json:"title" db:"title"`
	ReleaseDate        time.Time `json:"release_date" db:"release_date"`
	Rating             *float64  `json:"rating" db:"rating"`
	ViewCount          int       `json:"view_count" db:"view_count"`
	VoteCount          int       `json:"vote_count" db:"vote_count"`
	ThumbnailImageURL  *string   `json:"thumbnail_image_url" db:"thumbnail_image_url"`
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
