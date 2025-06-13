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
      logInfo('Adding bookmark for comic: ${bookmark.comicId}');

      final db = await _database;
      await db.insert(
        SqfliteService.tableBookmark,
        bookmark.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      logInfo('Bookmark added successfully for comic: ${bookmark.comicId}');
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
      logInfo('Removing bookmark for comic: $comicId');

      final db = await _database;
      final deletedRows = await db.delete(
        SqfliteService.tableBookmark,
        where: 'comic_id = ?',
        whereArgs: [comicId],
      );

      final success = deletedRows > 0;
      if (success) {
        logInfo('Bookmark removed successfully for comic: $comicId');
      } else {
        logInfo('No bookmark found to remove for comic: $comicId');
      }

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
      logDebug('Checking if comic is bookmarked: $comicId');

      final db = await _database;
      final result = await db.query(
        SqfliteService.tableBookmark,
        where: 'comic_id = ?',
        whereArgs: [comicId],
        limit: 1,
      );

      final isBookmarked = result.isNotEmpty;
      logDebug('Comic $comicId bookmark status: $isBookmarked');

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
      logInfo('Fetching bookmarks with limit: $limit, offset: $offset');

      final db = await _database;
      final result = await db.query(
        SqfliteService.tableBookmark,
        orderBy: 'created_at DESC',
        limit: limit,
        offset: offset,
      );

      final bookmarks = result.map((map) => BookmarkModel.fromMap(map)).toList();
      logInfo('Retrieved ${bookmarks.length} bookmarks');

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
      logDebug('Fetching bookmark for comic: $comicId');

      final db = await _database;
      final result = await db.query(
        SqfliteService.tableBookmark,
        where: 'comic_id = ?',
        whereArgs: [comicId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        final bookmark = BookmarkModel.fromMap(result.first);
        logDebug('Bookmark found for comic: $comicId');
        return bookmark;
      }

      logDebug('No bookmark found for comic: $comicId');
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
      logDebug('Fetching bookmarks count');

      final db = await _database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${SqfliteService.tableBookmark}'
      );

      final count = result.first['count'] as int;
      logDebug('Total bookmarks count: $count');

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
      logInfo('Clearing all bookmarks');

      final db = await _database;
      await db.delete(SqfliteService.tableBookmark);

      logInfo('All bookmarks cleared successfully');
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
      logInfo('Toggling bookmark for comic: ${bookmark.comicId}');

      final isCurrentlyBookmarked = await isBookmarked(bookmark.comicId);

      if (isCurrentlyBookmarked) {
        await removeBookmark(bookmark.comicId);
        logInfo('Bookmark removed for comic: ${bookmark.comicId}');
        return false;
      } else {
        await addBookmark(bookmark);
        logInfo('Bookmark added for comic: ${bookmark.comicId}');
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
