#!/bin/bash

# Deploy to Railway script
# Usage: ./scripts/deploy-railway.sh

set -e

echo "🚀 Deploying crawler updates to Railway..."

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Installing..."
    npm install -g @railway/cli
fi

# Check if logged in
if ! railway whoami &> /dev/null; then
    echo "🔐 Please login to Railway..."
    railway login
fi

# Build and test locally first
echo "🔨 Building application..."
go build -o crawler cmd/crawler/main.go
go build -o main main.go

echo "✅ Build successful!"

# Deploy to Railway
echo "📤 Deploying to Railway..."
railway up

echo "🎉 Deployment completed!"
echo ""
echo "🌐 Your app is available at:"
echo "   https://baca-komik-production.up.railway.app/"
echo ""
echo "🔧 Crawler endpoints:"
echo "   POST /api/crawler/start   - Start crawling"
echo "   GET  /api/crawler/status  - Check status"
echo "   POST /api/crawler/stop    - Stop crawling"
echo "   POST /api/crawler/resume  - Resume crawling"
echo ""
echo "📊 Test the endpoints:"
echo "   curl https://baca-komik-production.up.railway.app/api/crawler/status"
echo ""
echo "🚀 Start crawling:"
echo "   curl -X POST https://baca-komik-production.up.railway.app/api/crawler/start \\"
echo "        -H 'Content-Type: application/json' \\"
echo "        -d '{\"mode\": \"manga\", \"start_page\": 1, \"end_page\": 10}'"

# Cleanup
rm -f crawler main

echo ""
echo "✅ Ready for production crawling!"
