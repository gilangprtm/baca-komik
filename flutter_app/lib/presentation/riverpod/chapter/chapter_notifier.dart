import 'package:flutter/material.dart';
import '../../../core/base/base_state_notifier.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/datasource/network/service/shinigami_chapter_service.dart';
import '../../../data/models/shinigami/shinigami_models.dart';
import 'chapter_state.dart';

class ChapterNotifier extends BaseStateNotifier<ChapterState> {
  final ShinigamiChapterService _chapterService = ShinigamiChapterService();

  // Store initial state for easy reset
  static final ChapterState _initialState = ChapterState();

  ChapterNotifier(super.initialState, super.ref);

  /// Reset state to initial state (useful for clearing navigation data)
  void _resetToInitialState() {
    state = _initialState.copyWith(
      detailStatus: ChapterStateStatus.loading,
      pagesStatus: ChapterStateStatus.loading,
    );
  }

  @override
  void onInit() {
    super.onInit();

    // Get chapterId from route arguments
    final chapterId = Mahas.argument<String>('chapterId');

    // Fetch chapter details if chapterId is available
    if (chapterId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchChapterDetails(chapterId);
      });
    }
  }

  /// Fetch chapter details by ID (optimized - single API call)
  Future<void> fetchChapterDetails(String chapterId) async {
    runAsync('fetchChapterDetails', () async {
      // Reset to initial state to clear all previous data
      _resetToInitialState();

      // Use optimized method that fetches everything in one API call
      final chapterData =
          await _chapterService.getCompleteChapterData(chapterId);

      final chapter = chapterData['chapter'] as ShinigamiChapter;
      final pages = chapterData['pages'] as List<ShinigamiPage>;
      final navigation =
          chapterData['navigation'] as ShinigamiChapterNavigation;

      // Update state with new chapter data
      state = state.copyWith(
        detailStatus: ChapterStateStatus.success,
        pagesStatus: ChapterStateStatus.success,
        navigationStatus: ChapterStateStatus.success,
        selectedChapter: chapter,
        pages: pages,
        navigation: navigation,
        currentPageIndex: 0,
        nextChapterId: navigation.nextChapterId,
        prevChapterId: navigation.prevChapterId,
        nextChapterNumber: navigation.nextChapterNumber,
        prevChapterNumber: navigation.prevChapterNumber,
        isFirstChapter: navigation.prevChapterId == null,
        isLastChapter: navigation.nextChapterId == null,
      );
    });
  }

  /// Toggle reader controls visibility
  void toggleReaderControls() {
    run('toggleReaderControls', () {
      state = state.copyWith(
        showControls: !state.showControls,
      );
    });
  }

  /// Toggle fullscreen mode
  void toggleFullscreen() {
    run('toggleFullscreen', () {
      state = state.copyWith(
        isFullscreen: !state.isFullscreen,
      );
    });
  }

  /// Navigate to next page
  void nextPage() {
    run('nextPage', () {
      if (state.canGoToNextPage) {
        state = state.copyWith(
          currentPageIndex: state.currentPageIndex + 1,
        );
      }
    });
  }

  /// Navigate to previous page
  void previousPage() {
    run('previousPage', () {
      if (state.canGoToPrevPage) {
        state = state.copyWith(
          currentPageIndex: state.currentPageIndex - 1,
        );
      }
    });
  }

  /// Navigate to specific page
  void goToPage(int pageIndex) {
    run('goToPage', () {
      if (pageIndex >= 0 && pageIndex < state.totalPages) {
        state = state.copyWith(
          currentPageIndex: pageIndex,
        );
      }
    });
  }

  /// Navigate to next chapter
  Future<void> nextChapter() async {
    runAsync('nextChapter', () async {
      if (state.nextChapterId != null) {
        await fetchChapterDetails(state.nextChapterId!);
      }
    });
  }

  /// Navigate to previous chapter
  Future<void> previousChapter() async {
    runAsync('previousChapter', () async {
      if (state.prevChapterId != null) {
        await fetchChapterDetails(state.prevChapterId!);
      }
    });
  }

  /// Update zoom level
  void updateZoomLevel(double zoomLevel) {
    run('updateZoomLevel', () {
      state = state.copyWith(
        zoomLevel: zoomLevel.clamp(0.5, 3.0), // Limit zoom between 0.5x and 3x
      );
    });
  }

  /// Toggle reading direction
  void toggleReadingDirection() {
    run('toggleReadingDirection', () {
      state = state.copyWith(
        isHorizontalReading: !state.isHorizontalReading,
      );
    });
  }

  /// Track reading progress
  Future<void> trackReadingProgress() async {
    runAsync('trackReadingProgress', () async {
      if (state.hasChapter && !state.isTrackingProgress) {
        state = state.copyWith(
          isTrackingProgress: true,
          lastReadAt: DateTime.now(),
        );

        // TODO: Implement actual progress tracking to backend
        // await _progressService.updateReadingProgress(
        //   chapterId: state.chapterId,
        //   pageIndex: state.currentPageIndex,
        //   progress: state.readingProgress,
        // );

        state = state.copyWith(isTrackingProgress: false);
      }
    });
  }

  /// Navigate to specific chapter by ID
  Future<void> goToChapter(String chapterId) async {
    runAsync('goToChapter', () async {
      await fetchChapterDetails(chapterId);
    });
  }
}
