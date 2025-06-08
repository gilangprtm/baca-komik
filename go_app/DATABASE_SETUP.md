# Database Setup Instructions

## 🔧 **Mendapatkan Database Password**

File `.env` sudah dikonfigurasi dengan semua credentials kecuali **DB_PASSWORD**. Untuk mendapatkan database password:

### **Option 1: Dari Supabase Dashboard**

1. **Login ke Supabase Dashboard**: https://supabase.com/dashboard
2. **Pilih Project**: `baca-komik` (owiowqcpkksbuuoyhplm)
3. **Go to Settings** → **Database**
4. **Copy Database Password** dari section "Connection parameters"
5. **Update .env file**:
   ```env
   DB_PASSWORD=your_actual_password_here
   ```

### **Option 2: Reset Database Password**

Jika password tidak tersedia:

1. **Go to Settings** → **Database** 
2. **Click "Reset database password"**
3. **Generate new password**
4. **Copy dan update .env file**

### **Option 3: Menggunakan Connection String**

Alternatif, gunakan connection string langsung:

1. **Go to Settings** → **Database**
2. **Copy "Connection string"** 
3. **Extract password** dari connection string
4. **Update .env file**

## 🚀 **Testing Database Connection**

Setelah update DB_PASSWORD, test connection:

```bash
# Run aplikasi
go run main.go

# Test health check
curl http://localhost:8080/health

# Test database connection
curl http://localhost:8080/test-db
```

### **Expected Success Response:**

```json
{
  "status": "healthy",
  "database": "connected",
  "version": "1.0.0",
  "service": "baca-komik-api"
}
```

### **Database Test Response:**

```json
{
  "status": "success",
  "message": "All database tests passed"
}
```

## 📋 **Current .env Configuration**

```env
# Server Configuration
PORT=8080
GIN_MODE=debug
LOG_LEVEL=info

# Supabase Configuration ✅
SUPABASE_URL=https://owiowqcpkksbuuoyhplm.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Database Connection ⚠️ (Need DB_PASSWORD)
DB_HOST=db.owiowqcpkksbuuoyhplm.supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=YOUR_DATABASE_PASSWORD_HERE  # ← Update this
DB_SSL_MODE=require

# JWT Configuration ✅
JWT_SECRET=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# CORS Configuration ✅
CORS_ALLOWED_ORIGINS=http://localhost:3000,https://baca-komik.vercel.app
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Origin,Content-Type,Accept,Authorization,X-Requested-With
```

## 🎯 **Next Steps**

1. **Update DB_PASSWORD** di file `.env`
2. **Run aplikasi**: `go run main.go`
3. **Test endpoints**: 
   - Health: `http://localhost:8080/health`
   - Comics: `http://localhost:8080/api/comics`
   - Popular: `http://localhost:8080/api/comics/popular`
4. **Ready untuk production deployment!**

## 🔍 **Troubleshooting**

### **Connection Error:**
```
failed to connect to `host=db.owiowqcpkksbuuoyhplm.supabase.co
```
- **Solution**: Update DB_PASSWORD dengan password yang benar

### **Authentication Error:**
```
password authentication failed
```
- **Solution**: Reset database password di Supabase dashboard

### **SSL Error:**
```
SSL connection error
```
- **Solution**: Pastikan `DB_SSL_MODE=require` di .env

## 📞 **Support**

Jika masih ada masalah:
1. Check Supabase project status di dashboard
2. Verify database is active dan healthy
3. Ensure network connectivity ke Supabase
4. Check firewall settings jika ada

---

**Status**: ⚠️ Waiting for DB_PASSWORD configuration
**Next**: Update password → Test connection → Ready to use! 🚀
