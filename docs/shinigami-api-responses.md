# Shinigami API Response Documentation

## Base URL

```
https://api.shngm.io/v1
```

## 1. Manga List - `/manga/list`

### Basic Request

```
GET /v1/manga/list
```

### With Parameters

```
GET /v1/manga/list?is_update=true&sort=latest
GET /v1/manga/list?search=tower
```

### Response Structure

```json
{
  "retcode": 0,
  "message": "success",
  "meta": {
    "request_id": "string",
    "timestamp": 1749526731986,
    "process_time": "4ms",
    "page": 1,
    "page_size": 12,
    "total_page": 69,
    "total_record": 825
  },
  "data": [
    {
      "manga_id": "c0f1d049-ff7f-474d-8c6a-3a55e4c44147",
      "title": "Demonic Emperor",
      "alternative_title": "Magic Emperor, 魔皇大管家",
      "description": "Long description text...",
      "release_year": "2019",
      "status": 1,
      "cover_image_url": "https://storage.shngm.id/low/unsafe/filters:format(webp):quality(70)/thumbnail/image/...",
      "cover_portrait_url": "https://storage.shngm.id/low/unsafe/filters:format(webp):quality(70)/thumbnail/image/...",
      "view_count": 38002128,
      "user_rate": 8.6,
      "bookmark_count": 25069,
      "rank": 1,
      "country_id": "CN",
      "is_recommended": true,
      "latest_chapter_id": "eb67d9c8-e605-4d84-9a42-de8d1b7dd2cc",
      "latest_chapter_number": 712,
      "latest_chapter_time": "2025-06-08T00:11:26Z",
      "taxonomy": {
        "Artist": [
          {
            "name": "Wuer Manhua",
            "slug": "wuer-manhua-0"
          }
        ],
        "Author": [
          {
            "name": "Wuer Manhua",
            "slug": "wuer-manhua"
          }
        ],
        "Format": [
          {
            "name": "Manhua",
            "slug": "manhua"
          }
        ],
        "Genre": [
          {
            "name": "Action",
            "slug": "action"
          }
        ],
        "Type": [
          {
            "name": "Project",
            "slug": "project"
          }
        ]
      },
      "created_at": "2024-11-23T22:43:06Z",
      "updated_at": "2025-06-10T03:00:39Z",
      "deleted_at": null
    }
  ],
  "facet": {
    "release_year": {
      "2014": 1,
      "2021": 4
    },
    "taxonomy.Format.name": {
      "Manga": 82,
      "Manhua": 122,
      "Manhwa": 621
    }
  }
}
```

### Special Response for `is_update=true&sort=latest`

When using `is_update=true&sort=latest`, each manga item includes additional `chapters` array:

```json
{
  "chapters": [
    {
      "chapter_id": "3346cef3-2863-47f0-9db5-587fc7e4a6d7",
      "chapter_number": 12,
      "created_at": "2025-06-10T02:51:35Z"
    }
  ]
}
```

## 2. Manga Detail - `/manga/detail/{manga_id}`

### Request

```
GET /v1/manga/detail/7a20d073-50d9-44d1-be75-5b4c5516317e
```

### Response Structure

```json
{
  "retcode": 0,
  "message": "success",
  "meta": {
    "request_id": "string",
    "timestamp": 1749523945061,
    "process_time": "7ms"
  },
  "data": {
    "manga_id": "7a20d073-50d9-44d1-be75-5b4c5516317e",
    "title": "Tower Of God: Side Story Urek Mazino",
    "description": "Ini side story pertama dari Tower of God...",
    "alternative_title": "Tower of God: Urek's Ascent, 우렉 마지노, Urek Maginot",
    "release_year": "2025",
    "status": 1,
    "cover_image_url": "https://storage.shngm.id/low/unsafe/filters:format(webp):quality(70)/thumbnail/image/...",
    "cover_portrait_url": "",
    "view_count": 123447,
    "user_rate": 7.5,
    "bookmark_count": 926,
    "rank": 699,
    "country_id": "KR",
    "latest_chapter_id": "3346cef3-2863-47f0-9db5-587fc7e4a6d7",
    "latest_chapter_number": 12,
    "latest_chapter_time": "2025-06-10T02:51:35Z",
    "taxonomy": {
      "Artist": [
        {
          "slug": "e4f7c18f-e07f-4e83-b4f2-8baaa73980b3",
          "name": "SIU"
        }
      ],
      "Author": [
        {
          "slug": "01a46e29-a862-4925-85a6-301164cd8590",
          "name": "SIU"
        }
      ],
      "Format": [
        {
          "slug": "manhwa",
          "name": "Manhwa"
        }
      ],
      "Genre": [
        {
          "slug": "action",
          "name": "Action"
        }
      ],
      "Type": [
        {
          "slug": "mirror",
          "name": "Mirror"
        }
      ]
    },
    "created_at": "2025-05-04T08:50:55Z",
    "updated_at": "2025-06-10T02:51:37Z",
    "deleted_at": null
  }
}
```

## 3. Chapter Detail - `/chapter/detail/{chapter_id}`

### Request

```
GET /v1/chapter/detail/3346cef3-2863-47f0-9db5-587fc7e4a6d7
```

### Response Structure

