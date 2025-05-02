# BacaKomik API Documentation

This document provides details about the BacaKomik API endpoints for integration with Flutter or other clients.

## Base URL

```
https://baca-komik.vercel.app/api
```

## Authentication

Most endpoints require authentication using a JWT token. Include the token in the `Authorization` header:

```
Authorization: Bearer {token}
```

## Endpoints

### Comics

#### Get All Comics

```
GET /comics
```

Query Parameters:

- `page` (optional): Page number for pagination (default: 1)
- `limit` (optional): Number of comics per page (default: 20)
- `search` (optional): Search term to filter comics by title
- `sort` (optional): Field to sort by (default: 'updated_date')
- `order` (optional): Sort order, 'asc' or 'desc' (default: 'desc')
- `genre` (optional): Genre ID to filter by
- `status` (optional): Comic status to filter by ('ongoing', 'completed', 'hiatus')

Response:

```json
{
  "data": [
    {
      "id": "string",
      "title": "string",
      "alternative_title": "string",
      "synopsis": "string",
      "status": "string",
      "view_count": 0,
      "vote_count": 0,
      "bookmark_count": 0,
      "cover_image_url": "string",
      "created_date": "string",
      "updated_date": "string"
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

#### Get Comic Details

```
GET /comics/{id}
```

Path Parameters:

- `id`: Comic ID

Response:

```json
{
  "id": "string",
  "title": "string",
  "alternative_title": "string",
  "synopsis": "string",
  "status": "string",
  "view_count": 0,
  "vote_count": 0,
  "bookmark_count": 0,
  "cover_image_url": "string",
  "created_date": "string",
  "updated_date": "string",
  "chapters": [
    {
      "id": "string",
      "chapter_number": 0,
      "release_date": "string",
      "rating": 0,
      "view_count": 0,
      "vote_count": 0,
      "thumbnail_image_url": "string"
    }
  ],
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

#### Get Comic Chapters

```
GET /comics/{id}/chapters
```

Path Parameters:

- `id`: Comic ID

Query Parameters:

- `page` (optional): Page number for pagination (default: 1)
- `limit` (optional): Number of chapters per page (default: 20)
- `sort` (optional): Field to sort by (default: 'chapter_number')
- `order` (optional): Sort order, 'asc' or 'desc' (default: 'desc')

Response:

```json
{
  "comic": {
    "id": "string",
    "title": "string"
  },
  "data": [
    {
      "id": "string",
      "chapter_number": 0,
      "title": "string",
      "release_date": "string",
      "rating": 0,
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

### Chapters

#### Get Chapter Details

```
GET /chapters/{id}
```

Path Parameters:

- `id`: Chapter ID

Response:

```json
{
  "id": "string",
  "chapter_number": 0,
  "title": "string",
  "release_date": "string",
  "rating": 0,
  "view_count": 0,
  "vote_count": 0,
  "id_komik": "string",
  "thumbnail_image_url": "string",
  "comic": {
    "id": "string",
    "title": "string",
    "alternative_title": "string",
    "cover_image_url": "string"
  },
  "next_chapter": {
    "id": "string",
    "chapter_number": 0
  },
  "prev_chapter": {
    "id": "string",
    "chapter_number": 0
  }
}
```

#### Get Chapter Pages

```
GET /chapters/{id}/pages
```

Path Parameters:

- `id`: Chapter ID

Response:

```json
{
  "chapter": {
    "id": "string",
    "chapter_number": 0,
    "comic": {
      "id": "string",
      "title": "string"
    }
  },
  "pages": [
    {
      "id": "string",
      "id_chapter": "string",
      "page_number": 0,
      "image_url": "string"
    }
  ],
  "count": 0
}
```

### Comments

#### Get Comments

```
GET /comments/{id}
```

Path Parameters:

- `id`: Comic ID or Chapter ID

Query Parameters:

- `type` (optional): Type of content ('comic' or 'chapter', default: 'comic')
- `page` (optional): Page number for pagination (default: 1)
- `limit` (optional): Number of comments per page (default: 10)
- `parent_only` (optional): Only fetch parent comments (default: false)

Response:

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

#### Post Comment

```
POST /comments
```

Request Body:

```json
{
  "content": "string",
  "id_komik": "string", // Only for comic comments
  "id_chapter": "string", // Only for chapter comments
  "parent_id": "string" // Optional, for replies
}
```

Response:

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

### Bookmarks

#### Add Bookmark

```
POST /bookmarks
```

Request Body:

```json
{
  "id_komik": "string"
}
```

Response:

```json
{
  "success": true,
  "id": "string"
}
```

#### Get User Bookmarks

```
GET /bookmarks
```

Query Parameters:

- `page` (optional): Page number for pagination (default: 1)
- `limit` (optional): Number of bookmarks per page (default: 20)

Response:

```json
{
  "data": [
    {
      "id_komik": "string",
      "id_user": "string",
      "created_date": "string",
      "mKomik": {
        "id": "string",
        "title": "string",
        "cover_image_url": "string",
        "status": "string",
        "updated_date": "string"
      }
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

#### Remove Bookmark

```
DELETE /bookmarks/{id}
```

Path Parameters:

- `id`: Comic ID

Response:

```json
{
  "success": true
}
```

### Votes

#### Add Vote

```
POST /votes
```

Request Body:

```json
{
  "id": "string",
  "type": "comic" | "chapter"
}
```

Response:

```json
{
  "success": true
}
```

#### Remove Vote

```
DELETE /votes/{id}?type=comic|chapter
```

Path Parameters:

- `id`: Comic ID or Chapter ID

Query Parameters:

- `type`: Type of content ('comic' or 'chapter')

Response:

```json
{
  "success": true
}
```

### User

#### Get User Profile

```
GET /user/profile
```

Response:

```json
{
  "id": "string",
  "email": "string",
  "name": "string",
  "avatar_url": "string",
  "created_at": "string"
}
```

#### Update User Profile

```
PATCH /user/profile
```

Request Body:

```json
{
  "name": "string",
  "avatar_url": "string"
}
```

Response:

```json
{
  "success": true,
  "user": {
    "id": "string",
    "email": "string",
    "name": "string",
    "avatar_url": "string"
  }
}
```

## Error Responses

All API endpoints return error responses in the following format:

```json
{
  "error": "Error message"
}
```

Common HTTP status codes:

- 200: Success
- 400: Bad request
- 401: Unauthorized
- 404: Resource not found
- 500: Server error
