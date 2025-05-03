import '../../../../core/base/base_network.dart';
import '../repository/chapter_repository.dart';
import '../../../models/chapter_model.dart';
import '../../../models/page_model.dart';

class ChapterService extends BaseService {
  final ChapterRepository _chapterRepository = ChapterRepository();

  /// Get chapter details by ID
  Future<Chapter> getChapterDetails(String id) async {
    return await performanceAsync(
      operationName: 'getChapterDetails',
      function: () => _chapterRepository.getChapterDetails(id),
    );
  }

  /// Get chapter pages by chapter ID
  Future<ChapterPages> getChapterPages(String chapterId) async {
    return await performanceAsync(
      operationName: 'getChapterPages',
      function: () => _chapterRepository.getChapterPages(chapterId),
    );
  }

  /// Track chapter reading progress
  Future<void> trackReadingProgress(String chapterId) async {
    // This would typically update a local database or call an API
    // to track that the user has read this chapter
    await performanceAsync(
      operationName: 'trackReadingProgress',
      function: () async {
        // Implementation would depend on your tracking mechanism
        // For now, we'll just log it
        logger.i('Tracking reading progress for chapter: $chapterId', 
          tag: 'ChapterService');
        return;
      },
    );
  }

  /// Get next and previous chapters for navigation
  Future<Map<String, Chapter?>> getAdjacentChapters(
    String comicId, 
    double currentChapterNumber
  ) async {
    return await performanceAsync(
      operationName: 'getAdjacentChapters',
      function: () async {
        // This is a simplified implementation
        // In a real app, you might want to fetch this data from the API
        // or use data already available in the UI
        final currentChapter = await _chapterRepository.getChapterDetails(comicId);
        
        Chapter? nextChapter;
        Chapter? prevChapter;
        
        if (currentChapter.nextChapter != null) {
          nextChapter = await _chapterRepository.getChapterDetails(
            currentChapter.nextChapter!.id
          );
        }
        
        if (currentChapter.prevChapter != null) {
          prevChapter = await _chapterRepository.getChapterDetails(
            currentChapter.prevChapter!.id
          );
        }
        
        return {
          'next': nextChapter,
          'previous': prevChapter,
        };
      },
    );
  }
}
