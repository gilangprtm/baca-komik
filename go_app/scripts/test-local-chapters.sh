#!/bin/bash

# Test chapters crawling locally with limited data
# Usage: ./scripts/test-local-chapters.sh

echo "🧪 Local Chapters Crawling Test"
echo "==============================="
echo "Testing with first 10 manga from database"
echo ""

# Build the application
echo "🔨 Building application..."
go build -o main .
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi
echo "✅ Build successful"
echo ""

# Test with CLI crawler
echo "🚀 Starting local chapters crawling test..."
echo "Mode: chapters (first 10 manga)"
echo ""

# Run crawler with verbose logging
./main --mode=chapters --verbose --dry-run=false

echo ""
echo "✅ Local test completed!"
echo ""
echo "📊 Check your database to verify results:"
echo "   - mChapter table should have new records"
echo "   - Check external_id field is populated"
echo "   - Verify chapter data is correct"
