import 'package:flutter/foundation.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/metadata_models.dart';

enum CommentStateStatus { initial, loading, success, error }
enum CommentType { comic, chapter }

@immutable
class CommentState {
  final CommentStateStatus status;
  final List<Comment> comments;
  final MetaData? meta;
  final String? errorMessage;
  final bool isPosting;
  final bool isLoadingMore;
  final String? currentId; // ID of comic or chapter being viewed
  final CommentType? currentType; // Type of content being viewed (comic or chapter)

  const CommentState({
    this.status = CommentStateStatus.initial,
    this.comments = const [],
    this.meta,
    this.errorMessage,
    this.isPosting = false,
    this.isLoadingMore = false,
    this.currentId,
    this.currentType,
  });

  CommentState copyWith({
    CommentStateStatus? status,
    List<Comment>? comments,
    MetaData? meta,
    String? errorMessage,
    bool? isPosting,
    bool? isLoadingMore,
    String? currentId,
    CommentType? currentType,
  }) {
    return CommentState(
      status: status ?? this.status,
      comments: comments ?? this.comments,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
      isPosting: isPosting ?? this.isPosting,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentId: currentId ?? this.currentId,
      currentType: currentType ?? this.currentType,
    );
  }

  // Helper methods
  bool get hasComments => comments.isNotEmpty;
  bool get hasMore => meta?.hasMore ?? false;
  int get totalComments => meta?.total ?? 0;
  
  // Get string representation of current type
  String get typeString => currentType == CommentType.comic ? 'comic' : 'chapter';
}
