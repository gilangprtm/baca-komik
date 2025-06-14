import '../../../core/base/base_state_notifier.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/datasource/network/service/shinigami_services.dart';
import '../../../data/datasource/local/service/local_services.dart';
import 'comic_state.dart';

class ComicNotifier extends BaseStateNotifier<ComicState> {
  final ShinigamiMangaService _mangaService = ShinigamiMangaService();
  final ShinigamiChapterService _chapterService = ShinigamiChapterService();
  final CommentoCommentService _commentService = CommentoCommentService();

  // Local database services
  final BookmarkService _bookmarkService = BookmarkService();
  final ComicChapterService _comicChapterService = ComicChapterService();

  ComicNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty state

    // Check if we have a comic ID in arguments
    String comicId = Mahas.argument<String>('comicId') ?? '';
    state = state.copyWith(comicId: comicId);

    fetchComicDetails();

    // Check bookmark status from local database
    if (comicId.isNotEmpty) {
      _checkBookmarkStatus(comicId);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  /// Fetch comic details by ID
  /// If comicId is null, tries to get it from Mahas.argument
  Future<void> fetchComicDetails() async {
    runAsync('fetchComicDetails', () async {
      // Set loading state for comic details
      state = state.copyWith(detailStatus: ComicStateStatus.loading);

      final _comicId = state.comicId;
      if (_comicId == null || _comicId.isEmpty) {
        state = state.copyWith(
          detailStatus: ComicStateStatus.error,
          errorMessage: 'Comic ID is required',
        );
        return;
      }

      try {
        // Fetch manga detail from Shinigami API
        final manga = await _mangaService.getMangaDetail(_comicId);

        // Update state with comic details
        state = state.copyWith(
          detailStatus: ComicStateStatus.success,
          selectedComic: manga,
          errorMessage: null,
        );

        // Fetch chapters after getting manga details
        await fetchComicChapters();

        // Load chapter read status after chapters are loaded
        await _loadChapterReadStatus();
      } catch (e, stackTrace) {
        logger.e('Error fetching comic details',
            error: e, stackTrace: stackTrace);
        state = state.copyWith(
          detailStatus: ComicStateStatus.error,
          errorMessage: 'Failed to load comic details: ${e.toString()}',
        );
      }
    });
  }

  /// Fetch comic chapters with pagination
  Future<void> fetchComicChapters({int page = 1, int pageSize = 20}) async {
    runAsync('fetchComicChapters', () async {
      final _comicId = state.comicId;
      if (_comicId == null || _comicId.isEmpty) {
        return;
      }

      try {
        // Set loading state for chapters
        if (page == 1) {
          state = state.copyWith(chapterStatus: ComicStateStatus.loading);
        } else {
          state = state.copyWith(isLoadingMoreChapters: true);
        }

        // Get chapters from Shinigami API
        final chaptersResponse = await _chapterService.getChaptersByMangaId(
          mangaId: _comicId,
          page: page,
          pageSize: pageSize,
        );

        // If this is the first page, replace chapters
        if (page == 1) {
          state = state.copyWith(
            chapterStatus: ComicStateStatus.success,
            chapters: chaptersResponse.data,
            chapterMeta: chaptersResponse.meta,
            isLoadingMoreChapters: false,
            hasMoreChapters: chaptersResponse.meta.hasMore,
            errorMessage: null,
          );

          // Load chapter read status after chapters are loaded (first page only)
          await _loadChapterReadStatus();
        } else {
          // For pagination, append new chapters to existing ones
          final combinedChapters = [
            ...state.chapters,
            ...chaptersResponse.data,
          ];

          state = state.copyWith(
            chapters: combinedChapters,
            chapterMeta: chaptersResponse.meta,
            isLoadingMoreChapters: false,
            hasMoreChapters: chaptersResponse.meta.hasMore,
          );
        }
      } catch (e, stackTrace) {
        logger.e('Error fetching chapters', error: e, stackTrace: stackTrace);

        if (page == 1) {
          state = state.copyWith(
            chapterStatus: ComicStateStatus.error,
            errorMessage: 'Failed to load chapters: ${e.toString()}',
          );
        } else {
          state = state.copyWith(isLoadingMoreChapters: false);
        }
      }
    });
  }

  /// Load more chapters for pagination
  Future<void> loadMoreChapters() async {
    // Don't load if already loading or no more chapters
    if (state.isLoadingMoreChapters || !state.hasMoreChapters) {
      return;
    }

    final currentPage = state.chapterMeta?.page ?? 0;
    final nextPage = currentPage + 1;

    try {
      await fetchComicChapters(page: nextPage);
    } catch (e, stackTrace) {
      logger.e('Error loading more chapters', error: e, stackTrace: stackTrace);
      // Reset loading state on error
      state = state.copyWith(isLoadingMoreChapters: false);
    }
  }

  /// Check bookmark status from local database
  Future<void> _checkBookmarkStatus(String comicId) async {
    try {
      final isBookmarked = await _bookmarkService.isBookmarked(comicId);
      state = state.copyWith(isBookmarked: isBookmarked);
    } catch (e, stackTrace) {
      logger.e('Error checking bookmark status',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Toggle bookmark status for the current comic
  Future<void> toggleBookmark() async {
    final comic = state.selectedComic;
    final comicId = state.comicId;

    if (comic == null || comicId == null || comicId.isEmpty) return;

    runAsync('toggleBookmark', () async {
      // Set loading state
      state = state.copyWith(bookmarkStatus: ComicStateStatus.loading);

      try {
        // Toggle bookmark in local database
        final isBookmarked = await _bookmarkService.toggleBookmark(
          comicId: comicId,
          urlCover: comic.displayCoverUrl,
          title: comic.title,
          nation: comic.countryId ?? 'Unknown',
        );

        state = state.copyWith(
          isBookmarked: isBookmarked,
          bookmarkStatus: ComicStateStatus.success,
          errorMessage: null,
        );
      } catch (e, stackTrace) {
        logger.e('Error toggling bookmark', error: e, stackTrace: stackTrace);
        state = state.copyWith(
          bookmarkStatus: ComicStateStatus.error,
          errorMessage: 'Failed to update bookmark: ${e.toString()}',
        );
      }
    });
  }

  /// Update reading progress for a chapter
  void updateReadingProgress(String chapterId, double progress) {
    run('updateReadingProgress', () {
      final updatedProgress = Map<String, double>.from(state.readingProgress);
      updatedProgress[chapterId] = progress.clamp(0.0, 1.0);

      String? lastReadChapter = state.lastReadChapterId;
      if (progress > 0.0) {
        lastReadChapter = chapterId;
      }

      state = state.copyWith(
        readingProgress: updatedProgress,
        lastReadChapterId: lastReadChapter,
      );
    });
  }

  /// Mark chapter as read (100% progress)
  void markChapterAsRead(String chapterId) {
    updateReadingProgress(chapterId, 1.0);
  }

  /// Clear reading progress for a chapter
  void clearChapterProgress(String chapterId) {
    run('clearChapterProgress', () {
      final updatedProgress = Map<String, double>.from(state.readingProgress);
      updatedProgress.remove(chapterId);

      state = state.copyWith(
        readingProgress: updatedProgress,
      );
    });
  }

  /// Reset all data (useful for navigation to different comic)
  void resetState() {
    run('resetState', () {
      state = const ComicState();
    });
  }

  /// Fetch comments for the current comic
  Future<void> fetchComments({int page = 1, int pageSize = 10}) async {
    runAsync('fetchComments', () async {
      final _comicId = state.comicId;
      if (_comicId == null || _comicId.isEmpty) {
        return;
      }

      try {
        // Set loading state for comments
        if (page == 1) {
          state = state.copyWith(commentStatus: ComicStateStatus.loading);
        } else {
          state = state.copyWith(isLoadingMoreComments: true);
        }

        // Get comments from Commento API
        final commentResponse = await _commentService.getComments(
          mangaId: _comicId,
          page: page,
          pageSize: pageSize,
        );

        if (commentResponse.isSuccess) {
          // If this is the first page, replace comments
          if (page == 1) {
            state = state.copyWith(
              commentStatus: ComicStateStatus.success,
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
              commentStatus: ComicStateStatus.error,
              errorMessage:
                  'Failed to load comments: ${commentResponse.errmsg}',
            );
          } else {
            state = state.copyWith(isLoadingMoreComments: false);
          }
        }
      } catch (e, stackTrace) {
        logger.e('Error fetching comments', error: e, stackTrace: stackTrace);

        if (page == 1) {
          state = state.copyWith(
            commentStatus: ComicStateStatus.error,
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
      logger.e('Error loading more comments', error: e, stackTrace: stackTrace);
      // Reset loading state on error
      state = state.copyWith(isLoadingMoreComments: false);
    }
  }

  /// Get comment statistics for the current comic
  Future<void> fetchCommentStats() async {
    runAsync('fetchCommentStats', () async {
      final _comicId = state.comicId;
      if (_comicId == null || _comicId.isEmpty) {
        return;
      }

      try {
        final stats = await _commentService.getCommentStats(_comicId);

        state = state.copyWith(
          totalCommentCount: stats['total_comments'] as int? ?? 0,
        );
      } catch (e, stackTrace) {
        logger.e('Error fetching comment stats',
            error: e, stackTrace: stackTrace);
      }
    });
  }

  /// Check if the current comic has comments
  Future<bool> hasComments() async {
    final _comicId = state.comicId;
    if (_comicId == null || _comicId.isEmpty) {
      return false;
    }

    try {
      return await _commentService.hasComments(_comicId);
    } catch (e, stackTrace) {
      logger.e('Error checking if comic has comments',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Refresh all comic data including comments
  Future<void> refresh() async {
    await Future.wait([
      fetchComicDetails(),
      fetchCommentStats(),
    ]);
  }

  /// Refresh only comments
  Future<void> refreshComments() async {
    await fetchComments(page: 1);
  }

  /// Refresh chapter read status (useful when returning from chapter page)
  Future<void> refreshChapterReadStatus() async {
    await _loadChapterReadStatus();
  }

  // ==================== CHAPTER READ STATUS METHODS ====================

  /// Load chapter read status from database for all chapters
  Future<void> _loadChapterReadStatus() async {
    try {
      final comicId = state.comicId;
      if (comicId == null || comicId.isEmpty || state.chapters.isEmpty) {
        return;
      }

      // Get all read chapters for this comic from database
      final readChapterIds = <String>{};

      for (final chapter in state.chapters) {
        // Use chapter ID for reliable checking
        final isRead = await _comicChapterService.isChapterReadById(
          comicId,
          chapter.chapterId,
        );

        if (isRead) {
          readChapterIds.add(chapter.chapterId);
        }
      }

      // Update state with read chapter IDs
      state = state.copyWith(readChapterIds: readChapterIds);
    } catch (e, stackTrace) {
      logger.e(
        'Error loading chapter read status',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow - this is background operation
    }
  }

  /// Mark specific chapter as read in database and update UI
  Future<void> markChapterAsReadInDB(
      String chapterId, String chapterTitle) async {
    try {
      final comicId = state.comicId;
      if (comicId == null || comicId.isEmpty) return;

      // Mark chapter as read in database
      await _comicChapterService.markChapterRead(
        comicId: comicId,
        chapter: chapterTitle,
        chapterId: chapterId,
        isCompleted: true,
      );

      // Update local state
      final updatedReadChapterIds = Set<String>.from(state.readChapterIds);
      updatedReadChapterIds.add(chapterId);

      state = state.copyWith(readChapterIds: updatedReadChapterIds);
    } catch (e, stackTrace) {
      logger.e(
        'Error marking chapter as read',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Check if specific chapter is read
  bool isChapterRead(String chapterId) {
    return state.isChapterReadFromDB(chapterId);
  }

  /// Get read chapters count
  int get readChaptersCount => state.readChapterIds.length;

  /// Get reading progress percentage based on read chapters
  double get readingProgressPercentage {
    if (state.chapters.isEmpty) return 0.0;
    return (state.readChapterIds.length / state.chapters.length) * 100;
  }
}
