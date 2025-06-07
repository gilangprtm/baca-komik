# BacaKomik API Documentation

Dokumentasi lengkap untuk semua API endpoints BacaKomik yang digunakan oleh Flutter app dan client lainnya.

## Base URL

```
https://baca-komik.vercel.app/api
```

## Authentication

Sebagian besar endpoint memerlukan autentikasi menggunakan JWT token dari Supabase Auth. Sertakan token dalam header `Authorization`:

```
Authorization: Bearer {token}
```

### Protected Endpoints

Endpoint berikut memerlukan autentikasi:

- `/api/bookmarks/*`
- `/api/votes/*`
- `/api/comments/*`

## Response Format

Semua response menggunakan format JSON dengan struktur konsisten:

### Success Response

```json
{
  "data": "...",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "total_pages": 5,
    "has_more": true
  }
}
```

### Error Response

```json
{
  "error": "Error message"
}
```

## Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized
- `404` - Not Found
- `500` - Internal Server Error

---

## 📚 Comics

### Get Home Comics [Optimized]

**Endpoint:** `GET /comics/home`

**Deskripsi:** Mendapatkan daftar komik untuk halaman home dengan sorting berdasarkan chapter terbaru.

**Query Parameters:**

- `page` (optional): Nomor halaman untuk pagination (default: 1)
- `limit` (optional): Jumlah komik per halaman (default: 10)
- `sort` (optional): Field untuk sorting (default: berdasarkan chapter terbaru)
- `order` (optional): Urutan sort 'asc' atau 'desc' (default: 'desc')

**Response:**

```json
{
  "data": [
    {
      "id": "string",
      "title": "string",
      "alternative_title": "string",
      "synopsis": "string",
      "status": "On Going" | "End" | "Hiatus" | "Break",
      "country_id": "KR" | "JPN" | "CN",
      "view_count": 0,
      "vote_count": 0,
      "bookmark_count": 0,
      "cover_image_url": "string",
      "created_date": "string",
      "updated_date": "string",
      "chapter_count": 42,
      "latest_chapters": [
        {
          "id": "string",
          "id_komik": "string",
          "chapter_number": 1,
          "title": "string",
          "release_date": "string",
          "thumbnail_image_url": "string"
        }
      ],
      "genres": [
        {
          "id": "string",
          "name": "string"
        }
      ]
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 0,
    "total_pages": 0,
    "has_more": false
  }
}
```

---

### Get All Comics

**Endpoint:** `GET /comics`

**Deskripsi:** Mendapatkan daftar semua komik dengan filtering dan pagination.

**Query Parameters:**

- `page` (optional): Nomor halaman (default: 1)
- `limit` (optional): Jumlah komik per halaman (default: 10)
- `search` (optional): Kata kunci pencarian berdasarkan title
- `sort` (optional): Field untuk sorting (default: 'rank')
- `order` (optional): Urutan sort 'asc' atau 'desc' (default: 'desc')
- `genre` (optional): Filter berdasarkan genre ID
- `country` (optional): Filter berdasarkan negara ('KR', 'JPN', 'CN')

**Response:**

```json
{
  "data": [
    {
      "id": "string",
      "title": "string",
      "alternative_title": "string",
      "synopsis": "string",
      "status": "string",
      "country_id": "string",
      "view_count": 0,
      "vote_count": 0,
      "bookmark_count": 0,
      "cover_image_url": "string",
      "created_date": "string",
      "updated_date": "string",
      "chapter_count": 42,
      "genres": [
        {
          "id": "string",
          "name": "string"
        }
      ]
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 0,
    "total_pages": 0,
    "has_more": false
  }
}
```

---

### Get Popular Comics

**Endpoint:** `GET /comics/popular`

**Deskripsi:** Mendapatkan daftar komik populer berdasarkan tipe periode dari tabel `mPopular`.

**Query Parameters:**

- `type` (optional): Tipe periode popular ('harian', 'mingguan', 'bulanan', 'all_time', default: 'all_time')
- `limit` (optional): Jumlah komik yang dikembalikan (default: 20)

**Response:**

