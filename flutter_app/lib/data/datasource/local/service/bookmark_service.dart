import '../../../../core/base/base_network.dart';
import '../../../models/local/bookmark_model.dart';
import '../repository/bookmark_repository.dart';

/// Bookmark Service - High-level bookmark operations with performance monitoring
/// Follows the same pattern as network services
class BookmarkService extends BaseService {
  final BookmarkRepository _repository = BookmarkRepository();

  /// Toggle bookmark (add if not exists, remove if exists)
  /// Returns true if bookmark was added, false if removed
  Future<bool> toggleBookmark({
    required String comicId,
    required String urlCover,
    required String title,
    required String nation,
  }) async {
    return await performanceAsync(
      operationName: 'toggleBookmark',
      function: () async {
        final bookmark = BookmarkModel.create(
          comicId: comicId,
          urlCover: urlCover,
          title: title,
          nation: nation,
        );

        return await _repository.toggleBookmark(bookmark);
      },
    );
  }

  /// Check if comic is bookmarked
  Future<bool> isBookmarked(String comicId) async {
    return await performanceAsync(
      operationName: 'isBookmarked',
      function: () => _repository.isBookmarked(comicId),
    );
  }

  /// Get all bookmarks with pagination
  Future<List<BookmarkModel>> getAllBookmarks({
    int? limit,
    int? offset,
  }) async {
    return await performanceAsync(
      operationName: 'getAllBookmarks',
      function: () => _repository.getAllBookmarks(
        limit: limit,
        offset: offset,
      ),
    );
  }

  /// Get bookmark by comic ID
  Future<BookmarkModel?> getBookmark(String comicId) async {
    return await performanceAsync(
      operationName: 'getBookmark',
      function: () => _repository.getBookmark(comicId),
    );
  }

  /// Remove bookmark by comic ID
  Future<bool> removeBookmark(String comicId) async {
    return await performanceAsync(
      operationName: 'removeBookmark',
      function: () => _repository.removeBookmark(comicId),
    );
  }

  /// Get bookmarks count
  Future<int> getBookmarksCount() async {
    return await performanceAsync(
      operationName: 'getBookmarksCount',
      function: () => _repository.getBookmarksCount(),
    );
  }

  /// Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    return await performanceAsync(
      operationName: 'clearAllBookmarks',
      function: () => _repository.clearAllBookmarks(),
    );
  }

  /// Add bookmark directly
  Future<void> addBookmark({
    required String comicId,
    required String urlCover,
    required String title,
    required String nation,
  }) async {
    return await performanceAsync(
      operationName: 'addBookmark',
      function: () async {
        final bookmark = BookmarkModel.create(
          comicId: comicId,
          urlCover: urlCover,
          title: title,
          nation: nation,
        );

        await _repository.addBookmark(bookmark);
      },
    );
  }

  /// Get paginated bookmarks for UI
  Future<List<BookmarkModel>> getBookmarksPage({
    required int page,
    int pageSize = 20,
  }) async {
    return await performanceAsync(
      operationName: 'getBookmarksPage',
      function: () => _repository.getAllBookmarks(
        limit: pageSize,
        offset: (page - 1) * pageSize,
      ),
    );
  }

  /// Search bookmarks by title
  Future<List<BookmarkModel>> searchBookmarks(String query) async {
    return await performanceAsync(
      operationName: 'searchBookmarks',
      function: () async {
        final allBookmarks = await _repository.getAllBookmarks();
        
        if (query.isEmpty) return allBookmarks;
        
        final lowercaseQuery = query.toLowerCase();
        return allBookmarks.where((bookmark) =>
          bookmark.title.toLowerCase().contains(lowercaseQuery)
        ).toList();
      },
    );
  }

  /// Get bookmarks by nation/region
  Future<List<BookmarkModel>> getBookmarksByNation(String nation) async {
    return await performanceAsync(
      operationName: 'getBookmarksByNation',
      function: () async {
        final allBookmarks = await _repository.getAllBookmarks();
        
        return allBookmarks.where((bookmark) =>
          bookmark.nation.toLowerCase() == nation.toLowerCase()
        ).toList();
      },
    );
  }

  /// Get recent bookmarks (last 10)
  Future<List<BookmarkModel>> getRecentBookmarks({int limit = 10}) async {
    return await performanceAsync(
      operationName: 'getRecentBookmarks',
      function: () => _repository.getAllBookmarks(limit: limit),
    );
  }
}
