#!/bin/bash

# Complete API test for crawler endpoints
# Usage: ./scripts/test-api-complete.sh [base-url]

BASE_URL=${1:-"https://baca-komik-production.up.railway.app"}
API_URL="$BASE_URL/api/crawler"

echo "🧪 Complete Crawler API Test"
echo "============================="
echo "Base URL: $BASE_URL"
echo "API URL: $API_URL"
echo ""

# Function to test endpoint with error handling
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo "📡 Testing: $description"
    echo "   $method $endpoint"
    
    if [[ "$method" == "GET" ]]; then
        response=$(curl -s -w "\n%{http_code}" "$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$endpoint" \
                   -H "Content-Type: application/json" \
                   -d "$data")
    fi
    
    # Extract HTTP code and body
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n -1)
    
    if [[ "$http_code" -ge 200 && "$http_code" -lt 300 ]]; then
        echo "✅ Success ($http_code)"
        if command -v jq &> /dev/null; then
            echo "$body" | jq '.' 2>/dev/null || echo "$body"
        else
            echo "$body"
        fi
    else
        echo "❌ Failed ($http_code)"
        echo "$body"
    fi
    echo ""
}

# Test 1: Health check
test_endpoint "GET" "$BASE_URL/health" "" "Health check"

# Test 2: API root
test_endpoint "GET" "$BASE_URL/" "" "API root"

# Test 3: Check current status
test_endpoint "GET" "$API_URL/status" "" "Current crawling status"

# Test 4: Interactive test options
echo "🎯 Interactive Tests"
echo "==================="

# Test start crawling
echo ""
echo "🚀 Test Start Crawling"
echo "Options:"
echo "  1. Small test (manga pages 1-2)"
echo "  2. Medium test (manga pages 1-10)" 
echo "  3. Master data only (auto mode)"
echo "  4. Skip"
echo ""
read -p "Choose option (1-4): " -n 1 -r
echo ""

case $REPLY in
    1)
        test_data='{"mode": "manga", "start_page": 1, "end_page": 2, "batch_size": 5}'
        test_endpoint "POST" "$API_URL/start" "$test_data" "Start small test crawling"
        ;;
    2)
        test_data='{"mode": "manga", "start_page": 1, "end_page": 10, "batch_size": 10}'
        test_endpoint "POST" "$API_URL/start" "$test_data" "Start medium test crawling"
        ;;
    3)
        test_data='{"mode": "auto"}'
        test_endpoint "POST" "$API_URL/start" "$test_data" "Start master data crawling"
        ;;
    *)
        echo "⏭️ Skipping start test"
        ;;
esac

# If we started crawling, wait and check status
if [[ $REPLY =~ ^[1-3]$ ]]; then
    echo "⏳ Waiting 15 seconds for crawling to start..."
    sleep 15
    test_endpoint "GET" "$API_URL/status" "" "Status after starting"
fi

# Test stop
echo ""
echo "🛑 Test Stop Crawling"
read -p "Test stop crawling? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    test_endpoint "POST" "$API_URL/stop" "" "Stop crawling"
fi

# Test resume
echo ""
echo "🔄 Test Resume Crawling"
read -p "Test resume crawling? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    test_endpoint "POST" "$API_URL/resume" "" "Resume crawling"
fi

# Final status check
echo ""
echo "📊 Final Status Check"
test_endpoint "GET" "$API_URL/status" "" "Final crawling status"

echo ""
echo "🎉 Testing completed!"
echo ""
echo "📋 Summary of endpoints:"
echo "   ✅ GET  $API_URL/status     - Check crawling status"
echo "   ✅ POST $API_URL/start      - Start new crawling job"
echo "   ✅ POST $API_URL/stop       - Stop current crawling"
echo "   ✅ POST $API_URL/resume     - Resume from checkpoint"
echo ""
echo "📖 Documentation:"
echo "   - API_CRAWLER.md - Complete API documentation"
echo "   - CRAWLING_GUIDE.md - Usage guide"
echo ""
echo "🌐 Quick links:"
echo "   - Status: $API_URL/status"
echo "   - Health: $BASE_URL/health"
echo "   - API Root: $BASE_URL/"