```json
{
  "data": [
    {
      "id": "string",
      "title": "string",
      "alternative_title": "string",
      "cover_image_url": "string",
      "country_id": "KR" | "JPN" | "CN",
      "view_count": 0,
      "vote_count": 0,
      "bookmark_count": 0,
      "status": "On Going" | "Completed" | "Break",
      "created_date": "string",
      "type": "harian" | "mingguan" | "bulanan" | "all_time"
    }
  ],
  "meta": {
    "type": "all_time",
    "limit": 20,
    "total": 15
  }
}
```

---

### Get Recommended Comics

**Endpoint:** `GET /comics/recommended`

**Deskripsi:** Mendapatkan daftar komik rekomendasi dari tabel `mRecomed`.

**Query Parameters:**

- `limit` (optional): Jumlah komik yang dikembalikan (default: 20)

**Response:**

```json
{
  "data": [
    {
      "id": "string",
      "title": "string",
      "alternative_title": "string",
      "cover_image_url": "string",
      "country_id": "KR" | "JPN" | "CN",
      "view_count": 0,
      "vote_count": 0,
      "bookmark_count": 0,
      "status": "On Going" | "Completed" | "Break",
      "created_date": "string"
    }
  ],
  "meta": {
    "limit": 20,
    "total": 12
  }
}
```

---

### Get Comic Details

**Endpoint:** `GET /comics/{id}`

**Deskripsi:** Mendapatkan detail komik berdasarkan ID.

**Path Parameters:**

- `id`: Comic ID

**Response:**

```json
{
  "id": "string",
  "title": "string",
  "alternative_title": "string",
  "synopsis": "string",
  "status": "string",
  "country_id": "KR" | "JPN" | "CN",
  "view_count": 0,
  "vote_count": 0,
  "bookmark_count": 0,
  "cover_image_url": "string",
  "created_date": "string",
  "updated_date": "string",
  "chapter_count": 42,
  "genres": [
    {
      "id": "string",
      "name": "string"
    }
  ],
  "authors": [
    {
      "id": "string",
      "name": "string"
    }
  ],
  "artists": [
    {
      "id": "string",
      "name": "string"
    }
  ],
  "formats": [
    {
      "id": "string",
      "name": "string"
    }
  ]
}
```

---

### Get Complete Comic Details [Optimized]

**Endpoint:** `GET /comics/{id}/complete`

**Deskripsi:** Mendapatkan detail lengkap komik dengan data user (bookmark, vote, last read chapter) tanpa data chapter.

**Path Parameters:**

- `id`: Comic ID

**Response:**

```json
{
  "comic": {
    "id": "string",
    "title": "string",
    "alternative_title": "string",
    "synopsis": "string",
    "status": "string",
    "country_id": "string",
    "view_count": 0,
    "vote_count": 0,
    "bookmark_count": 0,
    "cover_image_url": "string",
    "created_date": "string",
    "updated_date": "string",
    "genres": [
      {
        "id": "string",
        "name": "string"
      }
    ],
    "authors": [
      {
        "id": "string",
        "name": "string"
      }
    ],
    "artists": [
      {
        "id": "string",
        "name": "string"
      }
    ],
    "formats": [
      {
        "id": "string",
        "name": "string"
      }
    ]
  },
  "user_data": {
    "is_bookmarked": true,
    "is_voted": false,
    "last_read_chapter": "chapter_id"
  }
}
```

---

### Get Comic Chapters

**Endpoint:** `GET /comics/{id}/chapters`

**Deskripsi:** Mendapatkan daftar chapter dari komik tertentu dengan pagination.

**Path Parameters:**

- `id`: Comic ID

**Query Parameters:**

- `page` (optional): Nomor halaman (default: 1)
- `limit` (optional): Jumlah chapter per halaman (default: 20)
- `sort` (optional): Field untuk sorting (default: 'chapter_number')
- `order` (optional): Urutan sort 'asc' atau 'desc' (default: 'desc')

**Response:**

```json
{
  "comic": {
    "id": "string",
    "title": "string"
  },
  "data": [
    {
      "id": "string",
      "chapter_number": 1,
      "title": "string",
      "release_date": "string",
      "rating": 4.5,
      "view_count": 0,
      "vote_count": 0,
      "thumbnail_image_url": "string"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 0,
    "total_pages": 0,
    "has_more": false
  }
}
```

