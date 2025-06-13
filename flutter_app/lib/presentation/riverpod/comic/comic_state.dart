import 'package:flutter/foundation.dart';
import '../../../data/models/shinigami/shinigami_models.dart';

enum ComicStateStatus { initial, loading, success, error }

@immutable
class ComicState {
  final String? comicId;

  // Comic detail state
  final ComicStateStatus detailStatus;
  final ShinigamiManga? selectedComic;
  final String? errorMessage;

  // Chapter state
  final ComicStateStatus chapterStatus;
  final List<ShinigamiChapter> chapters;
  final ShinigamiMeta? chapterMeta;
  final bool isLoadingMoreChapters;
  final bool hasMoreChapters;

  // Reading progress state
  final Map<String, double>
      readingProgress; // chapterId -> progress (0.0 to 1.0)
  final String? lastReadChapterId;

  // Chapter read status from database
  final Set<String> readChapterIds; // Set of chapter IDs that have been read

  // Bookmark state
  final bool isBookmarked;
  final ComicStateStatus bookmarkStatus;

  // Comment state
  final ComicStateStatus commentStatus;
  final List<CommentoComment> comments;
  final CommentoCommentListResponse? commentPagination;
  final bool isLoadingMoreComments;
  final bool hasMoreComments;
  final int totalCommentCount;

  const ComicState({
    this.comicId,
    this.detailStatus = ComicStateStatus.initial,
    this.selectedComic,
    this.errorMessage,
    this.chapterStatus = ComicStateStatus.initial,
    this.chapters = const [],
    this.chapterMeta,
    this.isLoadingMoreChapters = false,
    this.hasMoreChapters = true,
    this.readingProgress = const {},
    this.lastReadChapterId,
    this.readChapterIds = const {},
    this.isBookmarked = false,
    this.bookmarkStatus = ComicStateStatus.initial,
    this.commentStatus = ComicStateStatus.initial,
    this.comments = const [],
    this.commentPagination,
    this.isLoadingMoreComments = false,
    this.hasMoreComments = true,
    this.totalCommentCount = 0,
  });

  ComicState copyWith({
    String? comicId,
    ComicStateStatus? detailStatus,
    ShinigamiManga? selectedComic,
    String? errorMessage,
    ComicStateStatus? chapterStatus,
    List<ShinigamiChapter>? chapters,
    ShinigamiMeta? chapterMeta,
    bool? isLoadingMoreChapters,
    bool? hasMoreChapters,
    Map<String, double>? readingProgress,
    String? lastReadChapterId,
    Set<String>? readChapterIds,
    bool? isBookmarked,
    ComicStateStatus? bookmarkStatus,
    ComicStateStatus? commentStatus,
    List<CommentoComment>? comments,
    CommentoCommentListResponse? commentPagination,
    bool? isLoadingMoreComments,
    bool? hasMoreComments,
    int? totalCommentCount,
  }) {
    return ComicState(
      comicId: comicId ?? this.comicId,
      detailStatus: detailStatus ?? this.detailStatus,
      selectedComic: selectedComic ?? this.selectedComic,
      errorMessage: errorMessage ?? this.errorMessage,
      chapterStatus: chapterStatus ?? this.chapterStatus,
      chapters: chapters ?? this.chapters,
      chapterMeta: chapterMeta ?? this.chapterMeta,
      isLoadingMoreChapters:
          isLoadingMoreChapters ?? this.isLoadingMoreChapters,
      hasMoreChapters: hasMoreChapters ?? this.hasMoreChapters,
      readingProgress: readingProgress ?? this.readingProgress,
      lastReadChapterId: lastReadChapterId ?? this.lastReadChapterId,
      readChapterIds: readChapterIds ?? this.readChapterIds,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      bookmarkStatus: bookmarkStatus ?? this.bookmarkStatus,
      commentStatus: commentStatus ?? this.commentStatus,
      comments: comments ?? this.comments,
      commentPagination: commentPagination ?? this.commentPagination,
      isLoadingMoreComments:
          isLoadingMoreComments ?? this.isLoadingMoreComments,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      totalCommentCount: totalCommentCount ?? this.totalCommentCount,
    );
  }

