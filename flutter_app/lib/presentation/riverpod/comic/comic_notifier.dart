import '../../../core/base/base_state_notifier.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../data/datasource/network/service/comic_service.dart';
import '../../../data/datasource/network/service/optimized_comic_service.dart';
import '../../../data/datasource/network/service/vote_service.dart';
import '../../../data/datasource/network/service/bookmark_service.dart';
import '../../../data/models/complete_comic_model.dart';
import '../../../data/models/pagination_model.dart';
import '../../../data/models/comment_model.dart';
import 'comic_state.dart';

class ComicNotifier extends BaseStateNotifier<ComicState> {
  final ComicService _comicService = ComicService();
  final OptimizedComicService _optimizedComicService = OptimizedComicService();
  final VoteService _voteService = VoteService();
  final BookmarkService _bookmarkService = BookmarkService();

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

  /// Toggle upvote untuk komik yang sedang dilihat
  /// Mengembalikan [bool] yang menunjukkan apakah terjadi error unauthorized
  Future<bool> toggleComicVote() async {
    if (state.selectedComic == null) {
      logger.e('Tidak ada komik yang dipilih');
      return false;
    }

    try {
      // Mendapatkan ID komik dari comic yang ada di state
      final comicId = state.selectedComic!.comic.id;

      // Memanggil vote service untuk toggle vote
      final result = await _voteService.toggleVote(comicId, 'comic');

      if (result.success) {
        // Membuat objek UserComicData baru dengan status vote yang diperbarui
        final updatedUserData = UserComicData(
          isBookmarked: state.selectedComic!.userData.isBookmarked,
          isVoted: result.voted,
          lastReadChapter: state.selectedComic!.userData.lastReadChapter,
        );

        // Membuat objek Comic baru dengan jumlah vote yang diperbarui
        final updatedComic = state.selectedComic!.comic.copyWith(
          voteCount: result.voteCount,
        );

        // Membuat objek CompleteComic baru dengan data yang diperbarui
        final updatedCompleteComic = CompleteComic(
          comic: updatedComic,
          userData: updatedUserData,
        );

        // Memperbarui state dengan data komik yang baru
        state = state.copyWith(selectedComic: updatedCompleteComic);

        // Log hasil operasi
        logger.i(result.message);
        return false; // Tidak ada error unauthorized
      } else {
        logger.e('Gagal melakukan toggle vote: ${result.message}');
        // Cek apakah error adalah unauthorized
        if (result.message.toLowerCase().contains('unauthorized') ||
            result.message.toLowerCase().contains('login')) {
          return true; // Terjadi error unauthorized
        }
        return false;
      }
    } catch (e, stackTrace) {
      logger.e('Error saat toggle vote komik',
          error: e, stackTrace: stackTrace);
      // Cek apakah error adalah unauthorized
      if (e.toString().toLowerCase().contains('unauthorized') ||
          e.toString().toLowerCase().contains('401')) {
        return true; // Terjadi error unauthorized
      }
      return false;
    }
  }

  /// Toggle bookmark untuk komik yang sedang dilihat
  /// Mengembalikan [bool] yang menunjukkan apakah terjadi error unauthorized
  Future<bool> toggleBookmark() async {
    if (state.selectedComic == null) {
      logger.e('Tidak ada komik yang dipilih');
      return false;
    }

    try {
      // Mendapatkan ID komik dari comic yang ada di state
      final comicId = state.selectedComic!.comic.id;

      // Memanggil bookmark service untuk toggle bookmark
      final isBookmarked = await _bookmarkService.toggleBookmark(comicId);

      // Membuat objek UserComicData baru dengan status bookmark yang diperbarui
      final updatedUserData = UserComicData(
        isBookmarked: isBookmarked,
        isVoted: state.selectedComic!.userData.isVoted,
        lastReadChapter: state.selectedComic!.userData.lastReadChapter,
      );

      // Membuat objek Comic baru dengan jumlah bookmark yang diperbarui
      // Jika isBookmarked true, tambahkan 1, jika false, kurangi 1
      final updatedBookmarkCount = isBookmarked
          ? state.selectedComic!.comic.bookmarkCount + 1
          : state.selectedComic!.comic.bookmarkCount - 1;

      final updatedComic = state.selectedComic!.comic.copyWith(
        bookmarkCount: updatedBookmarkCount < 0 ? 0 : updatedBookmarkCount,
      );

      // Membuat objek CompleteComic baru dengan data yang diperbarui
      final updatedCompleteComic = CompleteComic(
        comic: updatedComic,
        userData: updatedUserData,
      );

      // Memperbarui state dengan data komik yang baru
      state = state.copyWith(selectedComic: updatedCompleteComic);

      // Log hasil operasi
      logger.i(isBookmarked
          ? 'Komik ditambahkan ke bookmark'
          : 'Komik dihapus dari bookmark');
      return false; // Tidak ada error unauthorized
    } catch (e, stackTrace) {
      logger.e('Error saat toggle bookmark', error: e, stackTrace: stackTrace);
      // Cek apakah error adalah unauthorized
      if (e.toString().toLowerCase().contains('unauthorized') ||
          e.toString().toLowerCase().contains('401')) {
        return true; // Terjadi error unauthorized
      }
      return false;
    }
  }
}
