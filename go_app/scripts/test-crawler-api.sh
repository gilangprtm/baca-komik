#!/bin/bash

# Test crawler API endpoints
# Usage: ./scripts/test-crawler-api.sh [base-url]

BASE_URL=${1:-"https://baca-komik-production.up.railway.app"}
API_URL="$BASE_URL/api/crawler"

echo "🧪 Testing Crawler API at: $API_URL"
echo "=================================="

# Test 1: Check current status
echo ""
echo "📊 1. Checking current status..."
curl -s "$API_URL/status" | jq '.' || echo "❌ Status check failed"

# Test 2: Start small test crawling
echo ""
echo "🚀 2. Starting test crawling (manga pages 1-2)..."
curl -X POST "$API_URL/start" \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "manga",
    "start_page": 1,
    "end_page": 2,
    "batch_size": 5,
    "dry_run": false
  }' | jq '.' || echo "❌ Start crawling failed"

# Wait a bit
echo ""
echo "⏳ Waiting 10 seconds..."
sleep 10

# Test 3: Check status again
echo ""
echo "📊 3. Checking status after start..."
curl -s "$API_URL/status" | jq '.' || echo "❌ Status check failed"

# Test 4: Test stop (optional)
echo ""
echo "🛑 4. Testing stop crawling..."
read -p "Do you want to stop the crawling? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -X POST "$API_URL/stop" | jq '.' || echo "❌ Stop crawling failed"
fi

echo ""
echo "✅ API testing completed!"
echo ""
echo "🔧 Available endpoints:"
echo "   GET  $API_URL/status"
echo "   POST $API_URL/start"
echo "   POST $API_URL/stop"
echo "   POST $API_URL/resume"
echo ""
echo "📖 For full documentation, see: CRAWLING_GUIDE.md"
