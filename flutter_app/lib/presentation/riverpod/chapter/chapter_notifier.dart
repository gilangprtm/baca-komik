import 'package:flutter/material.dart';
import '../../../core/base/base_state_notifier.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/datasource/network/service/chapter_service.dart';
import 'chapter_state.dart';

class ChapterNotifier extends BaseStateNotifier<ChapterState> {
  final ChapterService _chapterService = ChapterService();

  ChapterNotifier(super.initialState, super.ref);

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

  /// Fetch chapter details by ID
  Future<void> fetchChapterDetails(String chapterId) async {
    try {
      state = state.copyWith(status: ChapterStateStatus.loading);

      // Fetch chapter details and pages
      final chapter = await _chapterService.getChapterDetails(chapterId);
      final chapterPages = await _chapterService.getChapterPages(chapterId);

      // Get adjacent chapters for navigation
      final adjacent = await _chapterService.getAdjacentChapters(
          chapter.idKomik, chapter.chapterNumber.toDouble());

      // Update state with chapter data
      state = state.copyWith(
        status: ChapterStateStatus.success,
        chapter: chapter,
        pages: chapterPages.pages,
        nextChapter: adjacent.next,
        previousChapter: adjacent.previous,
        currentPageIndex: 0,
      );

      // Track reading progress
      _trackReadingProgress(chapterId);
    } catch (e, stackTrace) {
      logger.e('Error fetching chapter details',
          error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: ChapterStateStatus.error,
        errorMessage: 'Failed to load chapter: ${e.toString()}',
      );
    }
  }

  /// Navigate to the next page
  void nextPage() {
    if (state.isLastPage) {
      // If on last page and there's a next chapter, load it
      if (state.nextChapter != null) {
        fetchChapterDetails(state.nextChapter!.id);
      }
      return;
    }

    state = state.copyWith(
      currentPageIndex: state.currentPageIndex + 1,
    );
  }

  /// Navigate to the previous page
  void previousPage() {
    if (state.isFirstPage) {
      // If on first page and there's a previous chapter, load it
      if (state.previousChapter != null) {
        fetchChapterDetails(state.previousChapter!.id);
        // After loading previous chapter, navigate to its last page
        // This will be handled after the chapter is loaded
      }
      return;
    }

    state = state.copyWith(
      currentPageIndex: state.currentPageIndex - 1,
    );
  }

  /// Jump to a specific page
  void jumpToPage(int pageIndex) {
    if (pageIndex < 0 || pageIndex >= state.totalPages) return;

    state = state.copyWith(
      currentPageIndex: pageIndex,
    );
  }

  /// Toggle reader controls visibility
  void toggleReaderControls() {
    state = state.copyWith(
      isReaderControlsVisible: !state.isReaderControlsVisible,
    );
  }

  /// Change zoom level
  void setZoomLevel(double zoomLevel) {
    // Limit zoom between 0.5 and 3.0
    final newZoom = zoomLevel.clamp(0.5, 3.0);

    state = state.copyWith(
      zoomLevel: newZoom,
    );
  }

  /// Toggle reading direction (horizontal/vertical)
  void toggleReadingDirection() {
    state = state.copyWith(
      isHorizontalReading: !state.isHorizontalReading,
    );
  }

  /// Mark chapter as read and track progress
  Future<void> _trackReadingProgress(String chapterId) async {
    try {
      await _chapterService.trackReadingProgress(chapterId);
    } catch (e, stackTrace) {
      logger.e('Error tracking reading progress',
          error: e, stackTrace: stackTrace);
      // Don't update state for tracking errors, just log them
    }
  }

  /// Mark chapter as complete when user finishes reading
  Future<void> markChapterAsRead() async {
    if (state.chapter == null) return;

    try {
      final chapterId = state.chapter!.id;
      // This method will be implemented in ChapterService
      // For now, we just log it
      logger.i('Marking chapter as read: $chapterId');
    } catch (e, stackTrace) {
      logger.e('Error marking chapter as read',
          error: e, stackTrace: stackTrace);
      // Don't update state for tracking errors, just log them
    }
  }
}
