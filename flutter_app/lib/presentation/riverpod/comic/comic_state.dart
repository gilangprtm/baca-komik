import 'package:flutter/foundation.dart';
import '../../../data/models/complete_comic_model.dart';
import '../../../data/models/pagination_model.dart';
import '../../../data/models/comment_model.dart';

enum ComicStateStatus { initial, loading, success, error }

@immutable
class ComicState {
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
}
