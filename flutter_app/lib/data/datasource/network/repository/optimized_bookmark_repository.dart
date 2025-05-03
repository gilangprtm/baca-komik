import '../../../../core/base/base_network.dart';
import '../../../models/bookmark_detail_model.dart';
import '../../../models/metadata_models.dart';

class OptimizedBookmarkRepository extends BaseRepository {
  /// Get bookmark details with comic info and latest chapter
  /// Uses the optimized /bookmarks/details endpoint
  Future<Map<String, dynamic>> getBookmarkDetails({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response = await dioService.get('/bookmarks/details', queryParameters: queryParams);

      final List<BookmarkDetail> bookmarks = (response.data['data'] as List)
          .map((bookmark) => BookmarkDetail.fromJson(bookmark))
          .toList();

      return {
        'data': bookmarks,
        'meta': MetaData.fromJson(response.data['meta']),
      };
    } catch (e, stackTrace) {
      logError(
        'Error fetching bookmark details',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Add bookmark (reusing existing method from BookmarkRepository)
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

  /// Remove bookmark (reusing existing method from BookmarkRepository)
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
}
