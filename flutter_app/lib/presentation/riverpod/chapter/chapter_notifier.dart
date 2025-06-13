import 'package:flutter/material.dart';
import '../../../core/base/base_state_notifier.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/datasource/network/service/shinigami_services.dart';
import '../../../data/datasource/local/service/local_services.dart';
import '../../../data/models/shinigami/shinigami_models.dart';
import 'chapter_state.dart';

class ChapterNotifier extends BaseStateNotifier<ChapterState> {
  final ShinigamiChapterService _chapterService = ShinigamiChapterService();
  final CommentoCommentService _commentService = CommentoCommentService();

  // Local database services for history tracking and chapter read marking
  final HistoryService _historyService = HistoryService();
  final ComicChapterService _comicChapterService = ComicChapterService();

  // Store initial state for easy reset
  static final ChapterState _initialState = ChapterState();

  ChapterNotifier(super.initialState, super.ref);

  /// Reset state to initial state (useful for clearing navigation data)
  void _resetToInitialState() {
    state = _initialState.copyWith(
      detailStatus: ChapterStateStatus.loading,
      pagesStatus: ChapterStateStatus.loading,
      // Reset comment state to initial values
      commentStatus: ChapterStateStatus.initial,
      comments: const [],
      commentPagination: null,
      isLoadingMoreComments: false,
      hasMoreComments: true,
      totalCommentCount: 0,
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

      // Track chapter access in background (don't wait for completion)
      _trackChapterAccess(chapter, pages.length);
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
        final newPageIndex = state.currentPageIndex + 1;
        state = state.copyWith(
          currentPageIndex: newPageIndex,
        );

        // Track reading progress in background
        _updateReadingProgress(newPageIndex);
      }
    });
  }

  /// Navigate to previous page
  void previousPage() {
    run('previousPage', () {
      if (state.canGoToPrevPage) {
        final newPageIndex = state.currentPageIndex - 1;
        state = state.copyWith(
          currentPageIndex: newPageIndex,
        );

        // Track reading progress in background
        _updateReadingProgress(newPageIndex);
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

        // Track reading progress in background
        _updateReadingProgress(pageIndex);
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

  /// Fetch comments for the current chapter
  Future<void> fetchComments({int page = 1, int pageSize = 10}) async {
    runAsync('fetchComments', () async {
      final _chapterId = state.chapterId;
      if (_chapterId.isEmpty) {
        return;
      }

      try {
        // Set loading state for comments
        if (page == 1) {
          state = state.copyWith(commentStatus: ChapterStateStatus.loading);
        } else {
          state = state.copyWith(isLoadingMoreComments: true);
        }

        // Get comments from Commento API using chapter path
        final commentResponse = await _commentService.getChapterComments(
          chapterId: _chapterId,
          page: page,
          pageSize: pageSize,
        );

        if (commentResponse.isSuccess) {
          // If this is the first page, replace comments
          if (page == 1) {
            state = state.copyWith(
              commentStatus: ChapterStateStatus.success,
              comments: commentResponse.comments,
              commentPagination: commentResponse.data,
              isLoadingMoreComments: false,
              hasMoreComments: commentResponse.data.hasMore,
              totalCommentCount: commentResponse.data.count,
              errorMessage: null,
            );
          } else {
            // For pagination, append new comments to existing ones
            final combinedComments = [
              ...state.comments,
              ...commentResponse.comments,
            ];

            state = state.copyWith(
              comments: combinedComments,
              commentPagination: commentResponse.data,
              isLoadingMoreComments: false,
              hasMoreComments: commentResponse.data.hasMore,
              totalCommentCount: commentResponse.data.count,
            );
          }
        } else {
          // Handle API error
          if (page == 1) {
            state = state.copyWith(
              commentStatus: ChapterStateStatus.error,
              errorMessage:
                  'Failed to load comments: ${commentResponse.errmsg}',
            );
          } else {
            state = state.copyWith(isLoadingMoreComments: false);
          }
        }
      } catch (e, stackTrace) {
        logger.e('Error fetching chapter comments',
            error: e, stackTrace: stackTrace);

        if (page == 1) {
          state = state.copyWith(
            commentStatus: ChapterStateStatus.error,
            errorMessage: 'Failed to load comments: ${e.toString()}',
          );
        } else {
          state = state.copyWith(isLoadingMoreComments: false);
        }
      }
    });
  }

  /// Load more comments for pagination
  Future<void> loadMoreComments() async {
    // Don't load if already loading or no more comments
    if (state.isLoadingMoreComments || !state.hasMoreComments) {
      return;
    }

    final currentPage = state.commentPagination?.page ?? 0;
    final nextPage = currentPage + 1;

    try {
      await fetchComments(page: nextPage);
    } catch (e, stackTrace) {
      logger.e('Error loading more chapter comments',
          error: e, stackTrace: stackTrace);
      // Reset loading state on error
      state = state.copyWith(isLoadingMoreComments: false);
    }
  }

  /// Get comment statistics for the current chapter
  Future<void> fetchCommentStats() async {
    runAsync('fetchCommentStats', () async {
      final _chapterId = state.chapterId;
      if (_chapterId.isEmpty) {
        return;
      }

      try {
        final stats = await _commentService.getCommentStats(_chapterId);

        state = state.copyWith(
          totalCommentCount: stats['total_comments'] as int? ?? 0,
        );
      } catch (e, stackTrace) {
        logger.e('Error fetching chapter comment stats',
            error: e, stackTrace: stackTrace);
      }
    });
  }

  /// Check if the current chapter has comments
  Future<bool> hasComments() async {
    final _chapterId = state.chapterId;
    if (_chapterId.isEmpty) {
      return false;
    }

    try {
      return await _commentService.hasComments(_chapterId);
    } catch (e, stackTrace) {
      logger.e('Error checking if chapter has comments',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Refresh only comments
  Future<void> refreshComments() async {
    await fetchComments(page: 1);
  }

  // ==================== HISTORY TRACKING METHODS ====================

  /// Track chapter access when user opens a chapter
  /// This creates initial history entry and marks chapter as read
  Future<void> _trackChapterAccess(
      ShinigamiChapter chapter, int totalPages) async {
    try {
      final mangaId = chapter.mangaId;
      final chapterId = chapter.chapterId;
      final chapterNumber = chapter.chapterNumber;

      logger.d(
          'Tracking chapter access: $mangaId - Chapter $chapterNumber (ID: $chapterId)');

      // Get manga details for history (we need cover and title)
      // For now, we'll use basic info and enhance later if needed
      final mangaTitle = 'Unknown'; // TODO: Get from manga service if needed
      final mangaCover = ''; // TODO: Get from manga service if needed
      final nation = 'Unknown'; // TODO: Get from manga service if needed

      // Update reading history (initial access)
      await _historyService.updateHistory(
        comicId: mangaId,
        chapterId: chapterId,
        chapter: 'Chapter $chapterNumber',
        urlCover: mangaCover,
        title: mangaTitle,
        nation: nation,
        pagePosition: 0,
        totalPages: totalPages,
        isCompleted: false,
      );

      // Mark chapter as read (started reading) - use chapter ID
      await _comicChapterService.markChapterReadById(
        comicId: mangaId,
        chapterId: chapterId,
        isCompleted: false,
      );

      logger.i('Chapter access tracked: $mangaId - Chapter $chapterNumber');
    } catch (e, stackTrace) {
      logger.e(
        'Error tracking chapter access',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - this is background operation
    }
  }

  /// Update reading progress in real-time as user navigates pages
  Future<void> _updateReadingProgress(int pagePosition) async {
    try {
      final chapter = state.selectedChapter;
      if (chapter == null) return;

      final totalPages = state.totalPages;
      final isCompleted = pagePosition >= totalPages - 1;

      // Update history with current progress
      await _historyService.updateProgress(
        comicId: chapter.mangaId,
        pagePosition: pagePosition,
        totalPages: totalPages,
        isCompleted: isCompleted,
      );

      // If chapter is completed, mark it as completed
      if (isCompleted) {
        await _comicChapterService.markChapterCompleted(
          chapter.mangaId,
          chapter.chapterTitle ?? 'Unknown Chapter',
        );

        logger.i(
            'Chapter completed: ${chapter.mangaId} - ${chapter.chapterTitle}');
      }

      logger.d(
          'Reading progress updated: ${chapter.mangaId} - Page ${pagePosition + 1}/$totalPages');
    } catch (e, stackTrace) {
      logger.e(
        'Error updating reading progress',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - this is background operation
    }
  }

  /// Mark current chapter as completed manually
  Future<void> markChapterAsCompleted() async {
    runAsync('markChapterAsCompleted', () async {
      final chapter = state.selectedChapter;
      if (chapter == null) return;

      try {
        // Mark as completed in history
        await _historyService.markChapterCompleted(chapter.mangaId);

        // Mark as completed in chapter tracking
        await _comicChapterService.markChapterCompleted(
          chapter.mangaId,
          chapter.chapterTitle ?? 'Unknown Chapter',
        );

        // Update local state to reflect completion
        state = state.copyWith(
          currentPageIndex: state.totalPages - 1,
        );

        logger.i(
            'Chapter manually marked as completed: ${chapter.mangaId} - ${chapter.chapterTitle}');
      } catch (e, stackTrace) {
        logger.e(
          'Error marking chapter as completed',
          error: e,
          stackTrace: stackTrace,
        );
      }
    });
  }

  /// Get reading progress for current chapter
  Future<double> getReadingProgress() async {
    try {
      final chapter = state.selectedChapter;
      if (chapter == null) return 0.0;

      final history = await _historyService.getComicHistory(chapter.mangaId);
      return history?.progressPercentage ?? 0.0;
    } catch (e, stackTrace) {
      logger.e(
        'Error getting reading progress',
        error: e,
        stackTrace: stackTrace,
      );
      return 0.0;
    }
  }

  /// Check if current chapter is marked as read
  Future<bool> isChapterRead() async {
    try {
      final chapter = state.selectedChapter;
      if (chapter == null) return false;

      return await _comicChapterService.isChapterRead(
        chapter.mangaId,
        chapter.chapterTitle ?? 'Unknown Chapter',
      );
    } catch (e, stackTrace) {
      logger.e(
        'Error checking if chapter is read',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
