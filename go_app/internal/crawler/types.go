package crawler

import "time"

// API Response structures for external API

type APIResponse struct {
	RetCode   int         `json:"retcode"`
	Message   string      `json:"message"`
	Meta      APIMeta     `json:"meta"`
	Data      interface{} `json:"data"`
}

type APIMeta struct {
	RequestID   string `json:"request_id"`
	Timestamp   int64  `json:"timestamp"`
	ProcessTime string `json:"process_time"`
	Page        *int   `json:"page,omitempty"`
	PageSize    *int   `json:"page_size,omitempty"`
	TotalPage   *int   `json:"total_page,omitempty"`
	TotalRecord *int   `json:"total_record,omitempty"`
}

// Pagination for list endpoints
type PaginatedResponse struct {
	RetCode int     `json:"retcode"`
	Message string  `json:"message"`
	Meta    APIMeta `json:"meta"`
	Data    struct {
		Data       interface{} `json:"data"`
		Pagination Pagination  `json:"pagination"`
	} `json:"data"`
}

// Manga list response (different structure)
type MangaListResponse struct {
	RetCode int             `json:"retcode"`
	Message string          `json:"message"`
	Meta    APIMeta         `json:"meta"`
	Data    []ExternalManga `json:"data"`
	Facet   interface{}     `json:"facet"`
}

type Pagination struct {
	Page      int `json:"page"`
	PageSize  int `json:"page_size"`
	Total     int `json:"total"`
	TotalPage int `json:"total_page"`
}

// External API data structures
type ExternalGenre struct {
	Slug string `json:"slug"`
	Name string `json:"name"`
}

type ExternalFormat struct {
	Slug string `json:"slug"`
	Name string `json:"name"`
}

type ExternalType struct {
	Slug string `json:"slug"`
	Name string `json:"name"`
}

type ExternalAuthor struct {
	Slug string `json:"slug"`
	Name string `json:"name"`
}

type ExternalArtist struct {
	Slug string `json:"slug"`
	Name string `json:"name"`
}

type ExternalManga struct {
	ID               string    `json:"manga_id"`
	Title            string    `json:"title"`
	AlternativeTitle *string   `json:"alternative_title"`
	Description      *string   `json:"description"`
	Status           int       `json:"status"`
	CountryID        string    `json:"country_id"`
	ViewCount        *int      `json:"view_count"`
	VoteCount        *int      `json:"vote_count"`
	BookmarkCount    *int      `json:"bookmark_count"`
	CoverImageURL    *string   `json:"cover_image_url"`
	CreatedAt        *time.Time `json:"created_at"`
	Rank             *float64  `json:"rank"`
	ReleaseYear      *string   `json:"release_year"`
	IsRecommended    bool      `json:"is_recommended"`
	UserRate         float64   `json:"user_rate"`
	Taxonomy         *ExternalTaxonomy `json:"taxonomy,omitempty"`
}

// Taxonomy structure from API
type ExternalTaxonomy struct {
	Artist []ExternalArtist `json:"Artist"`
	Author []ExternalAuthor `json:"Author"`
	Format []ExternalFormat `json:"Format"`
	Genre  []ExternalGenre  `json:"Genre"`
	Type   []ExternalType   `json:"Type"`
}

type ExternalChapter struct {
	ID                string     `json:"chapter_id"`
	MangaID           string     `json:"manga_id"`
	ChapterNumber     float64    `json:"chapter_number"`
	ChapterTitle      *string    `json:"chapter_title"`
	ReleaseDate       *time.Time `json:"release_date"`
	ViewCount         *int       `json:"view_count"`
	ThumbnailImageURL *string    `json:"thumbnail_image_url"`
	CreatedAt         *time.Time `json:"created_at"`
	UpdatedAt         *time.Time `json:"updated_at"`
}

type ExternalChapterDetail struct {
	ChapterID         string    `json:"chapter_id"`
	MangaID           string    `json:"manga_id"`
	ChapterNumber     float64   `json:"chapter_number"`
	ChapterTitle      string    `json:"chapter_title"`
	BaseURL           string    `json:"base_url"`
	BaseURLLow        string    `json:"base_url_low"`
	Chapter           ChapterPages `json:"chapter"`
	ThumbnailImageURL string    `json:"thumbnail_image_url"`
	ViewCount         int       `json:"view_count"`
	PrevChapterID     *string   `json:"prev_chapter_id"`
	PrevChapterNumber *float64  `json:"prev_chapter_number"`
	NextChapterID     *string   `json:"next_chapter_id"`
	NextChapterNumber *float64  `json:"next_chapter_number"`
	ReleaseDate       time.Time `json:"release_date"`
	CreatedAt         time.Time `json:"created_at"`
	UpdatedAt         time.Time `json:"updated_at"`
}

type ChapterPages struct {
	Path string   `json:"path"`
	Data []string `json:"data"`
}

// Progress tracking
type CrawlProgress struct {
	Mode        string    `json:"mode"`
	StartTime   time.Time `json:"start_time"`
	EndTime     *time.Time `json:"end_time"`
	Total       int       `json:"total"`
	Processed   int       `json:"processed"`
	Success     int       `json:"success"`
	Failed      int       `json:"failed"`
	CurrentPage int       `json:"current_page"`
	Status      string    `json:"status"` // running, completed, failed
}

// URL Configuration for database
type URLConfig struct {
	ID          string    `json:"id" db:"id"`
	ServiceName string    `json:"service_name" db:"service_name"`
	URLType     string    `json:"url_type" db:"url_type"`
	URLValue    string    `json:"url_value" db:"url_value"`
	IsActive    bool      `json:"is_active" db:"is_active"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}
