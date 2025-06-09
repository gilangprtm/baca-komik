# Test chapters crawling locally with limited data
# Usage: .\scripts\test-local-chapters.ps1

Write-Host "🧪 Local Chapters Crawling Test" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "Testing with first 10 manga from database" -ForegroundColor Yellow
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
Write-Host "🚀 Starting local chapters crawling test..." -ForegroundColor Blue
Write-Host "Mode: chapters (first 10 manga)" -ForegroundColor Yellow
Write-Host ""

# Run crawler with verbose logging
.\main.exe --mode=chapters --verbose --dry-run=false

Write-Host ""
Write-Host "✅ Local test completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Check your database to verify results:" -ForegroundColor Cyan
Write-Host "   - mChapter table should have new records" -ForegroundColor White
Write-Host "   - Check external_id field is populated" -ForegroundColor White
Write-Host "   - Verify chapter data is correct" -ForegroundColor White
