import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/local/bookmark_model.dart';
import 'bookmark_notifier.dart';
import 'bookmark_state.dart';

/// Main bookmark provider
final bookmarkProvider =
    StateNotifierProvider.autoDispose<BookmarkNotifier, BookmarkState>((ref) {
  return BookmarkNotifier(const BookmarkState(), ref);
});

/// Bookmark list provider
final bookmarkListProvider = Provider.autoDispose<List<BookmarkModel>>((ref) {
  return ref.watch(bookmarkProvider.select((state) => state.bookmarks));
});

/// Bookmark status provider
final bookmarkStatusProvider = Provider.autoDispose<BookmarkStatus>((ref) {
  return ref.watch(bookmarkProvider.select((state) => state.status));
});

/// Bookmark loading state provider
final bookmarkLoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(bookmarkProvider.select((state) => state.isLoading));
});

/// Bookmark loading more state provider
final bookmarkLoadingMoreProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(bookmarkProvider.select((state) => state.isLoadingMore));
});

/// Bookmark error message provider
final bookmarkErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(bookmarkProvider.select((state) => state.errorMessage));
});

/// Bookmark count provider
final bookmarkCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(bookmarkProvider.select((state) => state.totalCount));
});

/// Bookmark empty state provider
final bookmarkEmptyProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(bookmarkProvider.select((state) => state.isEmpty));
});

/// Bookmark has more provider
final bookmarkHasMoreProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(bookmarkProvider.select((state) => state.hasMore));
});

/// Provider to check if specific comic is bookmarked
final comicBookmarkStatusProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, comicId) async {
  final notifier = ref.read(bookmarkProvider.notifier);
  return await notifier.isBookmarked(comicId);
});

/// Bookmark pagination info provider
final bookmarkPaginationProvider =
    Provider.autoDispose<Map<String, dynamic>>((ref) {
  final state = ref.watch(bookmarkProvider);
  return {
    'current_page': state.currentPage,
    'total_count': state.totalCount,
    'has_more': state.hasMore,
    'can_load_more': state.canLoadMore,
  };
});