  // Helper methods for chapter pagination
  int get currentChapterPage => chapterMeta?.currentPage ?? 0;
  int get totalChapterPages => chapterMeta?.lastPage ?? 0;
  int get totalChapters => chapterMeta?.total ?? 0;
  bool get hasChapters => chapters.isNotEmpty;
  bool get canLoadMoreChapters => hasMoreChapters && !isLoadingMoreChapters;

  // Helper methods for reading progress
  double getChapterProgress(String chapterId) =>
      readingProgress[chapterId] ?? 0.0;
  bool isChapterRead(String chapterId) => getChapterProgress(chapterId) >= 0.9;
  bool isChapterStarted(String chapterId) =>
      getChapterProgress(chapterId) > 0.0;

  // Helper methods for chapter read status from database
  bool isChapterReadFromDB(String chapterId) =>
      readChapterIds.contains(chapterId);
  bool isChapterReadFromDBByTitle(String chapterTitle) {
    // Find chapter by title and check if it's read
    final chapter =
        chapters.where((c) => c.chapterTitle == chapterTitle).firstOrNull;
    return chapter != null ? readChapterIds.contains(chapter.chapterId) : false;
  }

  // Helper methods for comic info
  bool get hasSelectedComic => selectedComic != null;
  String get comicTitle => selectedComic?.title ?? '';
  String get comicDescription => selectedComic?.description ?? '';
  List<ShinigamiGenre> get comicGenres =>
      selectedComic?.taxonomy.genre.cast<ShinigamiGenre>() ??
      <ShinigamiGenre>[];
  double get comicRating => selectedComic?.userRate ?? 0.0;
  int get comicViewCount => selectedComic?.viewCount ?? 0;
  int get comicBookmarkCount => selectedComic?.bookmarkCount ?? 0;

  // Helper methods for chapter navigation
  ShinigamiChapter? get firstChapter =>
      chapters.isNotEmpty ? chapters.first : null;
  ShinigamiChapter? get lastChapter =>
      chapters.isNotEmpty ? chapters.last : null;
  ShinigamiChapter? get lastReadChapter => lastReadChapterId != null
      ? chapters.where((c) => c.chapterId == lastReadChapterId).firstOrNull
      : null;

  // Helper methods for loading states
  bool get isLoadingDetail => detailStatus == ComicStateStatus.loading;
  bool get isLoadingChapters => chapterStatus == ComicStateStatus.loading;
  bool get isLoadingBookmark => bookmarkStatus == ComicStateStatus.loading;
  bool get isLoadingComments => commentStatus == ComicStateStatus.loading;
  bool get hasError =>
      detailStatus == ComicStateStatus.error ||
      chapterStatus == ComicStateStatus.error ||
      commentStatus == ComicStateStatus.error;

  // Helper method to get reading statistics
  Map<String, dynamic> get readingStats => {
        'total_chapters': totalChapters,
        'read_chapters':
            readingProgress.values.where((progress) => progress >= 0.9).length,
        'started_chapters':
            readingProgress.values.where((progress) => progress > 0.0).length,
        'reading_progress_percentage': totalChapters > 0
            ? (readingProgress.values
                        .where((progress) => progress >= 0.9)
                        .length /
                    totalChapters *
                    100)
                .round()
            : 0,
      };

  // Helper methods for comment pagination
  int get currentCommentPage => commentPagination?.page ?? 0;
  int get totalCommentPages => commentPagination?.totalPages ?? 0;
  bool get hasComments => comments.isNotEmpty;
  bool get canLoadMoreComments => hasMoreComments && !isLoadingMoreComments;

  // Helper methods for comment info
  List<CommentoComment> get rootComments =>
      comments.where((comment) => comment.isRootComment).toList();
  int get rootCommentCount => rootComments.length;
  int get replyCount => comments.length - rootCommentCount;

  // Helper method to get comment statistics
  Map<String, dynamic> get commentStats => {
        'total_comments': totalCommentCount,
        'loaded_comments': comments.length,
        'root_comments': rootCommentCount,
        'replies': replyCount,
        'current_page': currentCommentPage,
        'total_pages': totalCommentPages,
        'has_more': hasMoreComments,
      };
}
