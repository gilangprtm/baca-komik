import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/local/service/local_services.dart';
import '../../../data/models/local/history_model.dart';
import 'history_state.dart';

class HistoryNotifier extends BaseStateNotifier<HistoryState> {
  final HistoryService _historyService = HistoryService();

  HistoryNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Auto-load history when notifier is initialized
    loadHistory();
  }

  /// Load history from local database
  Future<void> loadHistory({int page = 1, int pageSize = 20}) async {
    runAsync('loadHistory', () async {
      try {
        // Set loading state
        if (page == 1) {
          state = state.copyWith(
            status: HistoryStatus.loading,
            errorMessage: null,
          );
        } else {
          state = state.copyWith(isLoadingMore: true);
        }

        // Get history from local database
        final history = await _historyService.getHistoryPage(
          page: page,
          pageSize: pageSize,
        );

        // Get total count for pagination
        final totalCount = await _historyService.getHistoryCount();

        // Calculate if there are more pages
        final hasMore = (page * pageSize) < totalCount;

        if (page == 1) {
          // First page - replace existing history
          state = state.copyWith(
            status: HistoryStatus.success,
            history: history,
            currentPage: page,
            totalCount: totalCount,
            hasMore: hasMore,
            isLoadingMore: false,
            errorMessage: null,
          );
        } else {
          // Subsequent pages - append to existing history
          final combinedHistory = [...state.history, ...history];
          state = state.copyWith(
            history: combinedHistory,
            currentPage: page,
            totalCount: totalCount,
            hasMore: hasMore,
            isLoadingMore: false,
          );
        }

        logger.i('Loaded ${history.length} history items (page $page)');
      } catch (e, stackTrace) {
        logger.e('Error loading history', error: e, stackTrace: stackTrace);

        if (page == 1) {
          state = state.copyWith(
            status: HistoryStatus.error,
            errorMessage: 'Failed to load history: ${e.toString()}',
            isLoadingMore: false,
          );
        } else {
          state = state.copyWith(
            isLoadingMore: false,
            errorMessage: 'Failed to load more history: ${e.toString()}',
          );
        }
      }
    });
  }

  /// Refresh history (reload from first page)
  Future<void> refreshHistory() async {
    await loadHistory(page: 1);
  }

  /// Load more history for pagination
  Future<void> loadMoreHistory() async {
    if (!state.canLoadMore) return;

    final nextPage = state.currentPage + 1;
    await loadHistory(page: nextPage);
  }

  /// Update reading history
  Future<void> updateHistory({
    required String comicId,
    required String chapterId,
    required String chapter,
    required String urlCover,
    required String title,
    required String nation,
    required int pagePosition,
    required int totalPages,
    required bool isCompleted,
  }) async {
    runAsync('updateHistory', () async {
      try {
        await _historyService.updateHistory(
          comicId: comicId,
          chapterId: chapterId,
          chapter: chapter,
          urlCover: urlCover,
          title: title,
          nation: nation,
          pagePosition: pagePosition,
          totalPages: totalPages,
          isCompleted: isCompleted,
        );

        // Refresh history to get updated list
        await refreshHistory();

        logger.i('History updated: $title - $chapter');
      } catch (e, stackTrace) {
        logger.e('Error updating history', error: e, stackTrace: stackTrace);
      }
    });
  }

  /// Remove specific history item
  Future<void> removeHistoryItem(String comicId) async {
    runAsync('removeHistoryItem', () async {
      try {
        await _historyService.removeHistory(comicId);

        // Remove from current state without full refresh for better UX
        final updatedHistory = state.history
            .where((historyItem) => historyItem.comicId != comicId)
            .toList();

        state = state.copyWith(
          history: updatedHistory,
          totalCount: state.totalCount - 1,
        );

        logger.i('History item removed: $comicId');
      } catch (e, stackTrace) {
        logger.e('Error removing history item',
            error: e, stackTrace: stackTrace);
        state = state.copyWith(
          status: HistoryStatus.error,
          errorMessage: 'Failed to remove history item: ${e.toString()}',
        );
      }
    });
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    runAsync('clearAllHistory', () async {
      try {
        await _historyService.clearAllHistory();

        state = state.copyWith(
          history: [],
          totalCount: 0,
          currentPage: 1,
          hasMore: false,
        );

        logger.i('All history cleared');
      } catch (e, stackTrace) {
        logger.e('Error clearing history', error: e, stackTrace: stackTrace);
        state = state.copyWith(
          status: HistoryStatus.error,
          errorMessage: 'Failed to clear history: ${e.toString()}',
        );
      }
    });
  }

  /// Get history for specific comic
  Future<HistoryModel?> getComicHistory(String comicId) async {
    try {
      final historyItem = await _historyService.getComicHistory(comicId);
      logger.i('Got history for comic $comicId: ${historyItem?.chapter}');
      return historyItem;
    } catch (e, stackTrace) {
      logger.e('Error getting comic history', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// Mark chapter as completed in history
  Future<void> markChapterCompleted(String comicId) async {
    try {
      await _historyService.markChapterCompleted(comicId);

      // Refresh history to get updated completion status
      await refreshHistory();

      logger.i('Chapter marked as completed in history: $comicId');
    } catch (e, stackTrace) {
      logger.e('Error marking chapter as completed',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Update reading progress
  Future<void> updateProgress({
    required String comicId,
    required int pagePosition,
    required int totalPages,
    required bool isCompleted,
  }) async {
    try {
      await _historyService.updateProgress(
        comicId: comicId,
        pagePosition: pagePosition,
        totalPages: totalPages,
        isCompleted: isCompleted,
      );

      logger.d(
          'Progress updated: $comicId - Page ${pagePosition + 1}/$totalPages');
    } catch (e, stackTrace) {
      logger.e('Error updating progress', error: e, stackTrace: stackTrace);
    }
  }

  /// Get history count
  int get historyCount => state.totalCount;

  /// Check if history list is empty
  bool get isEmpty => state.isEmpty;

  /// Check if history list is not empty
  bool get isNotEmpty => state.isNotEmpty;
}
