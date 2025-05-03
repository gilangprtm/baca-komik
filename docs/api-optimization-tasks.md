# API Optimization Tasks for BacaKomik Mobile App

## Background
Aplikasi BacaKomik saat ini menggunakan beberapa endpoint API terpisah yang menyebabkan terlalu banyak request pada satu halaman. Hal ini berdampak pada:
1. Performa aplikasi yang lambat
2. Penggunaan data seluler yang boros
3. Beban server yang tinggi
4. Pengalaman pengguna yang kurang optimal

## Endpoint Optimasi yang Dibutuhkan

### 1. Home Page Optimization
**Endpoint Baru:** `GET /comics/home`

**Deskripsi:**
Menggabungkan data komik dan 2 chapter terbaru untuk setiap komik dalam satu request.

**Parameter:**
- `page`: Halaman yang diminta
- `limit`: Jumlah komik per halaman

**Respons:**
```json
{
  "data": [
    {
      "id": "string",
      "title": "string",
      "alternative_title": "string",
      "cover_image_url": "string",
      "country_id": "string",
      "latest_chapters": [
        {
          "id": "string",
          "chapter_number": 0,
          "title": "string",
          "release_date": "string"
        }
      ]
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "total_pages": 10,
    "has_more": true
  }
}
```

**Status:** 🟢 Selesai

### 2. Search/Discover Page Optimization
**Endpoint Baru:** `GET /comics/discover`

**Deskripsi:**
Menggabungkan data komik populer, rekomendasi, dan hasil pencarian dalam satu request.

**Parameter:**
- `page`: Halaman yang diminta
- `limit`: Jumlah item per halaman
- `search`: Query pencarian (opsional)
- `genre`: Filter genre (opsional)
- `format`: Filter format (opsional)

**Respons:**
```json
{
  "popular": [
    {
      "id": "string",
      "title": "string",
      "cover_image_url": "string",
      "country_id": "string",
      "view_count": 0
    }
  ],
  "recommended": [
    {
      "id": "string",
      "title": "string",
      "cover_image_url": "string",
      "country_id": "string"
    }
  ],
  "search_results": {
    "data": [],
    "meta": {}
  }
}
```

**Status:** 🟢 Selesai

### 3. Bookmark Page Optimization
**Endpoint Baru:** `GET /bookmarks/details`

**Deskripsi:**
Menggabungkan data bookmark dengan detail komik dalam satu request.

**Parameter:**
- `page`: Halaman yang diminta
- `limit`: Jumlah bookmark per halaman

**Respons:**
```json
{
  "data": [
    {
      "bookmark_id": "string",
      "comic": {
        "id": "string",
        "title": "string",
        "cover_image_url": "string",
        "country_id": "string",
        "latest_chapter": {
          "id": "string",
          "chapter_number": 0,
          "title": "string"
        }
      },
      "created_date": "string"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 50,
    "total_pages": 3,
    "has_more": true
  }
}
```

**Status:** 🟢 Selesai

### 4. Comic Detail Page Optimization
**Endpoint Baru:** `GET /comics/{id}/complete`

**Deskripsi:**
Menggabungkan detail komik, daftar chapter, dan informasi user (bookmark, vote) dalam satu request.

**Parameter:**
- `id`: ID komik

**Respons:**
```json
{
  "comic": {
    "id": "string",
    "title": "string",
    "alternative_title": "string",
    "synopsis": "string",
    "status": "string",
    "view_count": 0,
    "vote_count": 0,
    "bookmark_count": 0,
    "cover_image_url": "string",
    "genres": [],
    "authors": [],
    "artists": [],
    "formats": []
  },
  "chapters": {
    "data": [],
    "meta": {}
  },
  "user_data": {
    "is_bookmarked": true,
    "is_voted": false,
    "last_read_chapter": "chapter_id"
  }
}
```

**Status:** 🟢 Selesai

### 5. Chapter Detail Page Optimization
**Endpoint Baru:** `GET /chapters/{id}/complete`

**Deskripsi:**
Menggabungkan detail chapter, daftar halaman, dan navigasi chapter dalam satu request.

**Parameter:**
- `id`: ID chapter

**Respons:**
```json
{
  "chapter": {
    "id": "string",
    "chapter_number": 0,
    "title": "string",
    "release_date": "string",
    "comic": {
      "id": "string",
      "title": "string"
    }
  },
  "pages": [
    {
      "id": "string",
      "page_number": 0,
      "image_url": "string"
    }
  ],
  "navigation": {
    "prev_chapter": {
      "id": "string",
      "chapter_number": 0
    },
    "next_chapter": {
      "id": "string",
      "chapter_number": 0
    }
  }
}
```

**Status:** 🟢 Selesai

### 6. User Profile Page Optimization
**Endpoint Baru:** `GET /user/complete-profile`

**Deskripsi:**
Menggabungkan profil user, statistik, dan aktivitas terbaru dalam satu request.

**Respons:**
```json
{
  "user": {
    "id": "string",
    "name": "string",
    "email": "string",
    "avatar_url": "string",
    "created_at": "string"
  },
  "stats": {
    "bookmark_count": 0,
    "comment_count": 0,
    "vote_count": 0
  },
  "recent_activity": {
    "last_read": [
      {
        "comic_id": "string",
        "comic_title": "string",
        "chapter_id": "string",
        "chapter_number": 0,
        "read_at": "string"
      }
    ]
  }
}
```

**Status:** 🔴 Belum Dimulai

## Implementasi di Mobile App

### 1. Perubahan pada Repository Layer
- Menambahkan method baru untuk endpoint yang dioptimasi
- Menyesuaikan model data untuk respons yang baru

### 2. Perubahan pada Service Layer
- Menggunakan endpoint yang dioptimasi
- Mempertahankan kompatibilitas dengan endpoint lama sebagai fallback

### 3. Caching Strategy
- Implementasi caching untuk data yang jarang berubah
- Strategi invalidasi cache yang efektif

### 4. Offline Support
- Menyimpan data penting secara lokal
- Sinkronisasi data ketika kembali online

## Timeline
- **Fase 1:** Implementasi endpoint Home dan Detail Komik
- **Fase 2:** Implementasi endpoint Search/Discover dan Bookmark
- **Fase 3:** Implementasi endpoint Chapter dan User Profile
- **Fase 4:** Pengujian dan optimasi

## Prioritas
1. Home Page Optimization (Tinggi)
2. Comic Detail Page Optimization (Tinggi)
3. Chapter Detail Page Optimization (Tinggi)
4. Bookmark Page Optimization (Sedang)
5. Search/Discover Page Optimization (Sedang)
6. User Profile Page Optimization (Rendah)
