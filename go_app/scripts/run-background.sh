#!/bin/bash

# Background crawler runner with automatic restart and monitoring
# Usage: ./scripts/run-background.sh [mode] [options]

set -e

MODE=${1:-"all"}
LOG_DIR="./logs"
PID_FILE="./crawler.pid"
CHECKPOINT_FILE="./crawler_checkpoint.json"

# Create logs directory
mkdir -p $LOG_DIR

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a $LOG_DIR/crawler.log
}

# Function to check if crawler is running
is_running() {
    if [ -f $PID_FILE ]; then
        PID=$(cat $PID_FILE)
        if ps -p $PID > /dev/null 2>&1; then
            return 0
        else
            rm -f $PID_FILE
            return 1
        fi
    fi
    return 1
}

# Function to start crawler
start_crawler() {
    if is_running; then
        log "❌ Crawler is already running (PID: $(cat $PID_FILE))"
        exit 1
    fi
    
    log "🚀 Starting crawler in background mode: $MODE"
    
    # Start crawler in background
    nohup ./crawler --mode=$MODE --verbose "${@:2}" > $LOG_DIR/crawler-$(date +%Y%m%d-%H%M%S).log 2>&1 &
    PID=$!
    echo $PID > $PID_FILE
    
    log "✅ Crawler started with PID: $PID"
    log "📄 Logs: $LOG_DIR/crawler-$(date +%Y%m%d-%H%M%S).log"
    log "📊 Check progress: ./crawler --mode=status"
}

# Function to stop crawler
stop_crawler() {
    if ! is_running; then
        log "❌ Crawler is not running"
        exit 1
    fi
    
    PID=$(cat $PID_FILE)
    log "🛑 Stopping crawler (PID: $PID)..."
    
    kill $PID
    sleep 2
    
    if ps -p $PID > /dev/null 2>&1; then
        log "⚠️  Force killing crawler..."
        kill -9 $PID
    fi
    
    rm -f $PID_FILE
    log "✅ Crawler stopped"
}

# Function to restart crawler
restart_crawler() {
    log "🔄 Restarting crawler..."
    if is_running; then
        stop_crawler
    fi
    sleep 1
    start_crawler "$@"
}

# Function to show status
show_status() {
    if is_running; then
        PID=$(cat $PID_FILE)
        log "✅ Crawler is running (PID: $PID)"
        
        # Show checkpoint status if available
        if [ -f $CHECKPOINT_FILE ]; then
            log "📊 Showing progress..."
            ./crawler --mode=status
        fi
    else
        log "❌ Crawler is not running"
    fi
}

# Function to monitor crawler (auto-restart if crashed)
monitor_crawler() {
    log "👁️  Starting crawler monitor..."
    
    while true; do
        if ! is_running; then
            log "⚠️  Crawler not running, attempting restart..."
            start_crawler "$@"
        fi
        
        # Check every 30 seconds
        sleep 30
    done
}

# Main script logic
case "${1:-start}" in
    start)
        start_crawler "${@:2}"
        ;;
    stop)
        stop_crawler
        ;;
    restart)
        restart_crawler "${@:2}"
        ;;
    status)
        show_status
        ;;
    monitor)
        monitor_crawler "${@:2}"
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|monitor} [crawler-mode] [options]"
        echo ""
        echo "Examples:"
        echo "  $0 start all                    # Start full crawling"
        echo "  $0 start manga --end-page=-1    # Start manga crawling (all pages)"
        echo "  $0 restart                      # Restart current crawling"
        echo "  $0 status                       # Show current status"
        echo "  $0 monitor all                  # Start with auto-restart monitoring"
        echo "  $0 stop                         # Stop crawling"
        exit 1
        ;;
esac
