package crawler

// Config holds crawler configuration
type Config struct {
	BaseURL   string
	BatchSize int
	DryRun    bool
	Verbose   bool
	Headers   map[string]string
}

// Default headers for API requests
func DefaultHeaders() map[string]string {
	return map[string]string{
		"User-Agent":      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36",
		"Origin":          "https://app.shinigami.asia",
		"Referer":         "https://app.shinigami.asia/",
		"Sec-Fetch-Mode":  "cors",
		"Sec-Fetch-Site":  "cross-site",
		"Accept":          "application/json, text/plain, */*",
		"Accept-Language": "en-US,en;q=0.9",
	}
}
