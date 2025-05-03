import '../../../../core/base/base_network.dart';
import '../repository/optimized_bookmark_repository.dart';
import '../repository/optimized_comic_repository.dart';

class OptimizedBookmarkService extends BaseService {
  final OptimizedBookmarkRepository _repository = OptimizedBookmarkRepository();
  final OptimizedComicRepository _comicRepository = OptimizedComicRepository();

  /// Get bookmark details with comic info and latest chapter
  /// Uses the optimized /bookmarks/details endpoint
  Future<Map<String, dynamic>> getBookmarkDetails({
    int page = 1,
    int limit = 20,
  }) async {
    return await performanceAsync(
      operationName: 'getBookmarkDetails',
      function: () => _repository.getBookmarkDetails(
        page: page,
        limit: limit,
      ),
    );
  }

  /// Add bookmark
  Future<Map<String, dynamic>> addBookmark(String comicId) async {
    return await performanceAsync(
      operationName: 'addBookmark',
      function: () => _repository.addBookmark(comicId),
    );
  }

  /// Remove bookmark
  Future<bool> removeBookmark(String comicId) async {
    return await performanceAsync(
      operationName: 'removeBookmark',
      function: () => _repository.removeBookmark(comicId),
    );
  }
  
  /// Check if comic is bookmarked (using complete comic details)
  Future<bool> isComicBookmarked(String comicId) async {
    return await performanceAsync(
      operationName: 'isComicBookmarked',
      function: () async {
        try {
          // Get complete comic details which includes bookmark status
          final completeComic = await _comicRepository.getCompleteComicDetails(comicId);
          return completeComic.userData.isBookmarked;
        } catch (e) {
          logger.e('Error checking if comic is bookmarked', 
            error: e, 
            tag: 'OptimizedBookmarkService');
          return false;
        }
      },
    );
  }
}
