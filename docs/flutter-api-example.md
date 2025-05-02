# Flutter Integration Examples

This document provides examples of how to use the BacaKomik API in a Flutter application.

## Setup

First, add the necessary dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
```

## API Service Class

Create an API service class to handle all API calls:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BacaKomikApiService {
  static const String baseUrl = 'https://baca-komik.vercel.app/api';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Get the authentication token
  Future<String?> getToken() async {
    return await secureStorage.read(key: 'auth_token');
  }

  // Set the authentication token
  Future<void> setToken(String token) async {
    await secureStorage.write(key: 'auth_token', value: token);
  }

  // Clear the authentication token (logout)
  Future<void> clearToken() async {
    await secureStorage.delete(key: 'auth_token');
  }

  // Helper method to create headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Generic GET request
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final headers = await _getHeaders();

    String url = '$baseUrl$endpoint';
    if (queryParams != null) {
      final queryString = Uri(queryParameters: queryParams).query;
      url = '$url?$queryString';
    }

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body),
      );
    }
  }

  // Generic POST request
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? json.encode(body) : null,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body),
      );
    }
  }

  // Generic DELETE request
  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? queryParams}) async {
    final headers = await _getHeaders();

    String url = '$baseUrl$endpoint';
    if (queryParams != null) {
      final queryString = Uri(queryParameters: queryParams).query;
      url = '$url?$queryString';
    }

    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response.body),
      );
    }
  }

  // Parse error message from response
  String _parseErrorMessage(String responseBody) {
    try {
      final data = json.decode(responseBody);
      return data['error'] ?? 'Unknown error';
    } catch (_) {
      return 'Unknown error';
    }
  }
}

// Exception class for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $statusCode - $message';
}
```

## Usage Examples

### Authentication

```dart
class AuthService {
  final BacaKomikApiService apiService = BacaKomikApiService();

  Future<bool> login(String email, String password) async {
    try {
      final response = await apiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      if (response['token'] != null) {
        await apiService.setToken(response['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await apiService.clearToken();
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await apiService.get('/user/profile');
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }
}
```

### Comics

```dart
class ComicService {
  final BacaKomikApiService apiService = BacaKomikApiService();

  // Get all comics with pagination and filtering
  Future<List<Comic>> getComics({
    int page = 1,
    int limit = 20,
    String? search,
    String? sort,
    String? order,
    String? genre,
    String? status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null) 'search': search,
        if (sort != null) 'sort': sort,
        if (order != null) 'order': order,
        if (genre != null) 'genre': genre,
        if (status != null) 'status': status,
      };

      final response = await apiService.get('/comics', queryParams: queryParams);

      final List<Comic> comics = (response['data'] as List)
          .map((json) => Comic.fromJson(json))
          .toList();

      return comics;
    } catch (e) {
      print('Get comics error: $e');
      return [];
    }
  }

  // Get comic details by ID
  Future<Comic?> getComicDetails(String id) async {
    try {
      final response = await apiService.get('/comics/$id');
      return Comic.fromJson(response);
    } catch (e) {
      print('Get comic details error: $e');
      return null;
    }
  }

  // Get chapters for a comic
  Future<List<Chapter>> getComicChapters(String comicId, {
    int page = 1,
    int limit = 20,
    String sort = 'chapter_number',
    String order = 'desc',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
        'order': order,
      };

      final response = await apiService.get('/comics/$comicId/chapters',
          queryParams: queryParams);

      final List<Chapter> chapters = (response['data'] as List)
          .map((json) => Chapter.fromJson(json))
          .toList();

      return chapters;
    } catch (e) {
      print('Get comic chapters error: $e');
      return [];
    }
  }
}

// Models
class Comic {
  final String id;
  final String title;
  final String? alternativeTitle;
  final String? synopsis;
  final String status;
  final int viewCount;
  final int voteCount;
  final int bookmarkCount;
  final String? coverImageUrl;
  final DateTime createdDate;
  final DateTime updatedDate;
  final List<Chapter>? chapters;
  final List<Genre>? genres;
  final List<Author>? authors;
  final List<Artist>? artists;
  final List<Format>? formats;

  Comic({
    required this.id,
    required this.title,
    this.alternativeTitle,
    this.synopsis,
    required this.status,
    required this.viewCount,
    required this.voteCount,
    required this.bookmarkCount,
    this.coverImageUrl,
    required this.createdDate,
    required this.updatedDate,
    this.chapters,
    this.genres,
    this.authors,
    this.artists,
    this.formats,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      id: json['id'],
      title: json['title'],
      alternativeTitle: json['alternative_title'],
      synopsis: json['synopsis'],
      status: json['status'],
      viewCount: json['view_count'] ?? 0,
      voteCount: json['vote_count'] ?? 0,
      bookmarkCount: json['bookmark_count'] ?? 0,
      coverImageUrl: json['cover_image_url'],
      createdDate: DateTime.parse(json['created_date']),
      updatedDate: DateTime.parse(json['updated_date']),
      chapters: json['chapters'] != null
          ? (json['chapters'] as List).map((e) => Chapter.fromJson(e)).toList()
          : null,
      genres: json['genres'] != null
          ? (json['genres'] as List).map((e) => Genre.fromJson(e)).toList()
          : null,
      authors: json['authors'] != null
          ? (json['authors'] as List).map((e) => Author.fromJson(e)).toList()
          : null,
      artists: json['artists'] != null
          ? (json['artists'] as List).map((e) => Artist.fromJson(e)).toList()
          : null,
      formats: json['formats'] != null
          ? (json['formats'] as List).map((e) => Format.fromJson(e)).toList()
          : null,
    );
  }
}

class Chapter {
  final String id;
  final double chapterNumber;
  final String? title;
  final DateTime releaseDate;
  final double rating;
  final int viewCount;
  final int voteCount;
  final String? thumbnailImageUrl;

  Chapter({
    required this.id,
    required this.chapterNumber,
    this.title,
    required this.releaseDate,
    required this.rating,
    required this.viewCount,
    required this.voteCount,
    this.thumbnailImageUrl,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      chapterNumber: json['chapter_number']?.toDouble() ?? 0,
      title: json['title'],
      releaseDate: DateTime.parse(json['release_date']),
      rating: json['rating']?.toDouble() ?? 0,
      viewCount: json['view_count'] ?? 0,
      voteCount: json['vote_count'] ?? 0,
      thumbnailImageUrl: json['thumbnail_image_url'],
    );
  }
}

// Other model classes (Genre, Author, Artist, Format, etc.)
```

