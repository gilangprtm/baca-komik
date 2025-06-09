#!/bin/bash

# URL Updater Script for Linux/Mac
# Usage: ./scripts/update-urls.sh -o <old_url> -n <new_url> [-d] [-v] [-h]

# Default values
DRY_RUN=true
VERBOSE=false
OLD_URL=""
NEW_URL=""

# Function to show help
show_help() {
    echo "🔄 URL Updater - Update base URLs in database"
    echo ""
    echo "Usage:"
    echo "  ./scripts/update-urls.sh -o <old_url> -n <new_url> [options]"
    echo ""
    echo "Options:"
    echo "  -o, --old-url     Old base URL to replace"
    echo "  -n, --new-url     New base URL to use"
    echo "  -d, --live        Live update mode (disable dry run)"
    echo "  -v, --verbose     Verbose logging"
    echo "  -h, --help        Show this help"
    echo ""
    echo "Examples:"
    echo "  # Preview changes (dry run)"
    echo "  ./scripts/update-urls.sh \\"
    echo "    -o 'https://storage.shngm.id' \\"
    echo "    -n 'https://new-storage.shngm.id'"
    echo ""
    echo "  # Actually update URLs"
    echo "  ./scripts/update-urls.sh \\"
    echo "    -o 'https://storage.shngm.id' \\"
    echo "    -n 'https://new-storage.shngm.id' \\"
    echo "    --live"
    echo ""
    echo "  # Update with verbose logging"
    echo "  ./scripts/update-urls.sh \\"
    echo "    -o 'https://storage.shngm.id' \\"
    echo "    -n 'https://new-storage.shngm.id' \\"
    echo "    --live --verbose"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--old-url)
            OLD_URL="$2"
            shift 2
            ;;
        -n|--new-url)
            NEW_URL="$2"
            shift 2
            ;;
        -d|--live)
            DRY_RUN=false
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$OLD_URL" || -z "$NEW_URL" ]]; then
    echo "❌ Error: Both old URL and new URL are required"
    echo "Use -h or --help for usage information"
    exit 1
fi

# Validate URLs
if [[ ! "$OLD_URL" =~ ^https?:// ]]; then
    echo "❌ Error: Old URL must start with http:// or https://"
    exit 1
fi

if [[ ! "$NEW_URL" =~ ^https?:// ]]; then
    echo "❌ Error: New URL must start with http:// or https://"
    exit 1
fi

echo "🔄 URL Updater Starting..."
echo "================================="
echo ""

# Build the application
echo "🔨 Building URL updater..."
go build -o url-updater cmd/url-updater/main.go
if [[ $? -ne 0 ]]; then
    echo "❌ Build failed!"
    exit 1
fi
echo "✅ Build successful"
echo ""

# Prepare arguments
ARGS=("-old=$OLD_URL" "-new=$NEW_URL")

if [[ "$DRY_RUN" == false ]]; then
    ARGS+=("-dry-run=false")
fi

if [[ "$VERBOSE" == true ]]; then
    ARGS+=("-verbose")
fi

# Show execution details
echo "📋 Execution Details:"
echo "   Old URL: $OLD_URL"
echo "   New URL: $NEW_URL"
echo "   Dry Run: $DRY_RUN"
echo "   Verbose: $VERBOSE"
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo "🔍 DRY RUN MODE - No changes will be made"
else
    echo "⚡ LIVE UPDATE MODE - Changes will be applied"
    echo ""
    read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Operation cancelled"
        rm -f url-updater
        exit 0
    fi
fi

echo ""
echo "🚀 Running URL updater..."
echo ""

# Execute the updater
./url-updater "${ARGS[@]}"
EXIT_CODE=$?

# Cleanup
rm -f url-updater

echo ""
if [[ $EXIT_CODE -eq 0 ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        echo "🔍 DRY RUN completed successfully!"
        echo "💡 Run with --live to apply changes"
    else
        echo "✅ URL update completed successfully!"
    fi
else
    echo "❌ URL update failed with exit code: $EXIT_CODE"
    exit $EXIT_CODE
fi

echo ""
echo "📖 For more information, see the documentation:"
echo "   - API_CRAWLER.md"
echo "   - CRAWLING_GUIDE.md"
