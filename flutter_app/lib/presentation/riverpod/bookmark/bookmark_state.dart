import 'package:flutter/foundation.dart';
import '../../../data/models/local/bookmark_model.dart';

/// Status enum for bookmark operations
enum BookmarkStatus {
  initial,
  loading,
  success,
  error,
}

/// State class for bookmark management
@immutable
class BookmarkState {
  final BookmarkStatus status;
  final List<BookmarkModel> bookmarks;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final int currentPage;
  final int totalCount;

  const BookmarkState({
    this.status = BookmarkStatus.initial,
    this.bookmarks = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.currentPage = 1,
    this.totalCount = 0,
  });

  /// Create a copy of BookmarkState with updated fields
  BookmarkState copyWith({
    BookmarkStatus? status,
    List<BookmarkModel>? bookmarks,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    int? currentPage,
    int? totalCount,
  }) {
    return BookmarkState(
      status: status ?? this.status,
      bookmarks: bookmarks ?? this.bookmarks,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  /// Reset state to initial
  BookmarkState get initialState => const BookmarkState();

  /// Helper methods
  bool get isEmpty => bookmarks.isEmpty;
  bool get isNotEmpty => bookmarks.isNotEmpty;
  bool get isLoading => status == BookmarkStatus.loading;
  bool get isSuccess => status == BookmarkStatus.success;
  bool get isError => status == BookmarkStatus.error;
  bool get canLoadMore => hasMore && !isLoadingMore && isSuccess;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BookmarkState &&
        other.status == status &&
        listEquals(other.bookmarks, bookmarks) &&
        other.isLoadingMore == isLoadingMore &&
        other.hasMore == hasMore &&
        other.errorMessage == errorMessage &&
        other.currentPage == currentPage &&
        other.totalCount == totalCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      bookmarks,
      isLoadingMore,
      hasMore,
      errorMessage,
      currentPage,
      totalCount,
    );
  }

  @override
  String toString() {
    return 'BookmarkState('
        'status: $status, '
        'bookmarks: ${bookmarks.length}, '
        'isLoadingMore: $isLoadingMore, '
        'hasMore: $hasMore, '
        'errorMessage: $errorMessage, '
        'currentPage: $currentPage, '
        'totalCount: $totalCount'
        ')';
  }
}
