import 'package:flutter/foundation.dart';
import '../../../data/models/complete_comic_model.dart';
import '../../../data/models/pagination_model.dart';
import '../../../data/models/comment_model.dart';

enum ComicStateStatus { initial, loading, success, error }

@immutable
class ComicState {
  final String? comicId;

  // Comic detail state
  final ComicStateStatus detailStatus;
  final CompleteComic? selectedComic;
  final String? errorMessage;

  // Chapter state - since CompleteComic no longer includes chapters
  final ChapterList? chapterList;

  // Chapter pagination state
  final bool isLoadingMoreChapters;
  final bool hasMoreChapters;

  // Comment state
  final ComicStateStatus commentStatus;
  final List<Comment> comments;
  final PaginationMeta? commentMeta;
  final bool isLoadingMoreComments;
  final bool hasMoreComments;

  const ComicState({
    this.comicId,
    this.detailStatus = ComicStateStatus.initial,
    this.selectedComic,
    this.errorMessage,
    this.chapterList,
    this.isLoadingMoreChapters = false,
    this.hasMoreChapters = true,
    this.commentStatus = ComicStateStatus.initial,
    this.comments = const [],
    this.commentMeta,
    this.isLoadingMoreComments = false,
    this.hasMoreComments = true,
  });

  ComicState copyWith({
    String? comicId,
    ComicStateStatus? detailStatus,
    CompleteComic? selectedComic,
    String? errorMessage,
    ChapterList? chapterList,
    bool? isLoadingMoreChapters,
    bool? hasMoreChapters,
    ComicStateStatus? commentStatus,
    List<Comment>? comments,
    PaginationMeta? commentMeta,
    bool? isLoadingMoreComments,
    bool? hasMoreComments,
  }) {
    return ComicState(
      comicId: comicId ?? this.comicId,
      detailStatus: detailStatus ?? this.detailStatus,
      selectedComic: selectedComic ?? this.selectedComic,
      errorMessage: errorMessage ?? this.errorMessage,
      chapterList: chapterList ?? this.chapterList,
      isLoadingMoreChapters:
          isLoadingMoreChapters ?? this.isLoadingMoreChapters,
      hasMoreChapters: hasMoreChapters ?? this.hasMoreChapters,
      commentStatus: commentStatus ?? this.commentStatus,
      comments: comments ?? this.comments,
      commentMeta: commentMeta ?? this.commentMeta,
      isLoadingMoreComments:
          isLoadingMoreComments ?? this.isLoadingMoreComments,
      hasMoreComments: hasMoreComments ?? this.hasMoreComments,
    );
  }

  // Helper methods for chapter pagination
  int get currentChapterPage => chapterList?.meta.page ?? 0;
  int get totalChapterPages => chapterList?.meta.totalPages ?? 0;
  int get totalChapters => chapterList?.meta.total ?? 0;
  bool get hasChapters => chapterList != null && chapterList!.data.isNotEmpty;
  bool get canLoadMoreChapters => hasMoreChapters && !isLoadingMoreChapters;
}
