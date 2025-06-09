#!/bin/bash

# Deployment script for crawler to cloud server
# Usage: ./scripts/deploy.sh [server-ip] [username]

set -e

SERVER_IP=${1:-"your-server-ip"}
USERNAME=${2:-"root"}
APP_NAME="baca-komik-crawler"
REMOTE_DIR="/opt/$APP_NAME"

echo "🚀 Deploying crawler to $USERNAME@$SERVER_IP..."

# Build the application
echo "📦 Building application..."
go build -o crawler cmd/crawler/main.go

# Create deployment package
echo "📦 Creating deployment package..."
tar -czf crawler-deploy.tar.gz \
    crawler \
    .env.example \
    scripts/run-background.sh \
    scripts/monitor.sh \
    scripts/systemd/crawler.service

# Upload to server
echo "📤 Uploading to server..."
scp crawler-deploy.tar.gz $USERNAME@$SERVER_IP:/tmp/

# Deploy on server
echo "🔧 Deploying on server..."
ssh $USERNAME@$SERVER_IP << EOF
    # Create application directory
    sudo mkdir -p $REMOTE_DIR
    cd $REMOTE_DIR
    
    # Extract files
    sudo tar -xzf /tmp/crawler-deploy.tar.gz
    sudo chmod +x crawler
    sudo chmod +x scripts/*.sh
    
    # Setup environment
    if [ ! -f .env ]; then
        sudo cp .env.example .env
        echo "⚠️  Please edit .env file with your database credentials"
    fi
    
    # Install systemd service
    sudo cp scripts/systemd/crawler.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable crawler
    
    # Cleanup
    rm /tmp/crawler-deploy.tar.gz
    
    echo "✅ Deployment completed!"
    echo "📝 Next steps:"
    echo "   1. Edit $REMOTE_DIR/.env with your database credentials"
    echo "   2. Start crawler: sudo systemctl start crawler"
    echo "   3. Check status: sudo systemctl status crawler"
    echo "   4. View logs: sudo journalctl -u crawler -f"
EOF

# Cleanup local files
rm crawler-deploy.tar.gz

echo "🎉 Deployment completed successfully!"
echo ""
echo "🔧 Server commands:"
echo "   Start crawler:    sudo systemctl start crawler"
echo "   Stop crawler:     sudo systemctl stop crawler"
echo "   Restart crawler:  sudo systemctl restart crawler"
echo "   Check status:     sudo systemctl status crawler"
echo "   View logs:        sudo journalctl -u crawler -f"
echo "   Check progress:   cd $REMOTE_DIR && ./crawler --mode=status"
