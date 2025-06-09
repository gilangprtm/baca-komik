# 🚀 Crawling Guide - Railway Deployment

## 📋 Overview

Sekarang Go app sudah di-deploy di Railway (https://baca-komik-production.up.railway.app/), kita bisa menjalankan crawling jangka panjang dengan beberapa cara:

## 🌐 **METHOD 1: HTTP API Endpoints (RECOMMENDED)**

### **✅ Advantages:**
- ✅ **24/7 Uptime** - Railway server tidak akan mati
- ✅ **Web Interface** - Bisa trigger via browser/Postman
- ✅ **Background Processing** - Crawling berjalan di background
- ✅ **Real-time Monitoring** - Cek progress kapan saja
- ✅ **Auto-restart** - Railway auto-restart jika crash

### **🔧 Available Endpoints:**

#### **1. Start Crawling**
```bash
POST https://baca-komik-production.up.railway.app/api/crawler/start
Content-Type: application/json

{
  "mode": "all",           // "auto", "manga", "chapters", "pages", "all"
  "start_page": 1,         // Optional: start page for manga
  "end_page": -1,          // Optional: end page (-1 = all pages)
  "batch_size": 10,        // Optional: batch size
  "dry_run": false         // Optional: test mode
}
```

#### **2. Check Status**
```bash
GET https://baca-komik-production.up.railway.app/api/crawler/status
```

#### **3. Stop Crawling**
```bash
POST https://baca-komik-production.up.railway.app/api/crawler/stop
```

#### **4. Resume Crawling**
```bash
POST https://baca-komik-production.up.railway.app/api/crawler/resume
```

### **📊 Example Usage:**

#### **Start Master Data Crawling:**
```bash
curl -X POST https://baca-komik-production.up.railway.app/api/crawler/start \
  -H "Content-Type: application/json" \
  -d '{"mode": "auto"}'
```

#### **Start Full Manga Crawling:**
```bash
curl -X POST https://baca-komik-production.up.railway.app/api/crawler/start \
  -H "Content-Type: application/json" \
  -d '{"mode": "manga", "start_page": 1, "end_page": -1}'
```

#### **Check Progress:**
```bash
curl https://baca-komik-production.up.railway.app/api/crawler/status
```

## 🔄 **METHOD 2: Railway CLI (Advanced)**

### **Setup Railway CLI:**
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Connect to your project
railway link
```

### **Run Commands:**
```bash
# Start crawling via Railway CLI
railway run ./crawler --mode=all --verbose

# Check logs
railway logs

# Connect to shell
railway shell
```

## 📊 **CRAWLING STRATEGIES:**

### **🎯 Strategy 1: Incremental Crawling**
```bash
# Step 1: Master data (sudah selesai)
curl -X POST .../api/crawler/start -d '{"mode": "auto"}'

# Step 2: Manga batch 1 (pages 1-100)
curl -X POST .../api/crawler/start -d '{"mode": "manga", "start_page": 1, "end_page": 100}'

# Step 3: Manga batch 2 (pages 101-200)
curl -X POST .../api/crawler/start -d '{"mode": "manga", "start_page": 101, "end_page": 200}'

# Step 4: All chapters
curl -X POST .../api/crawler/start -d '{"mode": "chapters"}'

# Step 5: All pages
curl -X POST .../api/crawler/start -d '{"mode": "pages"}'
```

### **🎯 Strategy 2: Full Auto Crawling**
```bash
# Start everything at once (will take days)
curl -X POST .../api/crawler/start -d '{"mode": "all"}'
```

## 📈 **MONITORING & PROGRESS:**

### **Real-time Status Check:**
```bash
# Check every 5 minutes
while true; do
  curl -s https://baca-komik-production.up.railway.app/api/crawler/status | jq
  sleep 300
done
```

### **Railway Dashboard:**
- **Logs**: https://railway.app/project/[your-project]/deployments
- **Metrics**: CPU, Memory, Network usage
- **Environment**: Database connections, variables

## ⚠️ **IMPORTANT CONSIDERATIONS:**

### **🔋 Resource Limits:**
- **Railway Free**: 500 hours/month, 512MB RAM
- **Railway Pro**: Unlimited hours, scalable resources
- **Rate Limiting**: API external ada rate limit (429 errors)

### **💾 Data Persistence:**
- **Database**: Supabase (persistent)
- **Checkpoint Files**: Railway ephemeral storage (lost on restart)
- **Logs**: Railway dashboard (7 days retention)

### **🛡️ Error Handling:**
- **Rate Limits**: Crawler handles 429 errors gracefully
- **Network Issues**: Auto-retry with exponential backoff
- **Railway Restarts**: Use checkpoint system to resume

## 🎯 **RECOMMENDED WORKFLOW:**

### **Phase 1: Test Run (5 minutes)**
```bash
curl -X POST .../api/crawler/start -d '{"mode": "manga", "start_page": 1, "end_page": 5, "dry_run": true}'
```

### **Phase 2: Small Batch (30 minutes)**
```bash
curl -X POST .../api/crawler/start -d '{"mode": "manga", "start_page": 1, "end_page": 50}'
```

### **Phase 3: Full Production (hours/days)**
```bash
curl -X POST .../api/crawler/start -d '{"mode": "all"}'
```

## 📱 **MONITORING TOOLS:**

### **1. Browser Dashboard:**
Visit: https://baca-komik-production.up.railway.app/api/crawler/status

### **2. Postman Collection:**
Import endpoints untuk easy testing

### **3. Custom Script:**
```bash
#!/bin/bash
# monitor.sh
while true; do
  echo "=== $(date) ==="
  curl -s .../api/crawler/status | jq '.data'
  echo ""
  sleep 60
done
```

## 🚀 **NEXT STEPS:**

1. **✅ Deploy updated code** dengan crawler endpoints
2. **🧪 Test endpoints** dengan small batch
3. **📊 Monitor progress** via status endpoint
4. **🔄 Scale up** sesuai kebutuhan
5. **📈 Optimize** berdasarkan performance

**Railway deployment memberikan solusi terbaik untuk crawling jangka panjang!** 🎉
