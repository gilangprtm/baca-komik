import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/network/service/optimized_chapter_service.dart';
import 'chapter_state.dart';

class ChapterNotifier extends BaseStateNotifier<ChapterState> {
  final OptimizedChapterService _chapterService = OptimizedChapterService();
  
  ChapterNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty state
  }

  /// Fetch complete chapter details by ID
  Future<void> fetchChapterDetails(String chapterId) async {
    try {
      state = state.copyWith(status: ChapterStateStatus.loading);
      
      // Fetch complete chapter details from service
      final chapter = await _chapterService.getCompleteChapterDetails(chapterId);
      
      // Reset page index when loading a new chapter
      state = state.copyWith(
        status: ChapterStateStatus.success,
        currentChapter: chapter,
        currentPageIndex: 0,
      );
      
      // Track reading progress
      _trackReadingProgress(chapterId, chapter.chapter.idKomik);
    } catch (e, stackTrace) {
      logger.e('Error fetching chapter details', error: e, stackTrace: stackTrace);
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
      if (state.nextChapterId != null) {
        fetchChapterDetails(state.nextChapterId!);
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
      if (state.prevChapterId != null) {
        fetchChapterDetails(state.prevChapterId!);
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
  Future<void> _trackReadingProgress(String chapterId, String comicId) async {
    try {
      await _chapterService.trackReadingProgress(chapterId, comicId);
    } catch (e, stackTrace) {
      logger.e('Error tracking reading progress', error: e, stackTrace: stackTrace);
      // Don't update state for tracking errors, just log them
    }
  }

  /// Mark chapter as complete when user finishes reading
  Future<void> markChapterAsRead() async {
    if (state.currentChapter == null) return;
    
    try {
      final chapterId = state.currentChapter!.chapter.id;
      await _chapterService.markChapterAsRead(chapterId);
    } catch (e, stackTrace) {
      logger.e('Error marking chapter as read', error: e, stackTrace: stackTrace);
      // Don't update state for tracking errors, just log them
    }
  }
}
