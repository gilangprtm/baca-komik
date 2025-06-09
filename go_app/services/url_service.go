package services

import (
	"fmt"
	"strings"
)

// URLService handles URL construction and management
type URLService struct {
	baseURL    string
	baseURLLow string
}

// NewURLService creates a new URL service instance
func NewURLService() *URLService {
	return &URLService{
		baseURL:    "https://storage.shngm.id",
		baseURLLow: "https://storage.shngm.id/low/unsafe/filters:format(webp):quality(70)",
	}
}

// GetFullImageURL constructs full image URL from relative path
func (u *URLService) GetFullImageURL(relativePath string, isLowQuality bool) string {
	if relativePath == "" {
		return ""
	}
	
	// If already full URL, return as-is
	if strings.HasPrefix(relativePath, "http") {
		return relativePath
	}
	
	// Ensure relative path starts with /
	if !strings.HasPrefix(relativePath, "/") {
		relativePath = "/" + relativePath
	}
	
	if isLowQuality {
		return u.baseURLLow + relativePath
	}
	return u.baseURL + relativePath
}

// GetCoverImageURL constructs cover image URL
func (u *URLService) GetCoverImageURL(relativePath string, isLowQuality bool) string {
	return u.GetFullImageURL(relativePath, isLowQuality)
}

// GetThumbnailImageURL constructs thumbnail image URL
func (u *URLService) GetThumbnailImageURL(relativePath string, isLowQuality bool) string {
	return u.GetFullImageURL(relativePath, isLowQuality)
}

// GetChapterPageURL constructs chapter page image URL
func (u *URLService) GetChapterPageURL(relativePath string, isLowQuality bool) string {
	return u.GetFullImageURL(relativePath, isLowQuality)
}

// UpdateBaseURL updates the base URL (for when external service changes)
func (u *URLService) UpdateBaseURL(newBaseURL, newBaseURLLow string) {
	u.baseURL = newBaseURL
	u.baseURLLow = newBaseURLLow
}

// GetBaseURL returns current base URL
func (u *URLService) GetBaseURL(isLowQuality bool) string {
	if isLowQuality {
		return u.baseURLLow
	}
	return u.baseURL
}

// ConvertToRelativePath converts full URL to relative path
func (u *URLService) ConvertToRelativePath(fullURL string) string {
	if fullURL == "" {
		return ""
	}
	
	// Remove base URLs to get relative path
	baseURLs := []string{
		u.baseURLLow,
		u.baseURL,
	}
	
	for _, baseURL := range baseURLs {
		if strings.HasPrefix(fullURL, baseURL) {
			return strings.TrimPrefix(fullURL, baseURL)
		}
	}
	
	// If no base URL matches, return as-is (might already be relative)
	return fullURL
}

// BatchConvertURLs converts multiple URLs to relative paths
func (u *URLService) BatchConvertURLs(urls []string) []string {
	result := make([]string, len(urls))
	for i, url := range urls {
		result[i] = u.ConvertToRelativePath(url)
	}
	return result
}

// BatchConstructURLs constructs multiple full URLs from relative paths
func (u *URLService) BatchConstructURLs(relativePaths []string, isLowQuality bool) []string {
	result := make([]string, len(relativePaths))
	for i, path := range relativePaths {
		result[i] = u.GetFullImageURL(path, isLowQuality)
	}
	return result
}

// ValidateURL checks if URL is valid
func (u *URLService) ValidateURL(url string) bool {
	if url == "" {
		return false
	}
	
	// Check if it's a valid relative path or full URL
	return strings.HasPrefix(url, "/") || strings.HasPrefix(url, "http")
}

// GetURLInfo returns information about URL
func (u *URLService) GetURLInfo(url string) map[string]interface{} {
	info := map[string]interface{}{
		"original_url": url,
		"is_relative": !strings.HasPrefix(url, "http"),
		"is_valid":    u.ValidateURL(url),
	}
	
	if info["is_relative"].(bool) {
		info["full_url"] = u.GetFullImageURL(url, false)
		info["full_url_low"] = u.GetFullImageURL(url, true)
	} else {
		info["relative_path"] = u.ConvertToRelativePath(url)
	}
	
	return info
}

// Example usage in API responses:
// 
// type MangaResponse struct {
//     ID           string `json:"id"`
//     Title        string `json:"title"`
//     CoverImageURL string `json:"cover_image_url"`
// }
//
// func (h *Handler) GetManga(c *gin.Context) {
//     // Get manga from database (with relative path)
//     manga := getMangaFromDB()
//     
//     // Construct full URL for response
//     urlService := NewURLService()
//     response := MangaResponse{
//         ID:            manga.ID,
//         Title:         manga.Title,
//         CoverImageURL: urlService.GetCoverImageURL(manga.CoverImageURL, false),
//     }
//     
//     c.JSON(200, response)
// }
