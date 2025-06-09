# 🔄 URL Updater Service

Service untuk mengupdate base URL di database ketika external service (Shinigami API) mengubah base URL mereka.

## 🎯 **Kapan Digunakan:**

### **Scenario:**
- Shinigami mengubah base URL dari `https://storage.shngm.id` ke `https://new-storage.shngm.id`
- Semua URL di database masih menggunakan URL lama
- Perlu update ribuan records secara batch

### **Affected Tables:**
- **mKomik**: `cover_image_url`
- **mChapter**: `thumbnail_image_url`  
- **trChapter**: `image_url`, `image_url_low`

## 🚀 **Cara Penggunaan:**

### **1. Windows (PowerShell):**
```powershell
# Preview changes (dry run)
.\scripts\update-urls.ps1 `
  -OldURL "https://storage.shngm.id" `
  -NewURL "https://new-storage.shngm.id"

# Actually update URLs
.\scripts\update-urls.ps1 `
  -OldURL "https://storage.shngm.id" `
  -NewURL "https://new-storage.shngm.id" `
  -DryRun:$false

# With verbose logging
.\scripts\update-urls.ps1 `
  -OldURL "https://storage.shngm.id" `
  -NewURL "https://new-storage.shngm.id" `
  -DryRun:$false -Verbose
```

### **2. Linux/Mac (Bash):**
```bash
# Preview changes (dry run)
./scripts/update-urls.sh \
  -o "https://storage.shngm.id" \
  -n "https://new-storage.shngm.id"

# Actually update URLs
./scripts/update-urls.sh \
  -o "https://storage.shngm.id" \
  -n "https://new-storage.shngm.id" \
  --live

# With verbose logging
./scripts/update-urls.sh \
  -o "https://storage.shngm.id" \
  -n "https://new-storage.shngm.id" \
  --live --verbose
```

### **3. Direct Go Command:**
```bash
# Preview changes
go run cmd/url-updater/main.go \
  -old="https://storage.shngm.id" \
  -new="https://new-storage.shngm.id"

# Actually update
go run cmd/url-updater/main.go \
  -old="https://storage.shngm.id" \
  -new="https://new-storage.shngm.id" \
  -dry-run=false
```

## 📊 **Output Example:**

### **Dry Run Mode:**
```
🔄 URL Updater Starting...
📍 Old Base URL: https://storage.shngm.id
📍 New Base URL: https://new-storage.shngm.id
🔍 Mode: DRY RUN (preview only)

🔍 Analyzing database for URL updates...
📊 Update Summary:
   📚 Manga cover URLs: 246 records
   📖 Chapter thumbnail URLs: 1,223 records
   📄 Chapter page URLs: 15,487 records
   📋 Total records: 16,956

🔍 DRY RUN - Showing sample records that would be updated:

📚 Updating manga cover URLs...
   Found 246 manga records to update
   📚 Sample manga records:
      📖 One Piece
      📖 Naruto
      📖 Attack on Titan

📖 Updating chapter thumbnail URLs...
   Found 1,223 chapter records to update
   📖 Sample chapter records:
      📄 One Piece - Chapter 1095
      📄 Naruto - Chapter 700
      📄 Attack on Titan - Chapter 139

📄 Updating chapter page URLs...
   Found 15,487 page records to update
   📄 Sample page records:
      🖼️  Page 1
      🖼️  Page 2
      🖼️  Page 3

🔍 DRY RUN completed - no changes made
💡 Run with -dry-run=false to apply changes
```

### **Live Update Mode:**
```
🔄 URL Updater Starting...
📍 Old Base URL: https://storage.shngm.id
📍 New Base URL: https://new-storage.shngm.id
⚡ Mode: LIVE UPDATE

📊 Update Summary:
   📚 Manga cover URLs: 246 records
   📖 Chapter thumbnail URLs: 1,223 records
   📄 Chapter page URLs: 15,487 records
   📋 Total records: 16,956

📚 Updating manga cover URLs...
   Found 246 manga records to update
   ✅ Updated 246 manga cover URLs

📖 Updating chapter thumbnail URLs...
   Found 1,223 chapter records to update
   ✅ Updated 1,223 chapter thumbnail URLs

📄 Updating chapter page URLs...
   Found 15,487 page records to update
   ✅ Updated 15,487 page URLs

✅ URL update completed successfully!
```

## ⚠️ **Safety Features:**

### **1. Dry Run by Default:**
- Default mode adalah **dry run** (preview only)
- Tidak ada perubahan yang dibuat kecuali explicitly disabled
- Menampilkan sample data yang akan diupdate

### **2. Confirmation Prompt:**
- Meminta konfirmasi sebelum live update
- Menampilkan summary jumlah records yang akan diupdate

### **3. Backup Recommendation:**
```sql
-- Backup tables sebelum update
CREATE TABLE "mKomik_backup" AS SELECT * FROM "mKomik";
CREATE TABLE "mChapter_backup" AS SELECT * FROM "mChapter";
CREATE TABLE "trChapter_backup" AS SELECT * FROM "trChapter";
```

### **4. Rollback Capability:**
```sql
-- Jika ada masalah, rollback dari backup
UPDATE "mKomik" SET cover_image_url = b.cover_image_url 
FROM "mKomik_backup" b WHERE "mKomik".id = b.id;

UPDATE "mChapter" SET thumbnail_image_url = b.thumbnail_image_url 
FROM "mChapter_backup" b WHERE "mChapter".id = b.id;

UPDATE "trChapter" SET 
    image_url = b.image_url,
    image_url_low = b.image_url_low
FROM "trChapter_backup" b WHERE "trChapter".id = b.id;
```

## 🔧 **Technical Details:**

### **How It Works:**
1. **Scan Database**: Count records with old base URL
2. **Show Summary**: Display affected records count
3. **Sample Preview**: Show sample records (dry run)
4. **Batch Update**: Use SQL REPLACE function for efficiency
5. **Progress Tracking**: Log success/failure counts

### **SQL Operations:**
```sql
-- Manga covers
UPDATE "mKomik" 
SET cover_image_url = REPLACE(cover_image_url, $old, $new),
    updated_at = NOW()
WHERE cover_image_url LIKE $old || '%';

-- Chapter thumbnails  
UPDATE "mChapter"
SET thumbnail_image_url = REPLACE(thumbnail_image_url, $old, $new),
    updated_at = NOW()
WHERE thumbnail_image_url LIKE $old || '%';

-- Chapter pages
UPDATE "trChapter"
SET image_url = REPLACE(image_url, $old, $new),
    image_url_low = REPLACE(image_url_low, $old, $new)
WHERE image_url LIKE $old || '%' OR image_url_low LIKE $old || '%';
```

### **Performance:**
- **Efficient**: Uses SQL REPLACE function
- **Batch Processing**: Updates all records in single query
- **Indexed**: WHERE clauses use LIKE with prefix for index usage

## 📋 **Checklist untuk URL Update:**

### **Before Update:**
- [ ] Backup database tables
- [ ] Verify old and new URLs are correct
- [ ] Run dry run to preview changes
- [ ] Check sample records look correct

### **During Update:**
- [ ] Monitor progress logs
- [ ] Check for any error messages
- [ ] Verify row counts match expectations

### **After Update:**
- [ ] Test sample URLs in browser
- [ ] Verify images load correctly
- [ ] Check API responses
- [ ] Test Flutter app functionality

## 🎉 **Success Indicators:**

- ✅ All records updated successfully
- ✅ No error messages in logs
- ✅ Images load correctly in browser
- ✅ Flutter app displays images properly
- ✅ API responses contain new URLs
