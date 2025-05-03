import '../../../../core/base/base_network.dart';
import '../../../models/bookmark_model.dart';

class BookmarkRepository extends BaseRepository {
  /// Add bookmark
  Future<Map<String, dynamic>> addBookmark(String comicId) async {
    try {
      final response = await dioService.post(
        '/bookmarks',
        data: {
          'id_komik': comicId,
        },
      );

      return {
        'success': response.data['success'] ?? false,
        'id': response.data['id'],
      };
    } catch (e, stackTrace) {
      logError(
        'Error adding bookmark',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Remove bookmark
  Future<bool> removeBookmark(String comicId) async {
    try {
      final response = await dioService.delete('/bookmarks/$comicId');
      return response.data['success'] ?? false;
    } catch (e, stackTrace) {
      logError(
        'Error removing bookmark',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get user bookmarks
  Future<Map<String, dynamic>> getUserBookmarks({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await dioService.get(
        '/bookmarks',
        queryParameters: queryParams,
      );

      final List<Bookmark> bookmarks = (response.data['data'] as List)
          .map((bookmark) => Bookmark.fromJson(bookmark))
          .toList();

      return {
        'data': bookmarks,
        'meta': response.data['meta'],
      };
    } catch (e, stackTrace) {
      logError(
        'Error fetching user bookmarks',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