---

## 📖 Chapters

### Get Complete Chapter Details [Optimized]

**Endpoint:** `GET /chapters/{id}/complete`

**Deskripsi:** Mendapatkan detail lengkap chapter dengan pages, navigation, dan user data dalam satu request.

**Path Parameters:**

- `id`: Chapter ID

**Response:**

```json
{
  "chapter": {
    "id": "string",
    "chapter_number": 1,
    "title": "string",
    "release_date": "string",
    "rating": 4.5,
    "view_count": 0,
    "vote_count": 0,
    "id_komik": "string",
    "thumbnail_image_url": "string",
    "comic": {
      "id": "string",
      "title": "string",
      "alternative_title": "string",
      "cover_image_url": "string"
    }
  },
  "pages": [
    {
      "id_chapter": "string",
      "page_number": 1,
      "page_url": "string"
    }
  ],
  "navigation": {
    "next_chapter": {
      "id": "string",
      "chapter_number": 2
    },
    "prev_chapter": {
      "id": "string",
      "chapter_number": 0
    }
  },
  "user_data": {
    "is_voted": false,
    "is_read": false
  }
}
```

---

### Get Chapter Details

**Endpoint:** `GET /chapters/{id}`

**Deskripsi:** Mendapatkan detail chapter berdasarkan ID.

**Path Parameters:**

- `id`: Chapter ID

**Response:**

```json
{
  "id": "string",
  "chapter_number": 1,
  "title": "string",
  "release_date": "string",
  "rating": 4.5,
  "view_count": 0,
  "vote_count": 0,
  "id_komik": "string",
  "thumbnail_image_url": "string",
  "comic": {
    "id": "string",
    "title": "string",
    "alternative_title": "string",
    "cover_image_url": "string"
  }
}
```

---

### Get Chapter Pages

**Endpoint:** `GET /chapters/{id}/pages`

**Deskripsi:** Mendapatkan daftar halaman dari chapter tertentu.

**Path Parameters:**

- `id`: Chapter ID

**Response:**

```json
{
  "chapter": {
    "id": "string",
    "chapter_number": 1,
    "comic": {
      "id": "string",
      "title": "string"
    }
  },
  "pages": [
    {
      "id_chapter": "string",
      "page_number": 1,
      "page_url": "string"
    }
  ],
  "count": 25
}
```

---

## 💬 Comments

### Get Comments

**Endpoint:** `GET /comments/{id}`

**Deskripsi:** Mendapatkan komentar untuk komik atau chapter tertentu.

**Path Parameters:**

- `id`: Comic ID atau Chapter ID

**Query Parameters:**

- `type` (optional): Tipe konten ('comic' atau 'chapter', default: 'comic')
- `page` (optional): Nomor halaman (default: 1)
- `limit` (optional): Jumlah komentar per halaman (default: 10)
- `parent_only` (optional): Hanya ambil parent comments (default: false)

**Response:**

```json
{
  "data": [
    {
      "id": "string",
      "content": "string",
      "id_user": "string",
      "id_komik": "string",
      "id_chapter": "string",
      "parent_id": "string",
      "created_date": "string",
      "mUser": {
        "id": "string",
        "name": "string",
        "avatar_url": "string"
      },
      "replies": [
        {
          "id": "string",
          "content": "string",
          "created_date": "string",
          "mUser": {
            "id": "string",
            "name": "string",
            "avatar_url": "string"
          }
        }
      ]
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 0,
    "total_pages": 0,
    "has_more": false
  }
}
```

---

### Add Comment [Auth Required]

**Endpoint:** `POST /comments`

**Deskripsi:** Menambahkan komentar baru untuk komik atau chapter.

**Request Body:**

```json
{
  "content": "string",
  "id_komik": "string",
  "id_chapter": "string",
  "parent_id": "string"
}
```

**Response:**

```json
{
  "id": "string",
  "content": "string",
  "id_user": "string",
  "id_komik": "string",
  "id_chapter": "string",
  "parent_id": "string",
  "created_date": "string"
}
```

