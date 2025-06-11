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

  // Bookmark state
  final bool isBookmarked;
  final ComicStateStatus bookmarkStatus;

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
    this.isBookmarked = false,
    this.bookmarkStatus = ComicStateStatus.initial,
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
    bool? isBookmarked,
    ComicStateStatus? bookmarkStatus,
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
      isBookmarked: isBookmarked ?? this.isBookmarked,
      bookmarkStatus: bookmarkStatus ?? this.bookmarkStatus,
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
  bool get hasError =>
      detailStatus == ComicStateStatus.error ||
      chapterStatus == ComicStateStatus.error;

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
}
