#!/bin/bash

# Monitor crawling progress
# Usage: ./scripts/monitor-crawling.sh [base-url] [interval]

BASE_URL=${1:-"https://baca-komik-production.up.railway.app"}
INTERVAL=${2:-60}  # Default 60 seconds
API_URL="$BASE_URL/api/crawler"

echo "📊 Crawling Progress Monitor"
echo "============================"
echo "API URL: $API_URL"
echo "Check interval: ${INTERVAL}s"
echo "Press Ctrl+C to stop monitoring"
echo ""

# Function to get timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Function to check status
check_status() {
    local timestamp=$(get_timestamp)
    echo "[$timestamp] Checking status..."
    
    response=$(curl -s "$API_URL/status")
    
    if [[ $? -eq 0 ]]; then
        # Check if jq is available
        if command -v jq &> /dev/null; then
            success=$(echo "$response" | jq -r '.success // false')
            
            if [[ "$success" == "true" ]]; then
                data=$(echo "$response" | jq -r '.data')
                
                if [[ "$data" != "null" ]]; then
                    # Extract key metrics
                    phase=$(echo "$response" | jq -r '.data.phase // "unknown"')
                    current_page=$(echo "$response" | jq -r '.data.current_page // 0')
                    total_processed=$(echo "$response" | jq -r '.data.total_processed // 0')
                    estimated_total=$(echo "$response" | jq -r '.data.estimated_total // 0')
                    progress_percent=$(echo "$response" | jq -r '.data.progress_percent // 0')
                    eta=$(echo "$response" | jq -r '.data.eta // "unknown"')
                    success_count=$(echo "$response" | jq -r '.data.success_count // 0')
                    error_count=$(echo "$response" | jq -r '.data.error_count // 0')
                    
                    echo "🚀 Phase: $phase"
                    echo "📄 Page: $current_page"
                    echo "📊 Progress: $total_processed/$estimated_total (${progress_percent}%)"
                    echo "⏳ ETA: $eta"
                    echo "✅ Success: $success_count | ❌ Errors: $error_count"
                    
                    # Progress bar
                    if [[ "$estimated_total" -gt 0 ]]; then
                        progress_int=$(echo "$progress_percent" | cut -d'.' -f1)
                        bar_length=50
                        filled_length=$((progress_int * bar_length / 100))
                        
                        printf "["
                        for ((i=0; i<filled_length; i++)); do printf "█"; done
                        for ((i=filled_length; i<bar_length; i++)); do printf "░"; done
                        printf "] ${progress_percent}%%\n"
                    fi
                else
                    echo "💤 No active crawling session"
                fi
            else
                message=$(echo "$response" | jq -r '.message // "Unknown error"')
                echo "❌ Error: $message"
            fi
        else
            # Fallback without jq
            echo "$response"
        fi
    else
        echo "❌ Failed to connect to API"
    fi
    
    echo "----------------------------------------"
}

# Function to handle Ctrl+C
cleanup() {
    echo ""
    echo "🛑 Monitoring stopped"
    echo "📊 Final status check..."
    check_status
    exit 0
}

# Set up signal handler
trap cleanup SIGINT

# Initial status check
echo "🔍 Initial status check..."
check_status

# Start monitoring loop
echo "🔄 Starting monitoring (every ${INTERVAL}s)..."
echo ""

while true; do
    sleep "$INTERVAL"
    check_status
done
