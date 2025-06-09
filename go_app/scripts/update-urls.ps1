# URL Updater Script for Windows
# Usage: .\scripts\update-urls.ps1 -OldURL <old_url> -NewURL <new_url> [-DryRun] [-Verbose]

param(
    [Parameter(Mandatory=$true)]
    [string]$OldURL,
    
    [Parameter(Mandatory=$true)]
    [string]$NewURL,
    
    [switch]$DryRun = $true,
    [switch]$Verbose = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host "🔄 URL Updater - Update base URLs in database" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\scripts\update-urls.ps1 -OldURL <old_url> -NewURL <new_url> [options]"
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  -OldURL string    Old base URL to replace"
    Write-Host "  -NewURL string    New base URL to use"
    Write-Host "  -DryRun           Dry run mode (default: true)"
    Write-Host "  -Verbose          Verbose logging"
    Write-Host "  -Help             Show this help"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  # Preview changes (dry run)" -ForegroundColor Green
    Write-Host "  .\scripts\update-urls.ps1 \"
    Write-Host "    -OldURL 'https://storage.shngm.id' \"
    Write-Host "    -NewURL 'https://new-storage.shngm.id'"
    Write-Host ""
    Write-Host "  # Actually update URLs" -ForegroundColor Green
    Write-Host "  .\scripts\update-urls.ps1 \"
    Write-Host "    -OldURL 'https://storage.shngm.id' \"
    Write-Host "    -NewURL 'https://new-storage.shngm.id' \"
    Write-Host "    -DryRun:`$false"
    Write-Host ""
    Write-Host "  # Update with verbose logging" -ForegroundColor Green
    Write-Host "  .\scripts\update-urls.ps1 \"
    Write-Host "    -OldURL 'https://storage.shngm.id' \"
    Write-Host "    -NewURL 'https://new-storage.shngm.id' \"
    Write-Host "    -DryRun:`$false -Verbose"
    exit 0
}

Write-Host "🔄 URL Updater Starting..." -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Validate URLs
if (-not $OldURL.StartsWith("http")) {
    Write-Host "❌ Error: Old URL must start with http:// or https://" -ForegroundColor Red
    exit 1
}

if (-not $NewURL.StartsWith("http")) {
    Write-Host "❌ Error: New URL must start with http:// or https://" -ForegroundColor Red
    exit 1
}

# Build the application
Write-Host "🔨 Building URL updater..." -ForegroundColor Blue
go build -o url-updater.exe cmd/url-updater/main.go
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Build successful" -ForegroundColor Green
Write-Host ""

# Prepare arguments
$args = @(
    "-old=$OldURL",
    "-new=$NewURL"
)

if (-not $DryRun) {
    $args += "-dry-run=false"
}

if ($Verbose) {
    $args += "-verbose"
}

# Show what will be executed
Write-Host "📋 Execution Details:" -ForegroundColor Yellow
Write-Host "   Old URL: $OldURL" -ForegroundColor White
Write-Host "   New URL: $NewURL" -ForegroundColor White
Write-Host "   Dry Run: $DryRun" -ForegroundColor White
Write-Host "   Verbose: $Verbose" -ForegroundColor White
Write-Host ""

if ($DryRun) {
    Write-Host "🔍 DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
} else {
    Write-Host "⚡ LIVE UPDATE MODE - Changes will be applied" -ForegroundColor Red
    Write-Host ""
    $confirm = Read-Host "Are you sure you want to proceed? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "❌ Operation cancelled" -ForegroundColor Yellow
        exit 0
    }
}

Write-Host ""
Write-Host "🚀 Running URL updater..." -ForegroundColor Blue
Write-Host ""

# Execute the updater
& .\url-updater.exe @args

$exitCode = $LASTEXITCODE

# Cleanup
Remove-Item url-updater.exe -ErrorAction SilentlyContinue

Write-Host ""
if ($exitCode -eq 0) {
    if ($DryRun) {
        Write-Host "🔍 DRY RUN completed successfully!" -ForegroundColor Green
        Write-Host "💡 Run with -DryRun:`$false to apply changes" -ForegroundColor Yellow
    } else {
        Write-Host "✅ URL update completed successfully!" -ForegroundColor Green
    }
} else {
    Write-Host "❌ URL update failed with exit code: $exitCode" -ForegroundColor Red
    exit $exitCode
}

Write-Host ""
Write-Host "📖 For more information, see the documentation:" -ForegroundColor Cyan
Write-Host "   - API_CRAWLER.md" -ForegroundColor White
Write-Host "   - CRAWLING_GUIDE.md" -ForegroundColor White
