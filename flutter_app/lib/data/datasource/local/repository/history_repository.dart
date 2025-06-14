import 'package:sqflite/sqflite.dart';

import '../../../../core/base/base_network.dart';
import '../../../models/local/history_model.dart';
import '../db/sqflite_service.dart';

/// History Repository - Handles reading history data operations
/// Follows the same pattern as network repositories
class HistoryRepository extends BaseRepository {
  final SqfliteService _sqfliteService = SqfliteService.instance;

  /// Get database instance
  Future<Database> get _database => _sqfliteService.database;

  /// Add or update reading history
  Future<void> updateHistory(HistoryModel history) async {
    try {
      final db = await _database;
      await db.insert(
        SqfliteService.tableHistory,
        history.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      logError(
        'Failed to update history for comic: ${history.comicId}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get reading history with pagination
  Future<List<HistoryModel>> getHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await _database;
      final result = await db.query(
        SqfliteService.tableHistory,
        orderBy: 'read_at DESC',
        limit: limit,
        offset: offset,
      );

      final history = result.map((map) => HistoryModel.fromMap(map)).toList();

      return history;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch history',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get history for specific comic
  Future<HistoryModel?> getComicHistory(String comicId) async {
    try {
      final db = await _database;
      final result = await db.query(
        SqfliteService.tableHistory,
        where: 'comic_id = ?',
        whereArgs: [comicId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final history = HistoryModel.fromMap(result.first);
        return history;
      }

      return null;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch history for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Remove history for specific comic
  Future<bool> removeHistory(String comicId) async {
    try {
      final db = await _database;
      final deletedRows = await db.delete(
        SqfliteService.tableHistory,
        where: 'comic_id = ?',
        whereArgs: [comicId],
      );

      final success = deletedRows > 0;

      return success;
    } catch (e, stackTrace) {
      logError(
        'Failed to remove history for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get history count
  Future<int> getHistoryCount() async {
    try {
      final db = await _database;
      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM ${SqfliteService.tableHistory}');

      final count = result.first['count'] as int;

      return count;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch history count',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    try {
      final db = await _database;
      await db.delete(SqfliteService.tableHistory);
    } catch (e, stackTrace) {
      logError(
        'Failed to clear all history',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Update reading progress for a comic
  Future<void> updateProgress({
    required String comicId,
    required int pagePosition,
    required int totalPages,
    bool? isCompleted,
  }) async {
    try {
      final existingHistory = await getComicHistory(comicId);
      if (existingHistory != null) {
        final updatedHistory = existingHistory.updateProgress(
          pagePosition: pagePosition,
          totalPages: totalPages,
          isCompleted: isCompleted,
        );
        await updateHistory(updatedHistory);
      } else {
        throw Exception('No history found for comic: $comicId');
      }
    } catch (e, stackTrace) {
      logError(
        'Failed to update progress for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Mark chapter as completed
  Future<void> markChapterCompleted(String comicId) async {
    try {
      final existingHistory = await getComicHistory(comicId);
      if (existingHistory != null) {
        final completedHistory = existingHistory.markCompleted();
        await updateHistory(completedHistory);
      } else {
        throw Exception('No history found for comic: $comicId');
      }
    } catch (e, stackTrace) {
      logError(
        'Failed to mark chapter as completed for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get recently read comics (last 10)
  Future<List<HistoryModel>> getRecentlyRead({int limit = 10}) async {
    try {
      return await getHistory(limit: limit, offset: 0);
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch recently read comics',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
