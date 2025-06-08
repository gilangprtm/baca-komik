# Go API Migration Tasks

Dokumentasi task untuk migrasi API dari Next.js ke Go dengan deployment ke Railway dan sinkronisasi GitHub.

## 🎯 Tujuan Migrasi

- **Performance**: Mengurangi response time dari 2000ms+ menjadi <100ms
- **Compatibility**: Mempertahankan exact same response format untuk Flutter app
- **Infrastructure**: Deploy ke Railway dengan auto-deploy dari GitHub
- **Database**: Tetap menggunakan Supabase yang sama (no database changes)

## 📋 Task Breakdown

### Phase 1: Project Setup & Infrastructure

- [x] **Task 1.1**: Setup Go project structure di folder `go_app/`
- [x] **Task 1.2**: Initialize Go modules dan dependencies
- [x] **Task 1.3**: Setup Supabase connection dengan pgx driver
- [x] **Task 1.4**: Create base models dan response structures
- [x] **Task 1.5**: Setup middleware (CORS, Auth, Logger)
- [x] **Task 1.6**: Create health check endpoint

### Phase 2: Core Comics API

- [x] **Task 2.1**: Implement `GET /comics` - List comics dengan pagination
- [x] **Task 2.2**: Implement `GET /comics/home` - Home comics dengan latest chapters
- [x] **Task 2.3**: Implement `GET /comics/popular` - Popular comics dari mPopular
- [x] **Task 2.4**: Implement `GET /comics/recommended` - Recommended dari mRecomed
- [x] **Task 2.5**: Implement `GET /comics/{id}` - Comic details
- [x] **Task 2.6**: Implement `GET /comics/{id}/complete` - Complete comic dengan user data

### Phase 3: Chapters API

- [x] **Task 3.1**: Implement `GET /comics/{id}/chapters` - List chapters (completed in Phase 2)
- [x] **Task 3.2**: Implement `GET /chapters/{id}` - Chapter details
- [x] **Task 3.3**: Implement `GET /chapters/{id}/complete` - Complete chapter dengan pages
- [x] **Task 3.4**: Implement `GET /chapters/{id}/pages` - Chapter pages
- [x] **Task 3.5**: Implement `GET /chapters/{id}/adjacent` - Adjacent chapters for navigation

### Phase 4: User Interactions API (Auth Required)

- [x] **Task 4.1**: Implement JWT authentication middleware (completed in Phase 1)
- [x] **Task 4.2**: Implement `GET/POST /bookmarks` - User bookmarks
- [x] **Task 4.3**: Implement `GET /bookmarks/details` - Detailed bookmarks
- [x] **Task 4.4**: Implement `DELETE /bookmarks/{id}` - Remove bookmark
- [x] **Task 4.5**: Implement `POST /votes` - Add vote
- [x] **Task 4.6**: Implement `DELETE /votes/{id}` - Remove vote

### Phase 5: Comments API

- [x] **Task 5.1**: Implement `GET /comments/{id}` - Get comments
- [x] **Task 5.2**: Implement `POST /comments` - Add comment

### Phase 6: Testing & Validation

- [ ] **Task 6.1**: Create comprehensive API tests
- [ ] **Task 6.2**: Response format validation tests
- [ ] **Task 6.3**: Performance benchmarking
- [ ] **Task 6.4**: Flutter app compatibility testing

### Phase 7: Deployment & Migration

- [ ] **Task 7.1**: Setup Railway project dan environment variables
- [ ] **Task 7.2**: Configure GitHub auto-deployment
- [ ] **Task 7.3**: Setup production database connection
- [ ] **Task 7.4**: Gradual traffic migration strategy
- [ ] **Task 7.5**: Monitor performance dan error rates

## 🔧 Technical Requirements

### Dependencies

```go
// Core dependencies yang akan digunakan
github.com/gin-gonic/gin           // HTTP framework
github.com/jackc/pgx/v5           // PostgreSQL driver
github.com/golang-jwt/jwt/v5      // JWT authentication
github.com/go-playground/validator/v10 // Validation
github.com/spf13/viper           // Configuration
github.com/sirupsen/logrus       // Logging
github.com/gin-contrib/cors      // CORS middleware
```

### Environment Variables

```env
# Supabase Configuration (same as Next.js)
SUPABASE_URL=https://owiowqcpkksbuuoyhplm.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Server Configuration
PORT=8080
GIN_MODE=release
LOG_LEVEL=info

# Database Connection
DB_HOST=db.owiowqcpkksbuuoyhplm.supabase.co
DB_PORT=5432
DB_NAME=postgres
DB_USER=postgres
DB_PASSWORD=your_db_password
DB_SSL_MODE=require
```

### Response Format Compliance

Semua endpoint harus menghasilkan response yang **persis sama** dengan dokumentasi API:

1. **Pagination Response:**

```json
{
  "data": [...],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5,
    "has_more": true
  }
}
```

2. **Error Response:**

```json
{
  "error": "Error message"
}
```

3. **Status Codes:** 200, 201, 400, 401, 404, 500

## 🚀 Deployment Strategy

### Railway Configuration

1. **Repository**: Connect ke GitHub repository
2. **Build Command**: `go build -o main .`
3. **Start Command**: `./main`
4. **Environment**: Production variables dari Supabase

### Migration Strategy

1. **Parallel Running**: Go API berjalan parallel dengan Next.js
2. **Gradual Migration**: Migrate endpoint by endpoint
3. **A/B Testing**: Test performance dan compatibility
4. **Full Migration**: Switch Flutter app ke Go API
5. **Cleanup**: Remove Next.js API setelah stable

## 📊 Success Metrics

### Performance Targets

- **Response Time**: <100ms (vs current 2000ms+)
- **Memory Usage**: <50MB (vs Node.js ~200MB)
- **Concurrent Requests**: >1000 req/s
- **Error Rate**: <0.1%

### Compatibility Requirements

- **100% Response Format Match**: Semua response harus identik
- **Zero Breaking Changes**: Flutter app tidak perlu diubah
- **Feature Parity**: Semua endpoint berfungsi sama

## 📝 Notes

- **Database**: Tidak ada perubahan pada Supabase schema
- **Authentication**: Tetap menggunakan Supabase Auth JWT
- **CORS**: Maintain same CORS policy untuk Flutter app
- **Logging**: Comprehensive logging untuk monitoring
- **Error Handling**: Consistent error response format

## 🔄 Next Steps

1. Start dengan **Task 1.1** - Setup Go project structure
2. Implement core dependencies dan configuration
3. Create base models sesuai dengan Supabase schema
4. Implement endpoints satu per satu dengan testing
5. Deploy ke Railway untuk testing
6. Gradual migration dari Next.js ke Go

---

**Priority**: High Performance, Zero Breaking Changes, Seamless Migration
