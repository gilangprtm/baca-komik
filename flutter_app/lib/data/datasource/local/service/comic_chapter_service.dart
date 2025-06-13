import '../../../../core/base/base_network.dart';
import '../../../models/local/comic_chapter_model.dart';
import '../repository/comic_chapter_repository.dart';

/// Comic Chapter Service - High-level read chapters operations with performance monitoring
/// Follows the same pattern as network services
class ComicChapterService extends BaseService {
  final ComicChapterRepository _repository = ComicChapterRepository();

  /// Mark chapter as read by chapter ID (more reliable)
  Future<void> markChapterReadById({
    required String comicId,
    required String chapterId,
    bool isCompleted = true,
  }) async {
    return await performanceAsync(
      operationName: 'markChapterReadById',
      function: () async {
        final comicChapter = ComicChapterModel.create(
          comicId: comicId,
          chapter: chapterId, // Use chapter_id as chapter identifier
          chapterId: chapterId,
          isCompleted: isCompleted,
        );

        await _repository.markChapterRead(comicChapter);
      },
    );
  }

  /// Mark chapter as read by title (legacy method)
  Future<void> markChapterRead({
    required String comicId,
    required String chapter,
    required String chapterId,
    bool isCompleted = true,
  }) async {
    return await performanceAsync(
      operationName: 'markChapterRead',
      function: () async {
        final comicChapter = ComicChapterModel.create(
          comicId: comicId,
          chapter: chapter,
          chapterId: chapterId,
          isCompleted: isCompleted,
        );

        await _repository.markChapterRead(comicChapter);
      },
    );
  }

  /// Get read chapters for a comic
  Future<List<ComicChapterModel>> getReadChapters(String comicId) async {
    return await performanceAsync(
      operationName: 'getReadChapters',
      function: () => _repository.getReadChapters(comicId),
    );
  }

  /// Check if chapter is read by chapter ID (more reliable)
  Future<bool> isChapterReadById(String comicId, String chapterId) async {
    return await performanceAsync(
      operationName: 'isChapterReadById',
      function: () => _repository.isChapterReadById(comicId, chapterId),
    );
  }

  /// Check if chapter is read by chapter title (legacy method)
  Future<bool> isChapterRead(String comicId, String chapter) async {
    return await performanceAsync(
      operationName: 'isChapterRead',
      function: () => _repository.isChapterRead(comicId, chapter),
    );
  }

  /// Get read chapter IDs for a comic (for quick lookup)
  Future<Set<String>> getReadChapterIds(String comicId) async {
    return await performanceAsync(
      operationName: 'getReadChapterIds',
      function: () => _repository.getReadChapterIds(comicId),
    );
  }

  /// Remove all read chapters for a comic
  Future<bool> removeComicChapters(String comicId) async {
    return await performanceAsync(
      operationName: 'removeComicChapters',
      function: () => _repository.removeComicChapters(comicId),
    );
  }

  /// Remove specific chapter
  Future<bool> removeChapter(String comicId, String chapter) async {
    return await performanceAsync(
      operationName: 'removeChapter',
      function: () => _repository.removeChapter(comicId, chapter),
    );
  }

  /// Get read chapters count for a comic
  Future<int> getReadChaptersCount(String comicId) async {
    return await performanceAsync(
      operationName: 'getReadChaptersCount',
      function: () => _repository.getReadChaptersCount(comicId),
    );
  }

  /// Get total read chapters count across all comics
  Future<int> getTotalReadChaptersCount() async {
    return await performanceAsync(
      operationName: 'getTotalReadChaptersCount',
      function: () => _repository.getTotalReadChaptersCount(),
    );
  }

  /// Clear all read chapters
  Future<void> clearAllChapters() async {
    return await performanceAsync(
      operationName: 'clearAllChapters',
      function: () => _repository.clearAllChapters(),
    );
  }

  /// Mark chapter as completed
  Future<void> markChapterCompleted(String comicId, String chapter) async {
    return await performanceAsync(
      operationName: 'markChapterCompleted',
      function: () => _repository.markChapterCompleted(comicId, chapter),
    );
  }

  /// Get completed chapters for a comic
  Future<List<ComicChapterModel>> getCompletedChapters(String comicId) async {
    return await performanceAsync(
      operationName: 'getCompletedChapters',
      function: () => _repository.getCompletedChapters(comicId),
    );
  }

  /// Check if all chapters are read for a comic
  Future<bool> areAllChaptersRead(
      String comicId, List<String> allChapters) async {
    return await performanceAsync(
      operationName: 'areAllChaptersRead',
      function: () async {
        final readChapterIds = await _repository.getReadChapterIds(comicId);
        return allChapters.every((chapter) => readChapterIds.contains(chapter));
      },
    );
  }

  /// Get unread chapters for a comic
  Future<List<String>> getUnreadChapters(
      String comicId, List<String> allChapters) async {
    return await performanceAsync(
      operationName: 'getUnreadChapters',
      function: () async {
        final readChapterIds = await _repository.getReadChapterIds(comicId);
        return allChapters
            .where((chapter) => !readChapterIds.contains(chapter))
            .toList();
      },
    );
  }

  /// Get reading progress percentage for a comic
  Future<double> getReadingProgress(
      String comicId, List<String> allChapters) async {
    return await performanceAsync(
      operationName: 'getReadingProgress',
      function: () async {
        if (allChapters.isEmpty) return 0.0;

        final readChapterIds = await _repository.getReadChapterIds(comicId);
        final readCount = allChapters
            .where((chapter) => readChapterIds.contains(chapter))
            .length;

        return readCount / allChapters.length;
      },
    );
  }

  /// Mark multiple chapters as read
  Future<void> markMultipleChaptersRead({
    required String comicId,
    required List<String> chapters,
    required List<String> chapterIds,
    bool isCompleted = true,
  }) async {
    return await performanceAsync(
      operationName: 'markMultipleChaptersRead',
      function: () async {
        if (chapters.length != chapterIds.length) {
          throw ArgumentError(
              'Chapters and chapterIds lists must have the same length');
        }

        for (int i = 0; i < chapters.length; i++) {
          final comicChapter = ComicChapterModel.create(
            comicId: comicId,
            chapter: chapters[i],
            chapterId: chapterIds[i],
            isCompleted: isCompleted,
          );

          await _repository.markChapterRead(comicChapter);
        }
      },
    );
  }

  /// Get recently read chapters across all comics
  Future<List<ComicChapterModel>> getRecentlyReadChapters(
      {int limit = 10}) async {
    return await performanceAsync(
      operationName: 'getRecentlyReadChapters',
      function: () async {
        // This would require a more complex query to get recent chapters across all comics
        // For now, we'll implement a simple version
// This would need to be populated from somewhere
        final recentChapters = <ComicChapterModel>[];

        // This is a simplified implementation
        // In a real scenario, you'd want to modify the repository to support this query
        return recentChapters;
      },
    );
  }

  /// Toggle chapter read status
  Future<bool> toggleChapterRead({
    required String comicId,
    required String chapter,
    required String chapterId,
  }) async {
    return await performanceAsync(
      operationName: 'toggleChapterRead',
      function: () async {
        final isCurrentlyRead =
            await _repository.isChapterRead(comicId, chapter);

        if (isCurrentlyRead) {
          await _repository.removeChapter(comicId, chapter);
          return false;
        } else {
          final comicChapter = ComicChapterModel.create(
            comicId: comicId,
            chapter: chapter,
            chapterId: chapterId,
            isCompleted: true,
          );
          await _repository.markChapterRead(comicChapter);
          return true;
        }
      },
    );
  }
}