---

## 🔖 Bookmarks

### Get User Bookmarks [Auth Required]

**Endpoint:** `GET /bookmarks`

**Deskripsi:** Mendapatkan daftar bookmark user.

**Query Parameters:**

- `page` (optional): Nomor halaman (default: 1)
- `limit` (optional): Jumlah bookmark per halaman (default: 10)

**Response:**

```json
{
  "data": [
    {
      "id_user": "string",
      "id_komik": "string",
      "created_at": "string",
      "mKomik": {
        "id": "string",
        "title": "string",
        "cover_image_url": "string",
        "alternative_title": "string",
        "description": "string",
        "rating": 4.5,
        "status": "string",
        "country_id": "string"
      }
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 0,
    "total_pages": 0,
    "has_more": false
  }
}
```

---

### Get Detailed Bookmarks [Auth Required]

**Endpoint:** `GET /bookmarks/details`

**Deskripsi:** Mendapatkan bookmark dengan detail komik dan chapter terbaru.

**Query Parameters:**

- `page` (optional): Nomor halaman (default: 1)
- `limit` (optional): Jumlah bookmark per halaman (default: 10)

**Response:**

```json
{
  "data": [
    {
      "bookmark_id": "string",
      "comic": {
        "id": "string",
        "title": "string",
        "alternative_title": "string",
        "synopsis": "string",
        "status": "string",
        "country_id": "string",
        "view_count": 0,
        "vote_count": 0,
        "bookmark_count": 0,
        "cover_image_url": "string",
        "created_date": "string",
        "updated_date": "string",
        "latest_chapter": {
          "id": "string",
          "chapter_number": 1,
          "title": "string",
          "release_date": "string"
        }
      }
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 0,
    "total_pages": 0,
    "has_more": false
  }
}
```

---

### Add Bookmark [Auth Required]

**Endpoint:** `POST /bookmarks`

**Deskripsi:** Menambahkan komik ke bookmark user.

**Request Body:**

```json
{
  "id_komik": "string"
}
```

**Response:**

```json
{
  "id_user": "string",
  "id_komik": "string",
  "created_at": "string"
}
```

---

### Remove Bookmark [Auth Required]

**Endpoint:** `DELETE /bookmarks/{id}`

**Deskripsi:** Menghapus komik dari bookmark user.

**Path Parameters:**

- `id`: Comic ID

**Response:**

```json
{
  "success": true
}
```

---

## 👍 Votes

### Add Vote [Auth Required]

**Endpoint:** `POST /votes`

**Deskripsi:** Menambahkan vote untuk komik atau chapter.

**Request Body:**

```json
{
  "id_komik": "string",
  "id_chapter": "string"
}
```

**Note:** Hanya salah satu dari `id_komik` atau `id_chapter` yang boleh diisi.

**Response:**

```json
{
  "id_user": "string",
  "id_komik": "string",
  "id_chapter": "string",
  "created_at": "string"
}
```

---

### Remove Vote [Auth Required]

**Endpoint:** `DELETE /votes/{id}?type=comic|chapter`

**Deskripsi:** Menghapus vote dari komik atau chapter.

**Path Parameters:**

- `id`: Comic ID atau Chapter ID

**Query Parameters:**

- `type`: Tipe konten ('comic' atau 'chapter')

**Response:**

```json
{
  "success": true
}
```

---

## ⚙️ Setup

### Setup Admin User

**Endpoint:** `GET /setup`

**Deskripsi:** Membuat admin user untuk pertama kali (development only).

**Response:**

```json
{
  "message": "Admin user created successfully",
  "user": {
    "email": "master@bacakomik.com",
    "password": "Master1234"
  }
}
```

---

## 🔄 API Changes & Migration

### Popular & Recommended Comics Update

**Previous Implementation:**

- ❌ `/comics/discover` - Menggabungkan popular, recommended, dan search dalam satu endpoint
- ❌ Popular comics diambil dari `mKomik` berdasarkan `view_count`
- ❌ Recommended comics diambil dari `mKomik` berdasarkan `rank`

