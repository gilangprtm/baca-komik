import 'package:flutter/foundation.dart';
import '../../../data/models/local/history_model.dart';

/// Status enum for history operations
enum HistoryStatus {
  initial,
  loading,
  success,
  error,
}

/// State class for history management
@immutable
class HistoryState {
  final HistoryStatus status;
  final List<HistoryModel> history;
  final bool isLoadingMore;
  final bool hasMore;
  final String? errorMessage;
  final int currentPage;
  final int totalCount;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.history = const [],
    this.isLoadingMore = false,
    this.hasMore = true,
    this.errorMessage,
    this.currentPage = 1,
    this.totalCount = 0,
  });

  /// Create a copy of HistoryState with updated fields
  HistoryState copyWith({
    HistoryStatus? status,
    List<HistoryModel>? history,
    bool? isLoadingMore,
    bool? hasMore,
    String? errorMessage,
    int? currentPage,
    int? totalCount,
  }) {
    return HistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  /// Reset state to initial
  HistoryState get initialState => const HistoryState();

  /// Helper methods
  bool get isEmpty => history.isEmpty;
  bool get isNotEmpty => history.isNotEmpty;
  bool get isLoading => status == HistoryStatus.loading;
  bool get isSuccess => status == HistoryStatus.success;
  bool get isError => status == HistoryStatus.error;
  bool get canLoadMore => hasMore && !isLoadingMore && isSuccess;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is HistoryState &&
        other.status == status &&
        listEquals(other.history, history) &&
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
      history,
      isLoadingMore,
      hasMore,
      errorMessage,
      currentPage,
      totalCount,
    );
  }

  @override
  String toString() {
    return 'HistoryState('
        'status: $status, '
        'history: ${history.length}, '
        'isLoadingMore: $isLoadingMore, '
        'hasMore: $hasMore, '
        'errorMessage: $errorMessage, '
        'currentPage: $currentPage, '
        'totalCount: $totalCount'
        ')';
  }
}
