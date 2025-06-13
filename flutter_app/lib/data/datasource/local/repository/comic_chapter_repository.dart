import 'package:sqflite/sqflite.dart';

import '../../../../core/base/base_network.dart';
import '../../../models/local/comic_chapter_model.dart';
import '../db/sqflite_service.dart';

/// Comic Chapter Repository - Handles read chapters data operations
/// Follows the same pattern as network repositories
class ComicChapterRepository extends BaseRepository {
  final SqfliteService _sqfliteService = SqfliteService.instance;

  /// Get database instance
  Future<Database> get _database => _sqfliteService.database;

  /// Mark chapter as read
  Future<void> markChapterRead(ComicChapterModel comicChapter) async {
    try {
      logInfo(
          'Marking chapter as read: ${comicChapter.comicId} - ${comicChapter.chapter}');

      final db = await _database;
      await db.insert(
        SqfliteService.tableComicChapter,
        comicChapter.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      logInfo(
          'Chapter marked as read successfully: ${comicChapter.comicId} - ${comicChapter.chapter}');
    } catch (e, stackTrace) {
      logError(
        'Failed to mark chapter as read: ${comicChapter.comicId} - ${comicChapter.chapter}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get read chapters for a comic
  Future<List<ComicChapterModel>> getReadChapters(String comicId) async {
    try {
      logInfo('Fetching read chapters for comic: $comicId');

      final db = await _database;
      final result = await db.query(
        SqfliteService.tableComicChapter,
        where: 'comic_id = ?',
        whereArgs: [comicId],
        orderBy: 'read_at DESC',
      );

      final chapters =
          result.map((map) => ComicChapterModel.fromMap(map)).toList();
      logInfo('Retrieved ${chapters.length} read chapters for comic: $comicId');

      return chapters;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch read chapters for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if chapter is read by chapter ID (more reliable)
  Future<bool> isChapterReadById(String comicId, String chapterId) async {
    try {
      final db = await _database;
      final result = await db.query(
        SqfliteService.tableComicChapter,
        where: 'comic_id = ? AND chapter_id = ?',
        whereArgs: [comicId, chapterId],
        limit: 1,
      );

      final isRead = result.isNotEmpty;

      return isRead;
    } catch (e, stackTrace) {
      logError(
        'Failed to check if chapter is read by ID: $comicId - $chapterId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if chapter is read by chapter title (legacy method)
  Future<bool> isChapterRead(String comicId, String chapter) async {
    try {
      logDebug('Checking if chapter is read: $comicId - $chapter');

      final db = await _database;
      final result = await db.query(
        SqfliteService.tableComicChapter,
        where: 'comic_id = ? AND chapter = ?',
        whereArgs: [comicId, chapter],
        limit: 1,
      );

      final isRead = result.isNotEmpty;
      logDebug('Chapter $comicId - $chapter read status: $isRead');

      return isRead;
    } catch (e, stackTrace) {
      logError(
        'Failed to check if chapter is read: $comicId - $chapter',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get read chapter IDs for a comic (for quick lookup)
  Future<Set<String>> getReadChapterIds(String comicId) async {
    try {
      logDebug('Fetching read chapter IDs for comic: $comicId');

      final db = await _database;
      final result = await db.query(
        SqfliteService.tableComicChapter,
        columns: ['chapter'],
        where: 'comic_id = ?',
        whereArgs: [comicId],
      );

      final chapterIds = result.map((row) => row['chapter'] as String).toSet();
      logDebug(
          'Retrieved ${chapterIds.length} read chapter IDs for comic: $comicId');

      return chapterIds;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch read chapter IDs for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Remove all read chapters for a comic
  Future<bool> removeComicChapters(String comicId) async {
    try {
      logInfo('Removing all chapters for comic: $comicId');

      final db = await _database;
      final deletedRows = await db.delete(
        SqfliteService.tableComicChapter,
        where: 'comic_id = ?',
        whereArgs: [comicId],
      );

      final success = deletedRows > 0;
      if (success) {
        logInfo('All chapters removed successfully for comic: $comicId');
      } else {
        logInfo('No chapters found to remove for comic: $comicId');
      }

      return success;
    } catch (e, stackTrace) {
      logError(
        'Failed to remove chapters for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Remove specific chapter
  Future<bool> removeChapter(String comicId, String chapter) async {
    try {
      logInfo('Removing chapter: $comicId - $chapter');

      final db = await _database;
      final deletedRows = await db.delete(
        SqfliteService.tableComicChapter,
        where: 'comic_id = ? AND chapter = ?',
        whereArgs: [comicId, chapter],
      );

      final success = deletedRows > 0;
      if (success) {
        logInfo('Chapter removed successfully: $comicId - $chapter');
      } else {
        logInfo('No chapter found to remove: $comicId - $chapter');
      }

      return success;
    } catch (e, stackTrace) {
      logError(
        'Failed to remove chapter: $comicId - $chapter',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get read chapters count for a comic
  Future<int> getReadChaptersCount(String comicId) async {
    try {
      logDebug('Fetching read chapters count for comic: $comicId');

      final db = await _database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${SqfliteService.tableComicChapter} WHERE comic_id = ?',
        [comicId],
      );

      final count = result.first['count'] as int;
      logDebug('Read chapters count for comic $comicId: $count');

      return count;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch read chapters count for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get total read chapters count across all comics
  Future<int> getTotalReadChaptersCount() async {
    try {
      logDebug('Fetching total read chapters count');

      final db = await _database;
      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM ${SqfliteService.tableComicChapter}');

      final count = result.first['count'] as int;
      logDebug('Total read chapters count: $count');

      return count;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch total read chapters count',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Clear all read chapters
  Future<void> clearAllChapters() async {
    try {
      logInfo('Clearing all read chapters');

      final db = await _database;
      await db.delete(SqfliteService.tableComicChapter);

      logInfo('All read chapters cleared successfully');
    } catch (e, stackTrace) {
      logError(
        'Failed to clear all read chapters',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Mark chapter as completed
  Future<void> markChapterCompleted(String comicId, String chapter) async {
    try {
      logInfo('Marking chapter as completed: $comicId - $chapter');

      final db = await _database;
      await db.update(
        SqfliteService.tableComicChapter,
        {
          'is_completed': 1,
          'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        },
        where: 'comic_id = ? AND chapter = ?',
        whereArgs: [comicId, chapter],
      );

      logInfo('Chapter marked as completed: $comicId - $chapter');
    } catch (e, stackTrace) {
      logError(
        'Failed to mark chapter as completed: $comicId - $chapter',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get completed chapters for a comic
  Future<List<ComicChapterModel>> getCompletedChapters(String comicId) async {
    try {
      logInfo('Fetching completed chapters for comic: $comicId');

      final db = await _database;
      final result = await db.query(
        SqfliteService.tableComicChapter,
        where: 'comic_id = ? AND is_completed = 1',
        whereArgs: [comicId],
        orderBy: 'read_at DESC',
      );

      final chapters =
          result.map((map) => ComicChapterModel.fromMap(map)).toList();
      logInfo(
          'Retrieved ${chapters.length} completed chapters for comic: $comicId');

      return chapters;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch completed chapters for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