### Chapter Reading

```dart
class ChapterService {
  final BacaKomikApiService apiService = BacaKomikApiService();

  // Get chapter details by ID
  Future<ChapterDetail?> getChapter(String id) async {
    try {
      final response = await apiService.get('/chapters/$id');
      return ChapterDetail.fromJson(response);
    } catch (e) {
      print('Get chapter error: $e');
      return null;
    }
  }

  // Get chapter pages by chapter ID
  Future<ChapterPages?> getChapterPages(String id) async {
    try {
      final response = await apiService.get('/chapters/$id/pages');
      return ChapterPages.fromJson(response);
    } catch (e) {
      print('Get chapter pages error: $e');
      return null;
    }
  }
}

// Models
class ChapterDetail {
  final String id;
  final double chapterNumber;
  final String? title;
  final DateTime releaseDate;
  final double rating;
  final int viewCount;
  final int voteCount;
  final String idKomik;
  final String? thumbnailImageUrl;
  final ComicDetail comic;
  final ChapterNavigation? nextChapter;
  final ChapterNavigation? prevChapter;

  ChapterDetail({
    required this.id,
    required this.chapterNumber,
    this.title,
    required this.releaseDate,
    required this.rating,
    required this.viewCount,
    required this.voteCount,
    required this.idKomik,
    this.thumbnailImageUrl,
    required this.comic,
    this.nextChapter,
    this.prevChapter,
  });

  factory ChapterDetail.fromJson(Map<String, dynamic> json) {
    return ChapterDetail(
      id: json['id'],
      chapterNumber: json['chapter_number']?.toDouble() ?? 0,
      title: json['title'],
      releaseDate: DateTime.parse(json['release_date']),
      rating: json['rating']?.toDouble() ?? 0,
      viewCount: json['view_count'] ?? 0,
      voteCount: json['vote_count'] ?? 0,
      idKomik: json['id_komik'],
      thumbnailImageUrl: json['thumbnail_image_url'],
      comic: ComicDetail.fromJson(json['comic']),
      nextChapter: json['next_chapter'] != null
          ? ChapterNavigation.fromJson(json['next_chapter'])
          : null,
      prevChapter: json['prev_chapter'] != null
          ? ChapterNavigation.fromJson(json['prev_chapter'])
          : null,
    );
  }
}

class ComicDetail {
  final String id;
  final String title;
  final String? alternativeTitle;
  final String? coverImageUrl;

  ComicDetail({
    required this.id,
    required this.title,
    this.alternativeTitle,
    this.coverImageUrl,
  });

  factory ComicDetail.fromJson(Map<String, dynamic> json) {
    return ComicDetail(
      id: json['id'],
      title: json['title'],
      alternativeTitle: json['alternative_title'],
      coverImageUrl: json['cover_image_url'],
    );
  }
}

class ChapterNavigation {
  final String id;
  final double chapterNumber;

  ChapterNavigation({
    required this.id,
    required this.chapterNumber,
  });

  factory ChapterNavigation.fromJson(Map<String, dynamic> json) {
    return ChapterNavigation(
      id: json['id'],
      chapterNumber: json['chapter_number']?.toDouble() ?? 0,
    );
  }
}

class ChapterPages {
  final ChapterInfo chapter;
  final List<Page> pages;
  final int count;

  ChapterPages({
    required this.chapter,
    required this.pages,
    required this.count,
  });

  factory ChapterPages.fromJson(Map<String, dynamic> json) {
    return ChapterPages(
      chapter: ChapterInfo.fromJson(json['chapter']),
      pages: (json['pages'] as List).map((e) => Page.fromJson(e)).toList(),
      count: json['count'],
    );
  }
}

class ChapterInfo {
  final String id;
  final double chapterNumber;
  final ComicInfo comic;

  ChapterInfo({
    required this.id,
    required this.chapterNumber,
    required this.comic,
  });

  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    return ChapterInfo(
      id: json['id'],
      chapterNumber: json['chapter_number']?.toDouble() ?? 0,
      comic: ComicInfo.fromJson(json['comic']),
    );
  }
}

class ComicInfo {
  final String id;
  final String title;

  ComicInfo({
    required this.id,
    required this.title,
  });

  factory ComicInfo.fromJson(Map<String, dynamic> json) {
    return ComicInfo(
      id: json['id'],
      title: json['title'],
    );
  }
}

class Page {
  final String id;
  final String idChapter;
  final int pageNumber;
  final String imageUrl;

  Page({
    required this.id,
    required this.idChapter,
    required this.pageNumber,
    required this.imageUrl,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json['id'],
      idChapter: json['id_chapter'],
      pageNumber: json['page_number'],
      imageUrl: json['image_url'],
    );
  }
}
```