**New Implementation:**

- ✅ `/comics/popular` - Endpoint terpisah untuk popular comics dari tabel `mPopular`
- ✅ `/comics/recommended` - Endpoint terpisah untuk recommended comics dari tabel `mRecomed`
- ✅ Data diambil dari tabel yang sesuai dengan foreign key ke `mKomik`

### Flutter Implementation

Untuk discover tab, panggil kedua endpoint secara parallel:

```dart
// Service layer
Future<DiscoverComicsResponse> getDiscoverComics({int limit = 10}) async {
  // Call both endpoints in parallel
  final results = await Future.wait([
    getPopularComics(type: 'all_time', limit: limit),
    getRecommendedComics(limit: limit),
  ]);

  return DiscoverComicsResponse(
    popular: results[0].data,
    recommended: results[1].data,
  );
}

// Usage examples
final popularComics = await http.get('/api/comics/popular?type=harian&limit=15');
final recommendedComics = await http.get('/api/comics/recommended?limit=10');
```

### Benefits

1. **Clean Architecture** - Setiap endpoint memiliki purpose yang jelas
2. **Database Optimization** - Query langsung ke tabel yang tepat
3. **Flexibility** - Popular comics bisa difilter berdasarkan periode
4. **No Redundancy** - Tidak ada endpoint yang overlap functionality

---

## 📊 Data Types & Enums

### Comic Status

- `"On Going"` - Komik masih berlanjut
- `"Completed"` - Komik sudah selesai
- `"Break"` - Komik sedang break/hiatus

### Country ID

- `"KR"` - Korea
- `"JPN"` - Japan
- `"CN"` - China

### Error Codes

- `400` - Bad Request (parameter tidak valid)
- `401` - Unauthorized (token tidak valid atau tidak ada)
- `404` - Not Found (resource tidak ditemukan)
- `500` - Internal Server Error (error server)

---

## 🔄 Optimized Endpoints

Endpoint yang ditandai dengan **[Optimized]** telah dioptimasi untuk mengurangi jumlah request:

1. **`/comics/home`** - Menggabungkan data komik dengan chapter terbaru
2. **`/comics/popular`** - Data komik populer dari tabel `mPopular` dengan filter tipe periode
3. **`/comics/recommended`** - Data komik rekomendasi dari tabel `mRecomed`
4. **`/comics/{id}/complete`** - Detail komik lengkap dengan user data
5. **`/chapters/{id}/complete`** - Detail chapter lengkap dengan pages dan navigation

**Note:** Untuk discover tab di Flutter, panggil `/comics/popular` dan `/comics/recommended` secara parallel untuk mendapatkan data yang diperlukan.

Gunakan endpoint optimized ini untuk performa yang lebih baik di Flutter app.

---

## 📝 Usage Examples

### Popular Comics dengan Filter Tipe

```bash
# Popular comics harian
curl "http://localhost:3000/api/comics/popular?type=harian&limit=15"

# Popular comics mingguan
curl "http://localhost:3000/api/comics/popular?type=mingguan&limit=20"

# Popular comics bulanan
curl "http://localhost:3000/api/comics/popular?type=bulanan&limit=10"

# Popular comics all time (default)
curl "http://localhost:3000/api/comics/popular?type=all_time&limit=25"
```

### Recommended Comics

```bash
# Get recommended comics
curl "http://localhost:3000/api/comics/recommended?limit=10"
```

### Flutter Discover Tab Implementation

```dart
// Dalam DiscoverTab widget
class DiscoverTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return FutureBuilder(
          future: _loadDiscoverContent(ref),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildPopularSection(snapshot.data?.popular ?? []),
                  _buildRecommendedSection(snapshot.data?.recommended ?? []),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<DiscoverData> _loadDiscoverContent(WidgetRef ref) async {
    final results = await Future.wait([
      ref.read(comicServiceProvider).getPopularComics(type: 'all_time', limit: 10),
      ref.read(comicServiceProvider).getRecommendedComics(limit: 10),
    ]);

    return DiscoverData(
      popular: results[0].data,
      recommended: results[1].data,
    );
  }
}
```
