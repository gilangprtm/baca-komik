import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/shinigami/shinigami_models.dart';
import 'comic_state.dart';
import 'comic_notifier.dart';

final comicProvider =
    StateNotifierProvider.autoDispose<ComicNotifier, ComicState>(
  (ref) => ComicNotifier(const ComicState(), ref),
);

// Optimized providers using select for better performance

/// Comic detail providers
final comicDetailProvider = Provider.autoDispose<ShinigamiManga?>((ref) {
  return ref.watch(comicProvider.select((state) => state.selectedComic));
});

final comicDetailStatusProvider = Provider.autoDispose<ComicStateStatus>((ref) {
  return ref.watch(comicProvider.select((state) => state.detailStatus));
});

/// Chapter providers
final comicChaptersProvider =
    Provider.autoDispose<List<ShinigamiChapter>>((ref) {
  return ref.watch(comicProvider.select((state) => state.chapters));
});

final comicChapterStatusProvider =
    Provider.autoDispose<ComicStateStatus>((ref) {
  return ref.watch(comicProvider.select((state) => state.chapterStatus));
});

final comicChapterMetaProvider = Provider.autoDispose<ShinigamiMeta?>((ref) {
  return ref.watch(comicProvider.select((state) => state.chapterMeta));
});

/// Loading state providers
final comicLoadingProvider = Provider.autoDispose<Map<String, bool>>((ref) {
  return ref.watch(comicProvider.select((state) => {
        'is_loading_detail': state.isLoadingDetail,
        'is_loading_chapters': state.isLoadingChapters,
        'is_loading_more_chapters': state.isLoadingMoreChapters,
        'is_loading_bookmark': state.isLoadingBookmark,
        'is_loading_comments': state.isLoadingComments,
        'is_loading_more_comments': state.isLoadingMoreComments,
      }));
});

/// Error provider
final comicErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(comicProvider.select((state) => state.errorMessage));
});

/// Bookmark providers
final comicBookmarkProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(comicProvider.select((state) => state.isBookmarked));
});

final comicBookmarkStatusProvider =
    Provider.autoDispose<ComicStateStatus>((ref) {
  return ref.watch(comicProvider.select((state) => state.bookmarkStatus));
});

/// Reading progress providers
final comicReadingProgressProvider =
    Provider.autoDispose<Map<String, double>>((ref) {
  return ref.watch(comicProvider.select((state) => state.readingProgress));
});

final comicLastReadChapterProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(comicProvider.select((state) => state.lastReadChapterId));
});

/// Comic info providers (derived from selectedComic)
final comicInfoProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(comicProvider.select((state) => {
        'title': state.comicTitle,
        'description': state.comicDescription,
        'rating': state.comicRating,
        'view_count': state.comicViewCount,
        'bookmark_count': state.comicBookmarkCount,
        'has_comic': state.hasSelectedComic,
      }));
});

final comicGenresProvider = Provider.autoDispose<List<ShinigamiGenre>>((ref) {
  return ref.watch(comicProvider.select((state) => state.comicGenres));
});

/// Chapter navigation providers
final comicChapterNavigationProvider =
    Provider.autoDispose<Map<String, ShinigamiChapter?>>((ref) {
  return ref.watch(comicProvider.select((state) => {
        'first_chapter': state.firstChapter,
        'last_chapter': state.lastChapter,
        'last_read_chapter': state.lastReadChapter,
      }));
});

/// Reading statistics provider
final comicReadingStatsProvider =
    Provider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(comicProvider.select((state) => state.readingStats));
});

/// Pagination info provider
final comicPaginationProvider =
    Provider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(comicProvider.select((state) => {
        'current_page': state.currentChapterPage,
        'total_pages': state.totalChapterPages,
        'total_chapters': state.totalChapters,
        'has_chapters': state.hasChapters,
        'can_load_more': state.canLoadMoreChapters,
        'has_more': state.hasMoreChapters,
      }));
});

/// Comment providers
final comicCommentsProvider =
    Provider.autoDispose<List<CommentoComment>>((ref) {
  return ref.watch(comicProvider.select((state) => state.comments));
});

final comicCommentStatusProvider =
    Provider.autoDispose<ComicStateStatus>((ref) {
  return ref.watch(comicProvider.select((state) => state.commentStatus));
});

final comicCommentStatsProvider =
    Provider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(comicProvider.select((state) => state.commentStats));
});

/// Combined status provider for UI
final comicStatusProvider = Provider.autoDispose<Map<String, bool>>((ref) {
  return ref.watch(comicProvider.select((state) => {
        'has_error': state.hasError,
        'is_loading': state.isLoadingDetail ||
            state.isLoadingChapters ||
            state.isLoadingComments,
        'has_data': state.hasSelectedComic && state.hasChapters,
        'is_ready': state.detailStatus == ComicStateStatus.success,
      }));
});
