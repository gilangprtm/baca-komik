# Test pages crawling locally with limited data
# Usage: .\scripts\test-local-pages.ps1

Write-Host "🧪 Local Pages Crawling Test" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Testing pages for chapters from previous test" -ForegroundColor Yellow
Write-Host ""

# Build the application
Write-Host "🔨 Building application..." -ForegroundColor Blue
go build -o main.exe .
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Build successful" -ForegroundColor Green
Write-Host ""

# Test with CLI crawler
Write-Host "🚀 Starting local pages crawling test..." -ForegroundColor Blue
Write-Host "Mode: pages (for existing chapters)" -ForegroundColor Yellow
Write-Host ""

# Run crawler with verbose logging
.\main.exe --mode=pages --verbose --dry-run=false

Write-Host ""
Write-Host "✅ Local test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Check your database to verify results:" -ForegroundColor Cyan
Write-Host "   - mChapter.pages_data should be populated" -ForegroundColor White
Write-Host "   - Check JSON structure with base_url, path, data" -ForegroundColor White
Write-Host "   - Verify image filenames are correct" -ForegroundColor White
