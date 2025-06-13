import '../../../../core/base/base_network.dart';
import '../../../models/local/history_model.dart';
import '../repository/history_repository.dart';

/// History Service - High-level reading history operations with performance monitoring
/// Follows the same pattern as network services
class HistoryService extends BaseService {
  final HistoryRepository _repository = HistoryRepository();

  /// Add or update reading history
  Future<void> updateHistory({
    required String comicId,
    required String chapterId,
    required String chapter,
    required String urlCover,
    required String title,
    required String nation,
    int pagePosition = 0,
    int totalPages = 0,
    bool isCompleted = false,
  }) async {
    return await performanceAsync(
      operationName: 'updateHistory',
      function: () async {
        final history = HistoryModel.create(
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

        await _repository.updateHistory(history);
      },
    );
  }

  /// Get reading history with pagination
  Future<List<HistoryModel>> getHistory({
    int? limit,
    int? offset,
  }) async {
    return await performanceAsync(
      operationName: 'getHistory',
      function: () => _repository.getHistory(
        limit: limit,
        offset: offset,
      ),
    );
  }

  /// Get history for specific comic
  Future<HistoryModel?> getComicHistory(String comicId) async {
    return await performanceAsync(
      operationName: 'getComicHistory',
      function: () => _repository.getComicHistory(comicId),
    );
  }

  /// Remove history for specific comic
  Future<bool> removeHistory(String comicId) async {
    return await performanceAsync(
      operationName: 'removeHistory',
      function: () => _repository.removeHistory(comicId),
    );
  }

  /// Get history count
  Future<int> getHistoryCount() async {
    return await performanceAsync(
      operationName: 'getHistoryCount',
      function: () => _repository.getHistoryCount(),
    );
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    return await performanceAsync(
      operationName: 'clearAllHistory',
      function: () => _repository.clearAllHistory(),
    );
  }

  /// Update reading progress for a comic
  Future<void> updateProgress({
    required String comicId,
    required int pagePosition,
    required int totalPages,
    bool? isCompleted,
  }) async {
    return await performanceAsync(
      operationName: 'updateProgress',
      function: () => _repository.updateProgress(
        comicId: comicId,
        pagePosition: pagePosition,
        totalPages: totalPages,
        isCompleted: isCompleted,
      ),
    );
  }

  /// Mark chapter as completed
  Future<void> markChapterCompleted(String comicId) async {
    return await performanceAsync(
      operationName: 'markChapterCompleted',
      function: () => _repository.markChapterCompleted(comicId),
    );
  }

  /// Get recently read comics
  Future<List<HistoryModel>> getRecentlyRead({int limit = 10}) async {
    return await performanceAsync(
      operationName: 'getRecentlyRead',
      function: () => _repository.getRecentlyRead(limit: limit),
    );
  }

  /// Get paginated history for UI
  Future<List<HistoryModel>> getHistoryPage({
    required int page,
    int pageSize = 20,
  }) async {
    return await performanceAsync(
      operationName: 'getHistoryPage',
      function: () => _repository.getHistory(
        limit: pageSize,
        offset: (page - 1) * pageSize,
      ),
    );
  }

  /// Search history by title
  Future<List<HistoryModel>> searchHistory(String query) async {
    return await performanceAsync(
      operationName: 'searchHistory',
      function: () async {
        final allHistory = await _repository.getHistory();
        
        if (query.isEmpty) return allHistory;
        
        final lowercaseQuery = query.toLowerCase();
        return allHistory.where((history) =>
          history.title.toLowerCase().contains(lowercaseQuery)
        ).toList();
      },
    );
  }

  /// Get history by nation/region
  Future<List<HistoryModel>> getHistoryByNation(String nation) async {
    return await performanceAsync(
      operationName: 'getHistoryByNation',
      function: () async {
        final allHistory = await _repository.getHistory();
        
        return allHistory.where((history) =>
          history.nation.toLowerCase() == nation.toLowerCase()
        ).toList();
      },
    );
  }

  /// Get incomplete readings (not finished chapters)
  Future<List<HistoryModel>> getIncompleteReadings() async {
    return await performanceAsync(
      operationName: 'getIncompleteReadings',
      function: () async {
        final allHistory = await _repository.getHistory();
        
        return allHistory.where((history) => !history.isCompleted).toList();
      },
    );
  }

  /// Get completed readings
  Future<List<HistoryModel>> getCompletedReadings() async {
    return await performanceAsync(
      operationName: 'getCompletedReadings',
      function: () async {
        final allHistory = await _repository.getHistory();
        
        return allHistory.where((history) => history.isCompleted).toList();
      },
    );
  }

  /// Get last read chapter for a comic
  Future<String?> getLastReadChapter(String comicId) async {
    return await performanceAsync(
      operationName: 'getLastReadChapter',
      function: () async {
        final history = await _repository.getComicHistory(comicId);
        return history?.chapter;
      },
    );
  }

  /// Check if comic has reading history
  Future<bool> hasReadingHistory(String comicId) async {
    return await performanceAsync(
      operationName: 'hasReadingHistory',
      function: () async {
        final history = await _repository.getComicHistory(comicId);
        return history != null;
      },
    );
  }
}