### Bookmarks

```dart
class BookmarkService {
  final BacaKomikApiService apiService = BacaKomikApiService();

  // Get user bookmarks
  Future<List<Bookmark>> getBookmarks({int page = 1, int limit = 20}) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await apiService.get('/bookmarks', queryParams: queryParams);

      final List<Bookmark> bookmarks = (response['data'] as List)
          .map((json) => Bookmark.fromJson(json))
          .toList();

      return bookmarks;
    } catch (e) {
      print('Get bookmarks error: $e');
      return [];
    }
  }

  // Add bookmark
  Future<bool> addBookmark(String comicId) async {
    try {
      final response = await apiService.post('/bookmarks', body: {
        'id_komik': comicId,
      });

      return response['success'] == true;
    } catch (e) {
      print('Add bookmark error: $e');
      return false;
    }
  }

  // Remove bookmark
  Future<bool> removeBookmark(String comicId) async {
    try {
      final response = await apiService.delete('/bookmarks/$comicId');
      return response['success'] == true;
    } catch (e) {
      print('Remove bookmark error: $e');
      return false;
    }
  }
}

// Models
class Bookmark {
  final String idKomik;
  final String idUser;
  final DateTime createdDate;
  final BookmarkComic comic;

  Bookmark({
    required this.idKomik,
    required this.idUser,
    required this.createdDate,
    required this.comic,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      idKomik: json['id_komik'],
      idUser: json['id_user'],
      createdDate: DateTime.parse(json['created_date']),
      comic: BookmarkComic.fromJson(json['mKomik']),
    );
  }
}

class BookmarkComic {
  final String id;
  final String title;
  final String? coverImageUrl;
  final String status;
  final DateTime updatedDate;

  BookmarkComic({
    required this.id,
    required this.title,
    this.coverImageUrl,
    required this.status,
    required this.updatedDate,
  });

  factory BookmarkComic.fromJson(Map<String, dynamic> json) {
    return BookmarkComic(
      id: json['id'],
      title: json['title'],
      coverImageUrl: json['cover_image_url'],
      status: json['status'],
      updatedDate: DateTime.parse(json['updated_date']),
    );
  }
}
```

## Example Flutter UI

Here's an example of how to integrate the API with Flutter UI:

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ComicListPage extends StatefulWidget {
  @override
  _ComicListPageState createState() => _ComicListPageState();
}

class _ComicListPageState extends State<ComicListPage> {
  final ComicService _comicService = ComicService();
  List<Comic> _comics = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _loadComics();
  }

  Future<void> _loadComics() async {
    if (!_hasMorePages) return;

    setState(() {
      _isLoading = true;
    });

    final comics = await _comicService.getComics(page: _currentPage);

    setState(() {
      _comics.addAll(comics);
      _currentPage++;
      _isLoading = false;
      _hasMorePages = comics.length == 20; // Assuming limit is 20
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BacaKomik'),
      ),
      body: _isLoading && _comics.isEmpty
          ? Center(child: CircularProgressIndicator())
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                  _loadComics();
                  return true;
                }
                return false;
              },
              child: GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _comics.length + (_hasMorePages ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _comics.length) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final comic = _comics[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComicDetailPage(comicId: comic.id),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                              child: comic.coverImageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: comic.coverImageUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: Icon(Icons.image, size: 50),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comic.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.remove_red_eye, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      comic.viewCount.toString(),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.thumb_up, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      comic.voteCount.toString(),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
```

## Error Handling

Create a wrapper widget for error handling:

```dart
class ApiErrorHandler extends StatelessWidget {
  final Future<void> Function() onRetry;
  final Widget child;

  const ApiErrorHandler({
    Key? key,
    required this.onRetry,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: onRetry(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => onRetry(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return child;
        }
      },
    );
  }
}
```
