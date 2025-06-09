# 🚀 Crawler API Documentation

## Base URL

```
https://baca-komik-production.up.railway.app/api/crawler
```

## 📋 Available Endpoints

### 1. 🚀 Start Crawling

**POST** `/start`

Start a new crawling job.

#### Request Body:

```json
{
  "mode": "manga", // Required: "auto", "manga", "chapters", "pages", "all"
  "start_page": 1, // Optional: start page (default: 1)
  "end_page": 10, // Optional: end page (-1 = all pages)
  "batch_size": 10, // Optional: batch size (default: 10)
  "manga_id": "", // Optional: specific manga ID for chapters (empty = all manga)
  "dry_run": false // Optional: test mode (default: false)
}
```

#### Response:

```json
{
  "success": true,
  "message": "Crawling job started in background: manga",
  "start_time": "2025-06-09T12:00:00Z",
  "job_id": "crawl_manga_1717934400",
  "data": {
    "job_id": "crawl_manga_1717934400",
    "status": "running"
  }
}
```

#### Examples:

```bash
# Start manga crawling (pages 1-100)
curl -X POST https://baca-komik-production.up.railway.app/api/crawler/start \
  -H "Content-Type: application/json" \
  -d '{
    "mode": "manga",
    "start_page": 1,
    "end_page": 100
  }'

# Start all master data crawling
curl -X POST https://baca-komik-production.up.railway.app/api/crawler/start \
  -H "Content-Type: application/json" \
  -d '{"mode": "auto"}'

# Start complete crawling (everything)
curl -X POST https://baca-komik-production.up.railway.app/api/crawler/start \
  -H "Content-Type: application/json" \
  -d '{"mode": "all"}'

# Start chapters crawling (all manga automatically)
curl -X POST https://baca-komik-production.up.railway.app/api/crawler/start \
  -H "Content-Type: application/json" \
  -d '{"mode": "chapters"}'

# Start pages crawling (all chapters automatically)
curl -X POST https://baca-komik-production.up.railway.app/api/crawler/start \
  -H "Content-Type: application/json" \
  -d '{"mode": "pages"}'
```

### 2. 📊 Check Status

**GET** `/status`

Get current crawling progress and statistics.

#### Response:

```json
{
  "success": true,
  "message": "Crawling status retrieved",
  "data": {
    "phase": "manga",
    "current_page": 45,
    "total_processed": 1080,
    "estimated_total": 2400,
    "progress_percent": 45.0,
    "elapsed_time": "15m30s",
    "eta": "18m45s",
    "success_count": 1075,
    "error_count": 5,
    "last_update": "2025-06-09T12:15:30Z"
  }
}
```

#### Example:

```bash
curl https://baca-komik-production.up.railway.app/api/crawler/status
```

### 3. 🛑 Stop Crawling

**POST** `/stop`

Stop current crawling job and clear checkpoint.

#### Response:

```json
{
  "success": true,
  "message": "Crawling stopped and checkpoint cleared"
}
```

#### Example:

```bash
curl -X POST https://baca-komik-production.up.railway.app/api/crawler/stop
```

### 4. 🔄 Resume Crawling

**POST** `/resume`

Resume crawling from last checkpoint.

#### Response:

```json
{
  "success": true,
  "message": "Resuming manga crawling from page 45",
  "start_time": "2025-06-09T12:20:00Z",
  "data": {
    "phase": "manga",
    "current_page": 45,
    "total_processed": 1080
  }
}
```

#### Example:

```bash
curl -X POST https://baca-komik-production.up.railway.app/api/crawler/resume
```

### 5. 📈 Get History

**GET** `/history`

Get crawling history and statistics.

#### Response:

```json
{
  "success": true,
  "message": "Crawl history retrieved",
  "data": {
    "jobs": [
      {
        "id": "crawl_chapters_1717934400",
        "mode": "chapters",
        "status": "running",
        "start_time": "2025-06-09T12:00:00Z",
        "progress": {
          "current_step": "Processing chapters...",
          "percentage": 45.5
        }
      }
    ],
    "total": 1
  }
}
```

### 6. 🔍 Get Job Status

**GET** `/jobs/{job_id}`

Get status of specific crawling job.

