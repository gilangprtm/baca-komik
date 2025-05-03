import 'package:flutter/foundation.dart';
import '../../../data/models/bookmark_detail_model.dart';
import '../../../data/models/metadata_models.dart';

enum BookmarkStateStatus { initial, loading, success, error }

@immutable
class BookmarkState {
  final BookmarkStateStatus status;
  final List<BookmarkDetail> bookmarks;
  final MetaData? meta;
  final String? errorMessage;
  final bool hasMore;
  final bool isAddingBookmark;
  final bool isRemovingBookmark;

  const BookmarkState({
    this.status = BookmarkStateStatus.initial,
    this.bookmarks = const [],
    this.meta,
    this.errorMessage,
    this.hasMore = true,
    this.isAddingBookmark = false,
    this.isRemovingBookmark = false,
  });

  BookmarkState copyWith({
    BookmarkStateStatus? status,
    List<BookmarkDetail>? bookmarks,
    MetaData? meta,
    String? errorMessage,
    bool? hasMore,
    bool? isAddingBookmark,
    bool? isRemovingBookmark,
  }) {
    return BookmarkState(
      status: status ?? this.status,
      bookmarks: bookmarks ?? this.bookmarks,
      meta: meta ?? this.meta,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMore: hasMore ?? this.hasMore,
      isAddingBookmark: isAddingBookmark ?? this.isAddingBookmark,
      isRemovingBookmark: isRemovingBookmark ?? this.isRemovingBookmark,
    );
  }
}
