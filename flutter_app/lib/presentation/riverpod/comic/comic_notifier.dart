import '../../../core/base/base_state_notifier.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/datasource/network/service/comic_service.dart';
import '../../../data/datasource/network/service/optimized_comic_service.dart';
import '../../../data/models/complete_comic_model.dart';
import '../../../data/models/pagination_model.dart';
import '../../../data/models/comment_model.dart';
import 'comic_state.dart';

class ComicNotifier extends BaseStateNotifier<ComicState> {
  final ComicService _comicService = ComicService();
  final OptimizedComicService _optimizedComicService = OptimizedComicService();

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

      // Use the optimized service to fetch complete comic details

      final _comicId = state.comicId;
      if (_comicId == null) {
        return;
      }

      final completeComic =
          await _optimizedComicService.getCompleteComicDetails(_comicId);

      // Update state with comic details
      state = state.copyWith(
        detailStatus: ComicStateStatus.success,
        selectedComic: completeComic,
      );

      await fetchComicChapters();
    });
  }

  /// Fetch comic chapters with pagination
  Future<void> fetchComicChapters({int page = 1, int limit = 20}) async {
    runAsync('fetchComicChapters', () async {
      // Set loading state for chapters
      state = state.copyWith(isLoadingMoreChapters: true);
      final _comicId = state.comicId;
      if (_comicId == null) {
        return;
      }

      // Get chapters using the new method that returns a structured response
      final chaptersResponse = await _comicService.getComicChapters(
        comicId: _comicId,
        page: page,
        limit: limit,
      );

      // Since CompleteComic no longer has chapters field, we need to store chapters separately in state
      // If this is the first page, replace chapters
      if (page == 1 && state.selectedComic != null) {
        // Create chapter list with pagination meta
        final chapterList = ChapterList(
          data: chaptersResponse.chapters,
          meta: chaptersResponse.meta,
        );

        state = state.copyWith(
          chapterList: chapterList,
          isLoadingMoreChapters: false,
          hasMoreChapters: chaptersResponse.meta.hasMore,
        );
      } else if (state.selectedComic != null) {
        // For pagination, append new chapters to existing ones
        final currentChapters = state.chapterList?.data ?? [];
        final combinedChapters = [
          ...currentChapters,
          ...chaptersResponse.chapters
        ];

        // Create updated metadata
        final updatedMeta = chaptersResponse.meta;

        // Create updated chapter list
        final updatedChapterList = ChapterList(
          data: combinedChapters,
          meta: updatedMeta,
        );

        state = state.copyWith(
          chapterList: updatedChapterList,
          isLoadingMoreChapters: false,
          hasMoreChapters: chaptersResponse.meta.hasMore,
        );
      }
    });
  }

  /// Load more chapters for pagination
  Future<void> loadMoreChapters() async {
    // Don't load if already loading or no more chapters
    if (state.isLoadingMoreChapters || !state.hasMoreChapters) {
      return;
    }

    final currentPage = state.chapterList?.meta.page ?? 0;
    final nextPage = currentPage + 1;

    try {
      await fetchComicChapters(page: nextPage);
    } catch (e, stackTrace) {
      logger.e('Error loading more chapters', error: e, stackTrace: stackTrace);
      // Reset loading state on error
      state = state.copyWith(isLoadingMoreChapters: false);
    }
  }

  /// Fetch comments for the current comic with pagination
  Future<void> fetchComments(int page,
      {int limit = 10, bool parentOnly = false}) async {
    if (state.selectedComic == null) {
      return;
    }

    try {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(commentStatus: ComicStateStatus.loading);
      } else {
        state = state.copyWith(isLoadingMoreComments: true);
      }

      // This will be updated in a separate task

      // Placeholder implementation - will be replaced
      await Future.delayed(
          const Duration(milliseconds: 500)); // Simulate network delay

      // Empty comments list for now
      final List<Comment> comments = [];

      // Create pagination meta
      final commentMeta = PaginationMeta(
        page: page,
        limit: limit,
        total: 0,
        totalPages: 1,
        hasMore: false,
      );

      // Update loading states
      if (page == 1) {
        state = state.copyWith(
          commentStatus: ComicStateStatus.success,
          comments: comments,
          commentMeta: commentMeta,
          isLoadingMoreComments: false,
          hasMoreComments: false,
        );
      } else {
        state = state.copyWith(
          comments: [...state.comments],
          commentMeta: commentMeta,
          isLoadingMoreComments: false,
          hasMoreComments: false,
        );
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
  }
}
