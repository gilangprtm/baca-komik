import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/shinigami/shinigami_models.dart';
import 'chapter_state.dart';
import 'chapter_notifier.dart';

/// Main chapter provider
final chapterProvider =
    StateNotifierProvider.autoDispose<ChapterNotifier, ChapterState>(
  (ref) => ChapterNotifier(const ChapterState(), ref),
);

/// Optimized providers for specific data to minimize rebuilds

// Status providers
final chapterDetailStatusProvider =
    Provider.autoDispose<ChapterStateStatus>((ref) {
  return ref.watch(chapterProvider.select((state) => state.detailStatus));
});

final chapterPagesStatusProvider =
    Provider.autoDispose<ChapterStateStatus>((ref) {
  return ref.watch(chapterProvider.select((state) => state.pagesStatus));
});

final chapterNavigationStatusProvider =
    Provider.autoDispose<ChapterStateStatus>((ref) {
  return ref.watch(chapterProvider.select((state) => state.navigationStatus));
});

final chapterCommentStatusProvider =
    Provider.autoDispose<ChapterStateStatus>((ref) {
  return ref.watch(chapterProvider.select((state) => state.commentStatus));
});

// Data providers
final chapterDetailProvider = Provider.autoDispose<ShinigamiChapter?>((ref) {
  return ref.watch(chapterProvider.select((state) => state.selectedChapter));
});

final chapterPagesProvider = Provider.autoDispose<List<ShinigamiPage>>((ref) {
  return ref.watch(chapterProvider.select((state) => state.pages));
});

final chapterNavigationProvider =
    Provider.autoDispose<ShinigamiChapterNavigation?>((ref) {
  return ref.watch(chapterProvider.select((state) => state.navigation));
});

// Comment providers
final chapterCommentsProvider =
    Provider.autoDispose<List<CommentoComment>>((ref) {
  return ref.watch(chapterProvider.select((state) => state.comments));
});

final chapterCommentStatsProvider =
    Provider.autoDispose<Map<String, dynamic>>((ref) {
  return ref.watch(chapterProvider.select((state) => state.commentStats));
});

final chapterMetaProvider = Provider.autoDispose<ShinigamiMeta?>((ref) {
  return ref.watch(chapterProvider.select((state) => state.chapterMeta));
});

// Current state providers
final currentPageIndexProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(chapterProvider.select((state) => state.currentPageIndex));
});

final currentPageProvider = Provider.autoDispose<ShinigamiPage?>((ref) {
  return ref.watch(chapterProvider.select((state) => state.currentPage));
});

final isFullscreenProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.isFullscreen));
});

final showControlsProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.showControls));
});

final zoomLevelProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(chapterProvider.select((state) => state.zoomLevel));
});

final isHorizontalReadingProvider = Provider.autoDispose<bool>((ref) {
  return ref
      .watch(chapterProvider.select((state) => state.isHorizontalReading));
});

// Navigation state providers
final nextChapterIdProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(chapterProvider.select((state) => state.nextChapterId));
});

final prevChapterIdProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(chapterProvider.select((state) => state.prevChapterId));
});

final nextChapterNumberProvider = Provider.autoDispose<int?>((ref) {
  return ref.watch(chapterProvider.select((state) => state.nextChapterNumber));
});

final prevChapterNumberProvider = Provider.autoDispose<int?>((ref) {
  return ref.watch(chapterProvider.select((state) => state.prevChapterNumber));
});

final isFirstChapterProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.isFirstChapter));
});

final isLastChapterProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.isLastChapter));
});

// Loading state providers
final chapterLoadingStatesProvider =
    Provider.autoDispose<Map<String, bool>>((ref) {
  return ref.watch(chapterProvider.select((state) => state.loadingStates));
});

final chapterErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(chapterProvider.select((state) => state.errorMessage));
});

// Helper providers
final totalPagesProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(chapterProvider.select((state) => state.totalPages));
});

final readingProgressProvider = Provider.autoDispose<double>((ref) {
  return ref.watch(chapterProvider.select((state) => state.readingProgress));
});

final progressTextProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(chapterProvider.select((state) => state.progressText));
});

final chapterTitleProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(chapterProvider.select((state) => state.displayTitle));
});

final fullChapterTitleProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(chapterProvider.select((state) => state.fullTitle));
});

// Navigation capability providers
final canGoToNextPageProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.canGoToNextPage));
});

final canGoToPrevPageProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.canGoToPrevPage));
});

final canGoToNextChapterProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.hasNextChapter));
});

final canGoToPrevChapterProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.hasPreviousChapter));
});

final isFirstPageProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.isFirstPage));
});

final isLastPageProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.isLastPage));
});

// Combined status providers for UI
final chapterLoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) =>
      state.isLoadingDetail ||
      state.isLoadingPages ||
      state.isLoadingNavigation ||
      state.isLoadingComments));
});

final chapterSuccessProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.isSuccess));
});

final chapterHasErrorProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.hasError));
});

final chapterHasDataProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(
      chapterProvider.select((state) => state.hasChapter && state.hasPages));
});

// Reading progress providers
final isTrackingProgressProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(chapterProvider.select((state) => state.isTrackingProgress));
});

final lastReadAtProvider = Provider.autoDispose<DateTime?>((ref) {
  return ref.watch(chapterProvider.select((state) => state.lastReadAt));
});