#### Response:

```json
{
  "success": true,
  "message": "Job status retrieved",
  "data": {
    "job_id": "crawl_chapters_1717934400",
    "mode": "chapters",
    "status": "running",
    "current_step": "Processing chapters...",
    "progress_percent": 45.5,
    "elapsed_time": "15m30s",
    "start_time": "2025-06-09T12:00:00Z"
  }
}
```

## 🎯 Crawling Modes

| Mode       | Description                              | Estimated Time |
| ---------- | ---------------------------------------- | -------------- |
| `auto`     | Master data only (genres, authors, etc.) | 2-5 minutes    |
| `manga`    | Manga list crawling                      | 2-4 hours      |
| `chapters` | All chapters for existing manga          | 4-8 hours      |
| `pages`    | All pages for existing chapters          | 8-16 hours     |
| `all`      | Complete crawling (everything)           | 1-2 days       |

## 📊 Monitoring Workflow

### 1. Start Crawling

```bash
curl -X POST .../api/crawler/start \
  -H "Content-Type: application/json" \
  -d '{"mode": "manga", "start_page": 1, "end_page": 50}'
```

### 2. Monitor Progress

```bash
# Check every 5 minutes
while true; do
  curl -s .../api/crawler/status | jq '.data'
  sleep 300
done
```

### 3. Handle Interruptions

```bash
# If crawling stops, resume from checkpoint
curl -X POST .../api/crawler/resume
```

## ⚠️ Important Notes

### Rate Limiting

- External API has rate limits (429 errors)
- Crawler handles this gracefully with delays
- Progress is saved automatically

### Resource Usage

- Railway Free: 500 hours/month
- Memory: ~100-200MB during crawling
- CPU: Moderate usage (I/O intensive)

### Error Handling

- Network errors: Auto-retry with backoff
- Rate limits: Automatic delay and retry
- Railway restarts: Resume from checkpoint

## 🔧 Troubleshooting

### No Response from API

```bash
# Check if service is running
curl https://baca-komik-production.up.railway.app/health
```

### Crawling Stuck

```bash
# Check status
curl .../api/crawler/status

# If needed, stop and restart
curl -X POST .../api/crawler/stop
curl -X POST .../api/crawler/start -d '{"mode": "manga", "start_page": 1, "end_page": 10}'
```

### Database Issues

- Check Railway logs for database connection errors
- Verify Supabase credentials in Railway environment variables

## 🎉 Success Indicators

### Healthy Crawling:

- ✅ `success_count` increasing
- ✅ `progress_percent` advancing
- ✅ `eta` showing reasonable time
- ✅ Low `error_count`

### Completed Crawling:

- ✅ Status returns "No active crawling session"
- ✅ Database contains new records
- ✅ No checkpoint file exists

## 🔄 **AUTO-UPDATE SERVICE**

### **Real-time Updates (5 menit interval):**

Monitors Shinigami API for new manga and chapters automatically.

```bash
# Start auto-updater as background service
go run cmd/auto-updater/main.go

# Custom interval (2 minutes)
go run cmd/auto-updater/main.go -interval=2m

# With pages crawling enabled
go run cmd/auto-updater/main.go -crawl-pages
```

### **API Endpoints:**

```bash
# Start auto-update service
POST /api/auto-update/start

# Stop auto-update service
POST /api/auto-update/stop

# Get service status
GET /api/auto-update/status

# Update configuration
PUT /api/auto-update/config

# Trigger manual update
POST /api/auto-update/trigger
```

### **Features:**

- ✅ **Automatic Detection**: New manga & chapters
- ✅ **Real-time Updates**: 5 menit interval (configurable)
- ✅ **Smart Crawling**: Only crawl new content
- ✅ **Background Service**: Runs continuously
- ✅ **API Control**: Start/stop via REST API

### **Monitoring Endpoint:**

```
https://api.shngm.io/v1/manga/list?is_update=true&sort=latest&sort_order=desc
```

### **How It Works:**

1. **Fetch Updates**: Query external API every 5 minutes
2. **Compare Database**: Check for new manga/chapters
3. **Auto-Crawl**: Automatically crawl new content
4. **Background Processing**: Runs continuously without manual intervention