```json
{
  "retcode": 0,
  "message": "success",
  "meta": {
    "request_id": "string",
    "timestamp": 1749523944100,
    "process_time": "44ms"
  },
  "data": {
    "chapter_id": "3346cef3-2863-47f0-9db5-587fc7e4a6d7",
    "manga_id": "7a20d073-50d9-44d1-be75-5b4c5516317e",
    "chapter_number": 12,
    "chapter_title": "",
    "base_url": "https://storage.shngm.id",
    "base_url_low": "https://storage.shngm.id/low/unsafe/filters:format(webp):quality(70)",
    "chapter": {
      "path": "/chapter/manga_7a20d073-50d9-44d1-be75-5b4c5516317e/chapter_3346cef3-2863-47f0-9db5-587fc7e4a6d7/",
      "data": ["1-4be16b.jpg", "2-cfbbae.jpg", "3-8c623e.jpg"]
    },
    "thumbnail_image_url": "https://storage.shngm.id/thumbnail/image/default.jpg",
    "view_count": 0,
    "prev_chapter_id": "9f826ef9-6285-4f1a-ae69-9d81ffaf5e56",
    "prev_chapter_number": 11,
    "next_chapter_id": null,
    "next_chapter_number": null,
    "release_date": "2025-06-10T02:51:35Z",
    "created_at": "2025-06-10T02:51:35Z",
    "updated_at": "2025-06-10T02:51:35Z"
  }
}
```

### Image URL Construction

Full image URLs are constructed as:

```
{base_url}{chapter.path}{filename}
```

Example:

```
https://storage.shngm.id/chapter/manga_7a20d073-50d9-44d1-be75-5b4c5516317e/chapter_3346cef3-2863-47f0-9db5-587fc7e4a6d7/1-4be16b.jpg
```

Low quality version:

```
{base_url_low}{chapter.path}{filename}
```

## 4. Format List - `/format/list`

### Request

```
GET /v1/format/list
```

### Response Structure

```json
{
  "retcode": 0,
  "message": "success",
  "meta": {
    "request_id": "string",
    "timestamp": 1749524372390,
    "process_time": "0ms"
  },
  "data": [
    {
      "slug": "manga",
      "name": "Manga"
    },
    {
      "slug": "manhua",
      "name": "Manhua"
    },
    {
      "slug": "manhwa",
      "name": "Manhwa"
    }
  ]
}
```

## 5. Genre List - `/genre/list`

### Request

```
GET /v1/genre/list
```

### Response Structure

```json
{
  "retcode": 0,
  "message": "success",
  "meta": {
    "request_id": "string",
    "timestamp": 1749523910758,
    "process_time": "19ms"
  },
  "data": [
    {
      "slug": "action",
      "name": "Action"
    },
    {
      "slug": "adventure",
      "name": "Adventure"
    }
  ]
}
```

## Chapter List Endpoint

### GET /v1/chapter/{manga_id}/list

**URL:** `https://api.shngm.io/v1/chapter/4b42395f-8cb2-4e42-bddd-662f4d6683bd/list?page=1&page_size=24&sort_by=chapter_number&sort_order=desc`

**Parameters:**

- `manga_id` (path): Manga ID untuk mengambil chapter list
- `page` (query): Nomor halaman (default: 1)
- `page_size` (query): Jumlah item per halaman (default: 24)
- `sort_by` (query): Field untuk sorting (default: chapter_number)
- `sort_order` (query): Urutan sorting asc/desc (default: desc)

**Response:**

```json
{
  "retcode": 0,
  "message": "success",
  "meta": {
    "request_id": "13143deb-2125-4ace-a435-b02a6ff0fb79",
    "timestamp": 1749535942368,
    "process_time": "0ms",
    "page": 1,
    "page_size": 24,
    "total_page": 4,
    "total_record": 77
  },
  "data": [
    {
      "chapter_id": "39237605-c631-4c48-978e-fb421eb0984d",
      "manga_id": "4b42395f-8cb2-4e42-bddd-662f4d6683bd",
      "chapter_title": "Reuni",
      "chapter_number": 76,
      "thumbnail_image_url": "https://storage.shngm.id/low/unsafe/filters:format(webp):quality(70)/thumbnail/image/b21756de-8ff3-48ff-a3a4-5f41f83820c7.jpg",
      "view_count": 57092,
      "release_date": "2025-06-09T15:26:08Z"
    },
    {
      "chapter_id": "315c4850-6978-4350-ba2b-91f98331a92c",
      "manga_id": "4b42395f-8cb2-4e42-bddd-662f4d6683bd",
      "chapter_title": "Kebangkitan kembali",
      "chapter_number": 75,
      "thumbnail_image_url": "https://storage.shngm.id/low/unsafe/filters:format(webp):quality(70)/thumbnail/image/91a51b74-c8d3-4f6b-9754-9d2a4cd844a6.jpg",
      "view_count": 92639,
      "release_date": "2025-05-26T15:47:48Z"
    }
  ]
}
```

**Response Fields:**

- `retcode`: Response code (0 = success)
- `message`: Response message
- `meta.page`: Current page number
- `meta.page_size`: Items per page
- `meta.total_page`: Total number of pages
- `meta.total_record`: Total number of records
- `data[].chapter_id`: Unique chapter identifier
- `data[].manga_id`: Parent manga identifier
- `data[].chapter_title`: Chapter title
- `data[].chapter_number`: Chapter number
- `data[].thumbnail_image_url`: Chapter thumbnail URL
- `data[].view_count`: Number of views
- `data[].release_date`: Release date in ISO 8601 format

## Notes

1. **Pagination**: All list endpoints support pagination with `page` parameter
2. **Search**: Use `search` parameter in `/manga/list` for searching
3. **Filtering**: Use `is_update=true&sort=latest` for latest updates
4. **Image URLs**: Always use the provided base_url + path + filename structure
5. **Chapter Navigation**: Use `prev_chapter_id` and `next_chapter_id` for navigation
6. **Status Codes**:
   - `retcode: 0` = Success
   - `retcode: 1` = Error (assumed)
7. **Timestamps**: All timestamps are in ISO 8601 format
8. **Missing Endpoints**: Chapter list endpoint for specific manga not found (404)
