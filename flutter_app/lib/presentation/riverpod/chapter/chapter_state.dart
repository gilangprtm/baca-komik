import 'package:flutter/foundation.dart';
import '../../../data/models/shinigami/shinigami_models.dart';

enum ChapterStateStatus { initial, loading, success, error }

@immutable
class ChapterState {
  // Status
  final ChapterStateStatus detailStatus;
  final ChapterStateStatus pagesStatus;
  final ChapterStateStatus navigationStatus;

  // Data
  final ShinigamiChapter? selectedChapter;
  final ShinigamiManga? comicModel;
  final List<ShinigamiPage> pages;
  final ShinigamiChapterNavigation? navigation;
  final ShinigamiMeta? chapterMeta;

  // Current state
  final int currentPageIndex;
  final bool isFullscreen;
  final bool showControls;
  final double zoomLevel;
  final bool isHorizontalReading;

  // Navigation state
  final String? nextChapterId;
  final String? prevChapterId;
  final int? nextChapterNumber;
  final int? prevChapterNumber;
  final bool isFirstChapter;
  final bool isLastChapter;

  // Loading states
  final Map<String, bool> loadingStates;

  // Error handling
  final String? errorMessage;

  // Reading progress
  final bool isTrackingProgress;
  final DateTime? lastReadAt;

  // Comment state
  final ChapterStateStatus commentStatus;
  final List<CommentoComment> comments;
  final CommentoCommentListResponse? commentPagination;
  final bool isLoadingMoreComments;
  final bool hasMoreComments;
  final int totalCommentCount;

  const ChapterState({
    this.detailStatus = ChapterStateStatus.initial,
    this.pagesStatus = ChapterStateStatus.initial,
    this.navigationStatus = ChapterStateStatus.initial,
    this.selectedChapter,
    this.comicModel,
    this.pages = const [],
    this.navigation,
    this.chapterMeta,
    this.currentPageIndex = 0,
    this.isFullscreen = false,
    this.showControls = true,
    this.zoomLevel = 1.0,
    this.isHorizontalReading = true,
    this.nextChapterId,
    this.prevChapterId,
    this.nextChapterNumber,
    this.prevChapterNumber,
    this.isFirstChapter = false,
    this.isLastChapter = false,
    this.loadingStates = const {},
    this.errorMessage,
    this.isTrackingProgress = false,
    this.lastReadAt,
    this.commentStatus = ChapterStateStatus.initial,
    this.comments = const [],
    this.commentPagination,
    this.isLoadingMoreComments = false,
    this.hasMoreComments = true,
    this.totalCommentCount = 0,
  });

  ChapterState copyWith({
    ChapterStateStatus? detailStatus,
    ChapterStateStatus? pagesStatus,
    ChapterStateStatus? navigationStatus,
    ShinigamiChapter? selectedChapter,
    ShinigamiManga? comicModel,
    List<ShinigamiPage>? pages,
    ShinigamiChapterNavigation? navigation,
    ShinigamiMeta? chapterMeta,
    int? currentPageIndex,
    bool? isFullscreen,
    bool? showControls,
    double? zoomLevel,
    bool? isHorizontalReading,
    String? nextChapterId,
    String? prevChapterId,
    int? nextChapterNumber,
    int? prevChapterNumber,
    bool? isFirstChapter,
    bool? isLastChapter,
    Map<String, bool>? loadingStates,
    String? errorMessage,
    bool? isTrackingProgress,
    DateTime? lastReadAt,
    ChapterStateStatus? commentStatus,
    List<CommentoComment>? comments,
    CommentoCommentListResponse? commentPagination,
    bool? isLoadingMoreComments,
    bool? hasMoreComments,
    int? totalCommentCount,
  }) {
    return ChapterState(
      detailStatus: detailStatus ?? this.detailStatus,
      pagesStatus: pagesStatus ?? this.pagesStatus,
      navigationStatus: navigationStatus ?? this.navigationStatus,
      selectedChapter: selectedChapter ?? this.selectedChapter,
      comicModel: comicModel ?? this.comicModel,
      pages: pages ?? this.pages,
      navigation: navigation ?? this.navigation,
      chapterMeta: chapterMeta ?? this.chapterMeta,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      showControls: showControls ?? this.showControls,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      isHorizontalReading: isHorizontalReading ?? this.isHorizontalReading,
      nextChapterId: nextChapterId ?? this.nextChapterId,
      prevChapterId: prevChapterId ?? this.prevChapterId,
      nextChapterNumber: nextChapterNumber ?? this.nextChapterNumber,
      prevChapterNumber: prevChapterNumber ?? this.prevChapterNumber,
      isFirstChapter: isFirstChapter ?? this.isFirstChapter,
      isLastChapter: isLastChapter ?? this.isLastChapter,
      loadingStates: loadingStates ?? this.loadingStates,
      errorMessage: errorMessage ?? this.errorMessage,
      isTrackingProgress: isTrackingProgress ?? this.isTrackingProgress,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      commentStatus: commentStatus ?? this.commentStatus,
      comments: comments ?? this.comments,
      commentPagination: commentPagination ?? this.commentPagination,
      isLoadingMoreComments:
          isLoadingMoreComments ?? this.isLoadingMoreComments,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
      totalCommentCount: totalCommentCount ?? this.totalCommentCount,
    );
  }

