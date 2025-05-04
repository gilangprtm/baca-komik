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
    final String? comicId = Mahas.argument<String>('comicId');
    if (comicId != null) {
      // Fetch comic details automatically if ID is provided
      fetchComicDetails(comicId);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  /// Fetch comic details by ID
  /// If comicId is null, tries to get it from Mahas.argument
  Future<void> fetchComicDetails([String? comicId]) async {
    // If comicId is not provided, try to get it from arguments
    comicId ??= Mahas.argument<String>('comicId');

    // If still null, return with error
    if (comicId == null) {
      state = state.copyWith(
        detailStatus: ComicStateStatus.error,
        errorMessage: 'Comic ID not provided',
      );
      return;
    }
    try {
      state = state.copyWith(detailStatus: ComicStateStatus.loading);

      // Use the optimized service to fetch complete comic details
      final completeComic =
          await _optimizedComicService.getCompleteComicDetails(comicId);

      // Update state with comic details
      state = state.copyWith(
        detailStatus: ComicStateStatus.success,
        selectedComic: completeComic,
      );

      // After setting the basic comic details, fetch chapters separately
      await fetchComicChapters(comicId, page: 1, limit: 20);
    } catch (e, stackTrace) {
      logger.e('Error fetching comic details',
          error: e, stackTrace: stackTrace);
      state = state.copyWith(
        detailStatus: ComicStateStatus.error,
        errorMessage: 'Failed to load comic details: ${e.toString()}',
      );
    }
  }

  /// Fetch comic chapters with pagination
  Future<void> fetchComicChapters(String comicId,
      {int page = 1, int limit = 20}) async {
    try {
      // Set loading state for chapters
      state = state.copyWith(isLoadingMoreChapters: true);

      // Get chapters using the new method that returns a structured response
      final chaptersResponse = await _comicService.getComicChapters(
        comicId: comicId,
        page: page,
        limit: limit,
      );

      // Since CompleteComic no longer has chapters field, we need to store chapters separately in state
      // If this is the first page, replace chapters
      if (page == 1 && state.selectedComic != null) {
        // Create chapter list with pagination meta
        final chapterList = ChapterList(
          data: chaptersResponse.chapters,
          meta: PaginationMeta(
            currentPage: chaptersResponse.meta.currentPage,
            lastPage: chaptersResponse.meta.lastPage,
            perPage: chaptersResponse.meta.perPage,
            total: chaptersResponse.meta.total,
          ),
        );

        state = state.copyWith(
          chapterList: chapterList,
          isLoadingMoreChapters: false,
          hasMoreChapters: page < chaptersResponse.meta.lastPage,
        );
      } else if (state.selectedComic != null) {
        // For pagination, append new chapters to existing ones
        final currentChapters = state.chapterList?.data ?? [];
        final combinedChapters = [
          ...currentChapters,
          ...chaptersResponse.chapters
        ];

        // Create updated metadata
        final updatedMeta = PaginationMeta(
          currentPage: chaptersResponse.meta.currentPage,
          lastPage: chaptersResponse.meta.lastPage,
          perPage: chaptersResponse.meta.perPage,
          total: chaptersResponse.meta.total,
        );

        // Create updated chapter list
        final updatedChapterList = ChapterList(
          data: combinedChapters,
          meta: updatedMeta,
        );

        state = state.copyWith(
          chapterList: updatedChapterList,
          isLoadingMoreChapters: false,
          hasMoreChapters: page < chaptersResponse.meta.lastPage,
        );
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching comic chapters',
          error: e, stackTrace: stackTrace);
      // Update loading state to false
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
        currentPage: page,
        lastPage: page,
        perPage: limit,
        total: 0,
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
