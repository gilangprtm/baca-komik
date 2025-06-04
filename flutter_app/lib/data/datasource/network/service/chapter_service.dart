import '../../../../core/base/base_network.dart';
import 'dart:math' as math;
import '../repository/chapter_repository.dart';
import '../repository/comic_repository.dart';
import '../../../models/chapter_model.dart' hide ComicInfo;
import '../../../models/page_model.dart';
import '../../../models/adjacent_chapters_model.dart';

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

          // Enrich chapter data with additional information if needed
          // For example, format the chapter title
          if (chapter.title == null || chapter.title!.isEmpty) {
            // Create a formatted title if none exists
            String formattedTitle = 'Chapter ${chapter.chapterNumber}';

            // We can't modify the title directly since it's final, but we can log it
            logger.i('Formatted chapter title: $formattedTitle',
                tag: 'ChapterService');
          }

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

          // Verify and process the pages data
          final List<Page> processedPages = [];

          for (var page in chapterPages.pages) {
            // Check if image URL is valid
            if (page.imageUrl.isNotEmpty) {
              // If needed, we could process the URL (e.g., add cache busting parameters)
              // Since URL is final, we would create a new Page if we wanted to modify it
              processedPages.add(page);
            } else {
              // Log warning about invalid page
              logger.w(
                  'Invalid page image URL in chapter $chapterId, page number ${page.pageNumber}',
                  tag: 'ChapterService');
            }
          }

          // Sort pages by page number
          processedPages.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));

          // Return the original chapterPages since we can't modify it directly
          // (the processed data was just for validation)
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

  /// Track chapter reading progress and update comic stats
  Future<void> trackReadingProgress(String chapterId) async {
    await performanceAsync(
      operationName: 'trackReadingProgress',
      function: () async {
        try {
          // Get chapter details to access comic ID
          final chapter = await _chapterRepository.getChapterDetails(chapterId);

          // Log reading progress
          logger.i(
              'Tracking reading progress for chapter: $chapterId of comic: ${chapter.idKomik}',
              tag: 'ChapterService');

          // Call repository method to update reading history
          // This would be implemented in a real app
          // await _chapterRepository.markAsRead(chapterId);

          // Increment view count for this chapter
          // await _chapterRepository.incrementViewCount(chapterId);

          // Store locally for offline access
          // await _localStorageRepository.saveReadChapter(chapterId, chapter.idKomik);

          return;
        } catch (e, stackTrace) {
          // Log error but don't throw - reading tracking is non-critical
          logger.e('Error tracking reading progress',
              error: e, stackTrace: stackTrace, tag: 'ChapterService');
        }
      },
    );
  }

  /// Get next and previous chapters for navigation with enhanced logic
  Future<AdjacentChapters> getAdjacentChapters(
      String comicId, double currentChapterNumber) async {
    return await performanceAsync(
      operationName: 'getAdjacentChapters',
      function: () async {
        try {
          // Get all chapters for this comic
          final chaptersResult = await _comicRepository.getComicChapters(
            comicId: comicId,
            limit: 1000, // Get all chapters
            sort: 'chapter_number',
            order: 'asc',
          );

          final List<dynamic> chaptersData =
              chaptersResult['data'] as List<dynamic>;
          final chapters = chaptersData
              .map((chapter) =>
                  Chapter.fromJson(chapter as Map<String, dynamic>))
              .toList();

          // Sort chapters by chapter number
          chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

          // Find next and previous chapters
          Chapter? nextChapter;
          Chapter? prevChapter;

          // Find the index of the current chapter
          int currentIndex = -1;
          for (int i = 0; i < chapters.length; i++) {
            if (chapters[i].chapterNumber == currentChapterNumber) {
              currentIndex = i;
              break;
            }
          }

          // If we found the current chapter
          if (currentIndex != -1) {
            // Get next chapter if available
            if (currentIndex < chapters.length - 1) {
              nextChapter = chapters[currentIndex + 1];
            }

            // Get previous chapter if available
            if (currentIndex > 0) {
              prevChapter = chapters[currentIndex - 1];
            }
          } else {
            // If we couldn't find the exact chapter number, find the closest matches
            // Find chapters with higher and lower chapter numbers
            Chapter? higherChapter;
            Chapter? lowerChapter;

            for (final chapter in chapters) {
              if (chapter.chapterNumber > currentChapterNumber) {
                if (higherChapter == null ||
                    chapter.chapterNumber < higherChapter.chapterNumber) {
                  higherChapter = chapter;
                }
              } else if (chapter.chapterNumber < currentChapterNumber) {
                if (lowerChapter == null ||
                    chapter.chapterNumber > lowerChapter.chapterNumber) {
                  lowerChapter = chapter;
                }
              }
            }

            nextChapter = higherChapter;
            prevChapter = lowerChapter;
          }

          return AdjacentChapters(
            next: nextChapter,
            previous: prevChapter,
          );
        } catch (e, stackTrace) {
          logger.e('Error getting adjacent chapters',
              error: e, stackTrace: stackTrace, tag: 'ChapterService');
          return AdjacentChapters.empty();
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

          final List<dynamic> chaptersData =
              chaptersResult['data'] as List<dynamic>;
          final allChapters = chaptersData
              .map((chapter) =>
                  Chapter.fromJson(chapter as Map<String, dynamic>))
              .toList();

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

  /// Calculate reading progress for a comic
  Future<double> calculateReadingProgress(String comicId) async {
    return await performanceAsync(
      operationName: 'calculateReadingProgress',
      function: () async {
        try {
          // Get all chapters
          final chaptersResult = await _comicRepository.getComicChapters(
            comicId: comicId,
          );

          final List<dynamic> chaptersData =
              chaptersResult['data'] as List<dynamic>;
          final totalChapters = chaptersData.length;

          if (totalChapters == 0) return 0.0;

          // In a real app, we would get read chapters from the API or local storage
          // For now, let's assume we've read 2 chapters
          final readChapters = 2;

          return (readChapters / totalChapters) * 100;
        } catch (e, stackTrace) {
          logger.e('Error calculating reading progress',
              error: e, stackTrace: stackTrace, tag: 'ChapterService');
          return 0.0;
        }
      },
    );
  }
}
