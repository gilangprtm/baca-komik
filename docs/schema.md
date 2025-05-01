# BacaKomik Database Schema

## Comic-Related Tables

### mKomik (Comic Master Table)

| Column            | Type      | Description                               |
| ----------------- | --------- | ----------------------------------------- |
| id                | uuid      | Primary key                               |
| title             | text      | Main title of the comic                   |
| alternative_title | text      | Alternative title, if any                 |
| country_id        | text      | Enum: KR (Korea), JPN (Japan), CN (China) |
| cover_image_url   | text      | URL to cover image                        |
| description       | text      | Comic description/summary                 |
| release_year      | integer   | Year of release                           |
| vote_count        | integer   | Number of votes received                  |
| rank              | float     | Calculated rank based on votes and views  |
| view_count        | integer   | Number of views                           |
| bookmark_count    | integer   | Number of bookmarks                       |
| created_date      | timestamp | Date when record was created              |

### mChapter (Chapter Master Table)

| Column              | Type      | Description                                    |
| ------------------- | --------- | ---------------------------------------------- |
| id                  | uuid      | Primary key                                    |
| id_komik            | uuid      | Foreign key to mKomik                          |
| chapter_number      | float     | Chapter number (allows for decimals like 10.5) |
| release_date        | timestamp | Release date of chapter                        |
| rating              | float     | Rating score                                   |
| view_count          | integer   | Number of views                                |
| vote_count          | integer   | Number of votes                                |
| thumbnail_image_url | text      | URL to chapter thumbnail                       |
| created_date        | timestamp | Date when record was created                   |

### trChapter (Chapter Pages Table)

| Column      | Type    | Description             |
| ----------- | ------- | ----------------------- |
| id_chapter  | uuid    | Foreign key to mChapter |
| page_number | integer | Page sequence number    |
| page_url    | text    | URL to page image       |

## Vote-Related Tables

### mKomikVote (Comic Votes Table)

| Column   | Type | Description           |
| -------- | ---- | --------------------- |
| id_komik | uuid | Foreign key to mKomik |
| id_user  | uuid | Foreign key to mUser  |

### trChapterVote (Chapter Votes Table)

| Column     | Type | Description             |
| ---------- | ---- | ----------------------- |
| id_chapter | uuid | Foreign key to mChapter |
| id_user    | uuid | Foreign key to mUser    |

## Metadata Tables

### mArtist

| Column | Type | Description |
| ------ | ---- | ----------- |
| id     | uuid | Primary key |
| name   | text | Artist name |

### trArtist (Comic-Artist Relationship)

| Column    | Type | Description            |
| --------- | ---- | ---------------------- |
| id_komik  | uuid | Foreign key to mKomik  |
| id_artist | uuid | Foreign key to mArtist |

### mAuthor

| Column | Type | Description |
| ------ | ---- | ----------- |
| id     | uuid | Primary key |
| name   | text | Author name |

### trAuthor (Comic-Author Relationship)

| Column    | Type | Description            |
| --------- | ---- | ---------------------- |
| id_komik  | uuid | Foreign key to mKomik  |
| id_author | uuid | Foreign key to mAuthor |

### mFormat

| Column | Type | Description                               |
| ------ | ---- | ----------------------------------------- |
| id     | uuid | Primary key                               |
| name   | text | Format name (e.g., Manga, Manhwa, Manhua) |

### trFormat (Comic-Format Relationship)

| Column    | Type | Description            |
| --------- | ---- | ---------------------- |
| id_komik  | uuid | Foreign key to mKomik  |
| id_format | uuid | Foreign key to mFormat |

### mGenre

| Column | Type | Description |
| ------ | ---- | ----------- |
| id     | uuid | Primary key |
| name   | text | Genre name  |

### trGenre (Comic-Genre Relationship)

| Column   | Type | Description           |
| -------- | ---- | --------------------- |
| id_komik | uuid | Foreign key to mKomik |
| id_genre | uuid | Foreign key to mGenre |

## Featured Tables

### mRecomed (Recommended Comics)

| Column   | Type | Description           |
| -------- | ---- | --------------------- |
| id_komik | uuid | Foreign key to mKomik |

### mPopular (Popular Comics)

| Column   | Type | Description                                                           |
| -------- | ---- | --------------------------------------------------------------------- |
| id_komik | uuid | Foreign key to mKomik                                                 |
| type     | text | Time period: harian(daily)/mingguan(weekly)/bulanan(monthly)/all time |

## User-Related Tables

### mUser

| Column     | Type | Description                |
| ---------- | ---- | -------------------------- |
| id         | uuid | Primary key                |
| name       | text | User's display name        |
| avatar_url | text | URL to user's avatar image |

### trUserHistory (Reading History)

| Column     | Type    | Description                       |
| ---------- | ------- | --------------------------------- |
| id_user    | uuid    | Foreign key to mUser              |
| id_komik   | uuid    | Foreign key to mKomik             |
| id_chapter | uuid    | Foreign key to mChapter           |
| is_read    | boolean | Whether the chapter was completed |

### trUserBookmark (Bookmarked Comics)

| Column   | Type | Description           |
| -------- | ---- | --------------------- |
| id_user  | uuid | Foreign key to mUser  |
| id_komik | uuid | Foreign key to mKomik |

## Comment-Related Tables

### trComments (Comments Table)

| Column       | Type      | Description                                                      |
| ------------ | --------- | ---------------------------------------------------------------- |
| id           | uuid      | Primary key                                                      |
| parent_id    | uuid      | Self-reference for nested comments (NULL for top-level comments) |
| id_user      | uuid      | Foreign key to mUser                                             |
| id_komik     | uuid      | Foreign key to mKomik (NULL if comment is for a chapter)         |
| id_chapter   | uuid      | Foreign key to mChapter (NULL if comment is for a comic)         |
| content      | text      | Comment content                                                  |
| created_date | timestamp | Date when comment was created                                    |
