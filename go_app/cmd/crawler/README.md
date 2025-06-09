# Baca Komik Crawler

Crawler untuk mengambil data manga dari API eksternal dan menyimpannya ke database Supabase.

## 🎯 Tujuan

Crawler ini dirancang untuk:
- Mengambil data master (genres, formats, types, authors, artists)
- Crawl semua manga dengan detail lengkap
- Crawl semua chapter untuk setiap manga
- Crawl halaman/pages untuk setiap chapter
- Menyimpan URL relatif untuk fleksibilitas

## 🚀 Cara Penggunaan

### Prerequisites

1. **Database Migration**
   ```bash
   # Jalankan migration untuk menambah kolom external_id
   psql -h your-host -U your-user -d your-db -f migrations/add_external_id.sql
   ```

2. **Environment Variables**
   Pastikan file `.env` sudah dikonfigurasi dengan benar:
   ```env
   DB_HOST=your-supabase-host
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=your-password
   DB_NAME=postgres
   ```

### Build Crawler

```bash
cd go_app
go build -o crawler cmd/crawler/main.go
```

### Menjalankan Crawler

#### 1. Crawl Master Data (Recommended First)

```bash
# Crawl genres
./crawler --mode=genres

# Crawl formats
./crawler --mode=formats

# Crawl types
./crawler --mode=types

# Crawl authors
./crawler --mode=authors

# Crawl artists
./crawler --mode=artists
```

#### 2. Crawl Manga Data

```bash
# Crawl manga halaman 1-5 (test dulu)
./crawler --mode=manga --start-page=1 --end-page=5 --batch-size=20

# Crawl manga halaman 1-50 (lebih banyak)
./crawler --mode=manga --start-page=1 --end-page=50 --batch-size=20
```

#### 3. Crawl Chapters

```bash
# Crawl chapters untuk semua manga yang sudah ada di database
./crawler --mode=chapters --manga-id=all --batch-size=5

# Crawl chapters untuk manga tertentu
./crawler --mode=chapters --manga-id=d8efab60-cada-4d99-be3a-e813f75ba72f
```

#### 4. Crawl Pages

```bash
# Crawl pages untuk semua chapter
./crawler --mode=pages --batch-size=10
```

#### 5. Crawl Everything (All-in-One)

```bash
# Crawl semua data secara berurutan
./crawler --mode=all --batch-size=10

# Dry run untuk test tanpa save ke database
./crawler --mode=all --dry-run --verbose
```

## 📊 Command Line Options

| Flag | Description | Default | Example |
|------|-------------|---------|---------|
| `--mode` | Mode crawling (required) | - | `genres`, `manga`, `chapters`, `pages`, `all` |
| `--start-page` | Halaman mulai untuk pagination | 1 | `--start-page=1` |
| `--end-page` | Halaman akhir untuk pagination | 1 | `--end-page=10` |
| `--batch-size` | Ukuran batch untuk processing | 10 | `--batch-size=20` |
| `--manga-id` | ID manga spesifik atau "all" | - | `--manga-id=all` |
| `--dry-run` | Jalankan tanpa save ke database | false | `--dry-run` |
| `--verbose` | Enable verbose logging | false | `--verbose` |

## 🔄 Workflow Recommended

### Phase 1: Setup & Test
```bash
# 1. Test connection dengan dry run
./crawler --mode=genres --dry-run --verbose

# 2. Crawl master data
./crawler --mode=genres
./crawler --mode=formats
./crawler --mode=types
./crawler --mode=authors
./crawler --mode=artists
```

### Phase 2: Sample Data
```bash
# 3. Test dengan sample manga (5 halaman)
./crawler --mode=manga --start-page=1 --end-page=5 --verbose

# 4. Test chapters untuk sample manga
./crawler --mode=chapters --manga-id=all --batch-size=3
```

### Phase 3: Full Crawl
```bash
# 5. Crawl lebih banyak manga
./crawler --mode=manga --start-page=1 --end-page=50

# 6. Crawl semua chapters
./crawler --mode=chapters --manga-id=all --batch-size=5

# 7. Crawl pages (optional, bisa dilakukan bertahap)
./crawler --mode=pages --batch-size=10
```

## 📈 Monitoring & Progress

### Database Queries untuk Monitor Progress

```sql
-- Check jumlah data yang sudah di-crawl
SELECT 
  (SELECT COUNT(*) FROM "mGenre") as genres,
  (SELECT COUNT(*) FROM "mFormat") as formats,
  (SELECT COUNT(*) FROM "mKomik") as manga,
  (SELECT COUNT(*) FROM "mChapter") as chapters,
  (SELECT COUNT(*) FROM "mChapter" WHERE pages_data IS NOT NULL) as chapters_with_pages;

-- Check manga terbaru yang di-crawl
SELECT title, external_id, created_date 
FROM "mKomik" 
WHERE external_id IS NOT NULL 
ORDER BY created_date DESC 
LIMIT 10;

-- Check chapters tanpa pages data
SELECT COUNT(*) as chapters_without_pages
FROM "mChapter" 
WHERE external_id IS NOT NULL AND pages_data IS NULL;
```

## ⚠️ Important Notes

1. **Rate Limiting**: Crawler sudah include rate limiting untuk menghormati server eksternal
2. **Resume Capability**: Crawler menggunakan `ON CONFLICT` untuk resume jika crash
3. **External ID Mapping**: Semua data disimpan dengan `external_id` untuk tracking
4. **URL Flexibility**: Base URL disimpan di `mUrlConfig` untuk fleksibilitas
5. **Batch Processing**: Gunakan batch size yang reasonable untuk avoid timeout

## 🐛 Troubleshooting

### Error: "failed to connect to database"
- Check environment variables
- Pastikan database accessible
- Verify credentials

### Error: "API returned status 429"
- Rate limit exceeded
- Tunggu beberapa menit dan coba lagi
- Kurangi batch size

### Error: "failed to insert manga"
- Check database schema
- Jalankan migration script
- Verify foreign key constraints

### Crawler Stuck/Slow
- Check network connection
- Monitor database performance
- Reduce batch size
- Use verbose mode untuk debug

## 📝 Logs

Crawler akan menampilkan progress real-time:
```
2024/01/15 10:30:00 Starting to crawl genres...
2024/01/15 10:30:01 Found 25 genres to process
2024/01/15 10:30:02 Successfully saved 25 genres
2024/01/15 10:30:02 Starting to crawl manga from page 1 to 5...
2024/01/15 10:30:03 Processing manga page 1/5...
2024/01/15 10:30:04 Found 24 manga on page 1
2024/01/15 10:30:05 Successfully saved 24 manga from page 1
```
