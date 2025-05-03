import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/network/service/optimized_bookmark_service.dart';
import '../../../data/models/bookmark_detail_model.dart';
import '../../../data/models/metadata_models.dart';
import 'bookmark_state.dart';

class BookmarkNotifier extends BaseStateNotifier<BookmarkState> {
  final OptimizedBookmarkService _bookmarkService = OptimizedBookmarkService();
  
  BookmarkNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty state
  }

  @override
  void onReady() {
    super.onReady();
    // Fetch initial data when ready
    fetchBookmarks();
  }

  /// Fetch user bookmarks with details
  Future<void> fetchBookmarks({bool refresh = false}) async {
    try {
      // If refreshing, reset to initial page, otherwise keep current state
      final page = refresh ? 1 : (state.meta?.page ?? 0) + 1;
      
      // Only show loading indicator on first page or refresh
      if (page == 1) {
        state = state.copyWith(status: BookmarkStateStatus.loading);
      }

      // Fetch bookmarks from service
      final result = await _bookmarkService.getBookmarkDetails(
        page: page,
        limit: 20,
      );

      // Extract data and metadata
      final List<BookmarkDetail> bookmarks = result['data'] as List<BookmarkDetail>;
      final MetaData meta = result['meta'] as MetaData;
      
      // If refreshing, replace the list, otherwise append
      final updatedBookmarks = page == 1 
          ? bookmarks 
          : [...state.bookmarks, ...bookmarks];
      
      // Update state with new data
      state = state.copyWith(
        status: BookmarkStateStatus.success,
        bookmarks: updatedBookmarks,
        meta: meta,
        hasMore: meta.hasMore,
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching bookmarks', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: BookmarkStateStatus.error,
        errorMessage: 'Failed to load bookmarks: ${e.toString()}',
      );
    }
  }

  /// Add a comic to bookmarks
  Future<void> addBookmark(String comicId) async {
    try {
      state = state.copyWith(isAddingBookmark: true);
      
      // Add bookmark through service
      await _bookmarkService.addBookmark(comicId);
      
      // Refresh bookmarks list to include the new bookmark
      await fetchBookmarks(refresh: true);
      
      state = state.copyWith(isAddingBookmark: false);
    } catch (e, stackTrace) {
      logger.e('Error adding bookmark', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isAddingBookmark: false,
        errorMessage: 'Failed to add bookmark: ${e.toString()}',
      );
    }
  }

  /// Remove a comic from bookmarks
  Future<void> removeBookmark(String comicId) async {
    try {
      state = state.copyWith(isRemovingBookmark: true);
      
      // Remove bookmark through service
      await _bookmarkService.removeBookmark(comicId);
      
      // Remove the bookmark from the local state
      final updatedBookmarks = state.bookmarks.where(
        (bookmark) => bookmark.comic.id != comicId
      ).toList();
      
      state = state.copyWith(
        isRemovingBookmark: false,
        bookmarks: updatedBookmarks,
      );
    } catch (e, stackTrace) {
      logger.e('Error removing bookmark', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isRemovingBookmark: false,
        errorMessage: 'Failed to remove bookmark: ${e.toString()}',
      );
    }
  }

  /// Check if a comic is bookmarked
  Future<bool> isComicBookmarked(String comicId) async {
    try {
      return await _bookmarkService.isComicBookmarked(comicId);
    } catch (e, stackTrace) {
      logger.e('Error checking bookmark status', error: e, stackTrace: stackTrace);
      return false;
    }
  }
}
