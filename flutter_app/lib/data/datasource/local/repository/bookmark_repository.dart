import 'package:sqflite/sqflite.dart';

import '../../../../core/base/base_network.dart';
import '../../../models/local/bookmark_model.dart';
import '../db/sqflite_service.dart';

/// Bookmark Repository - Handles bookmark data operations
/// Follows the same pattern as network repositories
class BookmarkRepository extends BaseRepository {
  final SqfliteService _sqfliteService = SqfliteService.instance;

  /// Get database instance
  Future<Database> get _database => _sqfliteService.database;

  /// Add bookmark
  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      final db = await _database;
      await db.insert(
        SqfliteService.tableBookmark,
        bookmark.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      logError(
        'Failed to add bookmark for comic: ${bookmark.comicId}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Remove bookmark by comic ID
  Future<bool> removeBookmark(String comicId) async {
    try {
      final db = await _database;
      final deletedRows = await db.delete(
        SqfliteService.tableBookmark,
        where: 'comic_id = ?',
        whereArgs: [comicId],
      );

      final success = deletedRows > 0;
      return success;
    } catch (e, stackTrace) {
      logError(
        'Failed to remove bookmark for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if comic is bookmarked
  Future<bool> isBookmarked(String comicId) async {
    try {
      final db = await _database;
      final result = await db.query(
        SqfliteService.tableBookmark,
        where: 'comic_id = ?',
        whereArgs: [comicId],
        limit: 1,
      );

      final isBookmarked = result.isNotEmpty;
      return isBookmarked;
    } catch (e, stackTrace) {
      logError(
        'Failed to check bookmark status for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get all bookmarks with pagination
  Future<List<BookmarkModel>> getAllBookmarks({
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await _database;
      final result = await db.query(
        SqfliteService.tableBookmark,
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );

      final bookmarks =
          result.map((map) => BookmarkModel.fromMap(map)).toList();

      return bookmarks;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch bookmarks',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get bookmark by comic ID
  Future<BookmarkModel?> getBookmark(String comicId) async {
    try {
      final db = await _database;
      final result = await db.query(
        SqfliteService.tableBookmark,
        where: 'comic_id = ?',
        whereArgs: [comicId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final bookmark = BookmarkModel.fromMap(result.first);
        return bookmark;
      }

      return null;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch bookmark for comic: $comicId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get bookmarks count
  Future<int> getBookmarksCount() async {
    try {
      final db = await _database;
      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM ${SqfliteService.tableBookmark}');

      final count = result.first['count'] as int;

      return count;
    } catch (e, stackTrace) {
      logError(
        'Failed to fetch bookmarks count',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Clear all bookmarks
  Future<void> clearAllBookmarks() async {
    try {
      final db = await _database;
      await db.delete(SqfliteService.tableBookmark);
    } catch (e, stackTrace) {
      logError(
        'Failed to clear all bookmarks',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Toggle bookmark (add if not exists, remove if exists)
  Future<bool> toggleBookmark(BookmarkModel bookmark) async {
    try {
      final isCurrentlyBookmarked = await isBookmarked(bookmark.comicId);

      if (isCurrentlyBookmarked) {
        await removeBookmark(bookmark.comicId);
        return false;
      } else {
        await addBookmark(bookmark);
        return true;
      }
    } catch (e, stackTrace) {
      logError(
        'Failed to toggle bookmark for comic: ${bookmark.comicId}',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