  // Helper methods for reader
  bool get isFirstPage => currentPageIndex == 0;

  bool get isLastPage {
    if (pages.isEmpty) return true;
    return currentPageIndex >= pages.length - 1;
  }

  int get totalPages => pages.length;

  // Helper methods for chapter navigation
  bool get hasNextChapter => nextChapterId != null && !isLastChapter;
  bool get hasPreviousChapter => prevChapterId != null && !isFirstChapter;

  // Status helpers
  bool get isLoadingDetail => detailStatus == ChapterStateStatus.loading;
  bool get isLoadingPages => pagesStatus == ChapterStateStatus.loading;
  bool get isLoadingNavigation =>
      navigationStatus == ChapterStateStatus.loading;
  bool get isLoadingComments => commentStatus == ChapterStateStatus.loading;
  bool get hasError =>
      detailStatus == ChapterStateStatus.error ||
      pagesStatus == ChapterStateStatus.error ||
      navigationStatus == ChapterStateStatus.error ||
      commentStatus == ChapterStateStatus.error;
  bool get isSuccess =>
      detailStatus == ChapterStateStatus.success &&
      pagesStatus == ChapterStateStatus.success;

  // Data helpers
  bool get hasChapter => selectedChapter != null;
  bool get hasPages => pages.isNotEmpty;
  bool get hasNavigation => navigation != null;
  bool get canGoToNextPage => currentPageIndex < totalPages - 1;
  bool get canGoToPrevPage => currentPageIndex > 0;

  // Chapter info helpers
  String get chapterTitle => selectedChapter?.chapterTitle ?? '';
  int get chapterNumber => selectedChapter?.chapterNumber ?? 0;
  String get mangaId => selectedChapter?.mangaId ?? '';
  String get chapterId => selectedChapter?.chapterId ?? '';

  // Progress helpers
  double get readingProgress =>
      totalPages > 0 ? (currentPageIndex + 1) / totalPages : 0.0;
  String get progressText => '${currentPageIndex + 1} / $totalPages';

  // Loading state helpers
  bool isLoading(String key) => loadingStates[key] ?? false;
  bool get isLoadingNextChapter => isLoading('next_chapter');
  bool get isLoadingPrevChapter => isLoading('prev_chapter');
  bool get isLoadingProgress => isLoading('progress');

  // Page helpers
  ShinigamiPage? get currentPage => hasPages && currentPageIndex < pages.length
      ? pages[currentPageIndex]
      : null;
  String? get currentPageUrl => currentPage?.imageUrl;
  String? get currentPageLowUrl => currentPage?.lowQualityImageUrl;

  // Chapter navigation helpers
  String get displayTitle =>
      chapterTitle.isNotEmpty ? chapterTitle : 'Chapter $chapterNumber';
  String get fullTitle =>
      'Chapter $chapterNumber${chapterTitle.isNotEmpty ? ': $chapterTitle' : ''}';

  // Comment helpers
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

  /// Initial state factory
  factory ChapterState.initial() => const ChapterState();
}
