import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/local/service/local_services.dart';
import 'bookmark_state.dart';

class BookmarkNotifier extends BaseStateNotifier<BookmarkState> {
  final BookmarkService _bookmarkService = BookmarkService();

  BookmarkNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Auto-load bookmarks when notifier is initialized
    loadBookmarks();
  }

  /// Load bookmarks from local database
  Future<void> loadBookmarks({int page = 1, int pageSize = 20}) async {
    runAsync('loadBookmarks', () async {
      try {
        // Set loading state
        if (page == 1) {
          state = state.copyWith(
            status: BookmarkStatus.loading,
            errorMessage: null,
          );
        } else {
          state = state.copyWith(isLoadingMore: true);
        }

        // Get bookmarks from local database
        final bookmarks = await _bookmarkService.getBookmarksPage(
          page: page,
          pageSize: pageSize,
        );

        // Get total count for pagination
        final totalCount = await _bookmarkService.getBookmarksCount();

        // Calculate if there are more pages
        final hasMore = (page * pageSize) < totalCount;

        if (page == 1) {
          // First page - replace existing bookmarks
          state = state.copyWith(
            status: BookmarkStatus.success,
            bookmarks: bookmarks,
            currentPage: page,
            totalCount: totalCount,
            hasMore: hasMore,
            isLoadingMore: false,
            errorMessage: null,
          );
        } else {
          // Subsequent pages - append to existing bookmarks
          final combinedBookmarks = [...state.bookmarks, ...bookmarks];
          state = state.copyWith(
            bookmarks: combinedBookmarks,
            currentPage: page,
            totalCount: totalCount,
            hasMore: hasMore,
            isLoadingMore: false,
          );
        }

        logger.i('Loaded ${bookmarks.length} bookmarks (page $page)');
      } catch (e, stackTrace) {
        logger.e('Error loading bookmarks', error: e, stackTrace: stackTrace);

        if (page == 1) {
          state = state.copyWith(
            status: BookmarkStatus.error,
            errorMessage: 'Failed to load bookmarks: ${e.toString()}',
            isLoadingMore: false,
          );
        } else {
          state = state.copyWith(
            isLoadingMore: false,
            errorMessage: 'Failed to load more bookmarks: ${e.toString()}',
          );
        }
      }
    });
  }

  /// Refresh bookmarks (reload from first page)
  Future<void> refreshBookmarks() async {
    await loadBookmarks(page: 1);
  }

  /// Load more bookmarks for pagination
  Future<void> loadMoreBookmarks() async {
    if (!state.canLoadMore) return;

    final nextPage = state.currentPage + 1;
    await loadBookmarks(page: nextPage);
  }

  /// Check if comic is bookmarked
  Future<bool> isBookmarked(String comicId) async {
    try {
      return await _bookmarkService.isBookmarked(comicId);
    } catch (e, stackTrace) {
      logger.e('Error checking bookmark status',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Get bookmarks count
  int get bookmarksCount => state.totalCount;

  /// Check if bookmark list is empty
  bool get isEmpty => state.isEmpty;

  /// Check if bookmark list is not empty
  bool get isNotEmpty => state.isNotEmpty;
}
