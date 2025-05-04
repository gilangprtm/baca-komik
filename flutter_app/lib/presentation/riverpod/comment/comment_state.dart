import 'package:flutter/foundation.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/pagination_model.dart';

enum CommentStateStatus { initial, loading, success, error }

enum CommentType { comic, chapter }

@immutable
class CommentState {
  final CommentStateStatus status;
  final String? currentId;
  final CommentType? currentType;
  final List<Comment> comments;
  final PaginationMeta? meta;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isPosting;
  final String? errorMessage;

  const CommentState({
    this.status = CommentStateStatus.initial,
    this.currentId,
    this.currentType,
    this.comments = const [],
    this.meta,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isPosting = false,
    this.errorMessage,
  });

  CommentState copyWith({
    CommentStateStatus? status,
    String? currentId,
    CommentType? currentType,
    List<Comment>? comments,
    PaginationMeta? meta,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isPosting,
    String? errorMessage,
  }) {
    return CommentState(
      status: status ?? this.status,
      currentId: currentId ?? this.currentId,
      currentType: currentType ?? this.currentType,
      comments: comments ?? this.comments,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isPosting: isPosting ?? this.isPosting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper method to convert CommentType to string
  String get typeString {
    switch (currentType) {
      case CommentType.comic:
        return 'comic';
      case CommentType.chapter:
        return 'chapter';
      default:
        return 'comic';
    }
  }
}
