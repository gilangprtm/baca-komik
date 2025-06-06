import '../../../../core/base/base_network.dart';
import 'dart:async';
import 'dart:math' as math;
import '../repository/chapter_repository.dart';
import '../repository/comic_repository.dart';
import '../../../models/chapter_model.dart' hide ComicInfo;
import '../../../models/page_model.dart';

class ChapterService extends BaseService {
  final ChapterRepository _chapterRepository = ChapterRepository();
  final ComicRepository _comicRepository = ComicRepository();

  /// Get chapter details by ID with error handling and data enrichment
  Future<Chapter> getChapterDetails(String id) async {
    return await performanceAsync(
      operationName: 'getChapterDetails',
      function: () async {
        try {
          final chapter = await _chapterRepository.getChapterDetails(id);

          // Mark chapter as read
          // await _chapterRepository.markAsRead(chapterId);
          // await _chapterRepository.incrementViewCount(chapterId);

          return chapter;
        } catch (e, stackTrace) {
          logger.e('Error fetching chapter details',
              error: e, stackTrace: stackTrace, tag: 'ChapterService');
          rethrow; // Re-throw to allow the UI to handle the error
        }
      },
    );
  }

  /// Get chapter pages by chapter ID with enhanced error handling
  Future<ChapterPages> getChapterPages(String chapterId) async {
    return await performanceAsync(
      operationName: 'getChapterPages',
      function: () async {
        try {
          // Get chapter pages from repository
          final chapterPages =
              await _chapterRepository.getChapterPages(chapterId);

          return chapterPages;
        } catch (e, stackTrace) {
          logger.e('Error fetching chapter pages',
              error: e, stackTrace: stackTrace, tag: 'ChapterService');

          // Create a fallback chapter info for error case
          final fallbackInfo = ChapterInfo(
            id: chapterId,
            chapterNumber: 0,
            comic: ComicInfo(
              id: '',
              title: 'Unknown',
            ),
          );

          // Return empty chapter pages to prevent UI crashes
          return ChapterPages(
            chapter: fallbackInfo,
            pages: [],
            count: 0,
          );
        }
      },
    );
  }

  /// Get reading history for a specific comic
  Future<List<Chapter>> getReadingHistory(String comicId) async {
    return await performanceAsync(
      operationName: 'getReadingHistory',
      function: () async {
        try {
          // Here you would normally get read chapters from your API
          // For now we'll just get all chapters and simulate history
          final chaptersResult = await _comicRepository.getComicChapters(
            comicId: comicId,
            limit: 20,
            sort: 'chapter_number',
            order: 'desc',
          );

          // The repository already returns List<Chapter> in the 'data' field
          final List<Chapter> allChapters =
              chaptersResult['data'] as List<Chapter>;

          // In a real app, we would filter for read chapters
          // For now, let's just return the first few as "read"
          final readChapters =
              allChapters.take(math.min(3, allChapters.length)).toList();

          return readChapters;
        } catch (e, stackTrace) {
          logger.e('Error getting reading history',
              error: e, stackTrace: stackTrace, tag: 'ChapterService');
          return [];
        }
      },
    );
  }
}
