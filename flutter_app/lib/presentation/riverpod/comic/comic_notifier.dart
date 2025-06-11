import '../../../core/base/base_state_notifier.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/datasource/network/service/shinigami_services.dart';
import 'comic_state.dart';

class ComicNotifier extends BaseStateNotifier<ComicState> {
  final ShinigamiMangaService _mangaService = ShinigamiMangaService();
  final ShinigamiChapterService _chapterService = ShinigamiChapterService();

  ComicNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty state

    // Check if we have a comic ID in arguments
    String comicId = Mahas.argument<String>('comicId') ?? '';
    state = state.copyWith(comicId: comicId);

    fetchComicDetails();
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

  /// Toggle bookmark status for the current comic
  Future<void> toggleBookmark() async {
    if (state.selectedComic == null) return;

    runAsync('toggleBookmark', () async {
      // Set loading state
      state = state.copyWith(bookmarkStatus: ComicStateStatus.loading);

      try {
        // TODO: Implement bookmark API call
        // For now, just toggle the local state
        final newBookmarkStatus = !state.isBookmarked;

        // Simulate API delay
        await Future.delayed(const Duration(milliseconds: 500));

        state = state.copyWith(
          isBookmarked: newBookmarkStatus,
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

  /// Refresh all comic data
  Future<void> refresh() async {
    await Future.wait([
      fetchComicDetails(),
    ]);
  }
}
