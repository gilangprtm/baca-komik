import '../../../../core/base/base_network.dart';
import '../repository/bookmark_repository.dart';
import '../../../models/bookmark_model.dart';

class BookmarkService extends BaseService {
  final BookmarkRepository _bookmarkRepository = BookmarkRepository();
  
  /// Add bookmark
  Future<Map<String, dynamic>> addBookmark(String comicId) async {
    return await performanceAsync(
      operationName: 'addBookmark',
      function: () => _bookmarkRepository.addBookmark(comicId),
    );
  }
  
  /// Remove bookmark
  Future<bool> removeBookmark(String comicId) async {
    return await performanceAsync(
      operationName: 'removeBookmark',
      function: () => _bookmarkRepository.removeBookmark(comicId),
    );
  }
  
  /// Get user bookmarks
  Future<Map<String, dynamic>> getUserBookmarks({
    int page = 1,
    int limit = 20,
  }) async {
    return await performanceAsync(
      operationName: 'getUserBookmarks',
      function: () => _bookmarkRepository.getUserBookmarks(
        page: page,
        limit: limit,
      ),
    );
  }
  
  /// Check if comic is bookmarked
  Future<bool> isComicBookmarked(String comicId) async {
    return await performanceAsync(
      operationName: 'isComicBookmarked',
      function: () async {
        try {
          final bookmarks = await _bookmarkRepository.getUserBookmarks();
          final bookmarkList = bookmarks['data'] as List<Bookmark>;
          
          return bookmarkList.any((bookmark) => bookmark.idKomik == comicId);
        } catch (e) {
          logger.e('Error checking if comic is bookmarked', 
            error: e, 
            tag: 'BookmarkService');
          return false;
        }
      },
    );
  }
  
  /// Toggle bookmark status
  Future<bool> toggleBookmark(String comicId) async {
    return await performanceAsync(
      operationName: 'toggleBookmark',
      function: () async {
        final isBookmarked = await isComicBookmarked(comicId);
        
        if (isBookmarked) {
          await removeBookmark(comicId);
          return false; // Now it's not bookmarked
        } else {
          await addBookmark(comicId);
          return true; // Now it's bookmarked
        }
      },
    );
  }
}
