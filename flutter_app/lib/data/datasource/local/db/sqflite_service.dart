import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../../../core/services/logger_service.dart';

/// SQLite Service - Core database operations
/// Similar to DioService but for local SQLite database
class SqfliteService {
  static final SqfliteService _instance = SqfliteService._internal();
  static SqfliteService get instance => _instance;

  static Database? _database;
  final LoggerService _logger = LoggerService.instance;

  // Database configuration
  static const String _databaseName = 'baca_komik.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableBookmark = 'bookmark';
  static const String tableHistory = 'history';
  static const String tableComicChapter = 'comic_chapter';

  SqfliteService._internal();

  /// Get database instance with lazy initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database with proper configuration
  Future<Database> _initDatabase() async {
    try {
      _logger.i('Initializing SQLite database', tag: 'SqfliteService');

      final documentsDirectory = await getDatabasesPath();
      final path = join(documentsDirectory, _databaseName);

      _logger.d('Database path: $path', tag: 'SqfliteService');

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
        onConfigure: _onConfigure,
        onOpen: _onOpen,
      );
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to initialize database',
        error: e,
        stackTrace: stackTrace,
        tag: 'SqfliteService',
      );
      rethrow;
    }
  }

  /// Configure database settings before opening
  Future<void> _onConfigure(Database db) async {
    _logger.d('Configuring database', tag: 'SqfliteService');

    try {
      // Enable foreign key constraints (this is usually safe)
      await db.execute('PRAGMA foreign_keys = ON');
      _logger.d('Foreign keys enabled', tag: 'SqfliteService');
    } catch (e) {
      _logger.w('Could not enable foreign keys: $e', tag: 'SqfliteService');
    }

    // Skip other PRAGMA commands that might cause issues on some Android versions
    // WAL mode and other optimizations will be handled by SQLite defaults
  }

  /// Called when database is opened
  Future<void> _onOpen(Database db) async {
    _logger.i('Database opened successfully', tag: 'SqfliteService');

    try {
      // Verify foreign key constraints are enabled (optional check)
      final result = await db.rawQuery('PRAGMA foreign_keys');
      if (result.isNotEmpty && result.first['foreign_keys'] != null) {
        _logger.d('Foreign keys status: ${result.first['foreign_keys']}',
            tag: 'SqfliteService');
      }
    } catch (e) {
      _logger.d('Could not check foreign keys status: $e',
          tag: 'SqfliteService');
    }
  }

  /// Create database tables for the first time
  Future<void> _onCreate(Database db, int version) async {
    _logger.i('Creating database tables (version $version)',
        tag: 'SqfliteService');

    try {
      // Create bookmark table
      await _createBookmarkTable(db);

      // Create history table
      await _createHistoryTable(db);

      // Create comic_chapter table
      await _createComicChapterTable(db);

      // Create indexes for better performance
      await _createIndexes(db);

      _logger.i('All database tables created successfully',
          tag: 'SqfliteService');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to create database tables',
        error: e,
        stackTrace: stackTrace,
        tag: 'SqfliteService',
      );
      rethrow;
    }
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    _logger.i(
      'Upgrading database from version $oldVersion to $newVersion',
      tag: 'SqfliteService',
    );

    try {
      // Run migrations based on version differences
      for (int version = oldVersion + 1; version <= newVersion; version++) {
        await _runMigration(db, version);
      }

      _logger.i('Database upgrade completed successfully',
          tag: 'SqfliteService');
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to upgrade database',
        error: e,
        stackTrace: stackTrace,
        tag: 'SqfliteService',
      );
      rethrow;
    }
  }

  /// Handle database downgrades (usually not recommended)
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    _logger.w(
      'Downgrading database from version $oldVersion to $newVersion',
      tag: 'SqfliteService',
    );

    // For safety, we'll recreate the database on downgrade
    await _recreateDatabase(db);
  }

  /// Run specific migration for a version
  Future<void> _runMigration(Database db, int version) async {
    _logger.i('Running migration for version $version', tag: 'SqfliteService');

    switch (version) {
      case 2:
        // Example: Add new column to bookmark table
        // await db.execute('ALTER TABLE $tableBookmark ADD COLUMN new_column TEXT');
        break;
      case 3:
        // Example: Create new table
        // await _createNewTable(db);
        break;
      default:
        _logger.w('No migration defined for version $version',
            tag: 'SqfliteService');
    }
  }

  /// Create bookmark table
  Future<void> _createBookmarkTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableBookmark (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        comic_id TEXT NOT NULL UNIQUE,
        url_cover TEXT NOT NULL,
        title TEXT NOT NULL,
        nation TEXT NOT NULL,
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      )
    ''');

    _logger.d('Bookmark table created', tag: 'SqfliteService');
  }

  /// Create history table
  Future<void> _createHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableHistory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        comic_id TEXT NOT NULL UNIQUE,
        chapter_id TEXT NOT NULL,
        chapter TEXT NOT NULL,
        url_cover TEXT NOT NULL,
        title TEXT NOT NULL,
        nation TEXT NOT NULL,
        page_position INTEGER NOT NULL DEFAULT 0,
        total_pages INTEGER NOT NULL DEFAULT 0,
        is_completed INTEGER NOT NULL DEFAULT 0,
        read_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
      )
    ''');

    _logger.d('History table created', tag: 'SqfliteService');
  }

  /// Create comic_chapter table
  Future<void> _createComicChapterTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableComicChapter (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        comic_id TEXT NOT NULL,
        chapter TEXT NOT NULL,
        chapter_id TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        read_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
        UNIQUE(comic_id, chapter)
      )
    ''');

    _logger.d('Comic chapter table created', tag: 'SqfliteService');
  }

  /// Create database indexes for better performance
  Future<void> _createIndexes(Database db) async {
    // Bookmark indexes
    await db.execute(
        'CREATE INDEX idx_bookmark_comic_id ON $tableBookmark(comic_id)');
    await db.execute(
        'CREATE INDEX idx_bookmark_created_at ON $tableBookmark(created_at DESC)');

    // History indexes
    await db.execute(
        'CREATE INDEX idx_history_comic_id ON $tableHistory(comic_id)');
    await db.execute(
        'CREATE INDEX idx_history_read_at ON $tableHistory(read_at DESC)');

    // Comic chapter indexes
    await db.execute(
        'CREATE INDEX idx_comic_chapter_comic_id ON $tableComicChapter(comic_id)');
    await db.execute(
        'CREATE INDEX idx_comic_chapter_read_at ON $tableComicChapter(read_at DESC)');
    await db.execute(
        'CREATE INDEX idx_comic_chapter_composite ON $tableComicChapter(comic_id, chapter)');

    _logger.d('Database indexes created', tag: 'SqfliteService');
  }

  /// Recreate database (used for downgrades or corruption recovery)
  Future<void> _recreateDatabase(Database db) async {
    _logger.w('Recreating database', tag: 'SqfliteService');

    // Drop all tables
    await db.execute('DROP TABLE IF EXISTS $tableBookmark');
    await db.execute('DROP TABLE IF EXISTS $tableHistory');
    await db.execute('DROP TABLE IF EXISTS $tableComicChapter');

    // Recreate tables
    await _onCreate(db, _databaseVersion);
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _logger.i('Database connection closed', tag: 'SqfliteService');
    }
  }

  /// Delete database file (for testing or reset purposes)
  Future<void> deleteDatabase() async {
    try {
      final documentsDirectory = await getDatabasesPath();
      final path = join(documentsDirectory, _databaseName);

      await close();

      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        _logger.i('Database file deleted', tag: 'SqfliteService');
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to delete database',
        error: e,
        stackTrace: stackTrace,
        tag: 'SqfliteService',
      );
      rethrow;
    }
  }

  /// Get database information for debugging
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;

      final version = await db.getVersion();
      final path = db.path;

      // Get table information
      final tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

      return {
        'version': version,
        'path': path,
        'tables': tables.map((table) => table['name']).toList(),
      };
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get database info',
        error: e,
        stackTrace: stackTrace,
        tag: 'SqfliteService',
      );
      rethrow;
    }
  }
}
