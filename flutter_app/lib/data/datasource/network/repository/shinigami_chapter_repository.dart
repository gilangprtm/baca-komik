import '../../../../core/base/base_network.dart';
import '../../../models/shinigami/shinigami_models.dart';
import '../db/dio_service.dart';

class ShinigamiChapterRepository extends BaseRepository {
  /// Get chapters list by manga ID
  /// Returns paginated list of chapters for a manga
  Future<ShinigamiChapterListResponse> getChaptersByMangaId({
    required String mangaId,
    int page = 1,
    int pageSize = 24,
    String sortBy = 'chapter_number',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        'sort_by': sortBy,
        'sort_order': sortOrder,
      };

      logInfo('Fetching chapters for manga ID: $mangaId, page: $page');

      final response = await dioService.get(
        '/chapter/$mangaId/list',
        queryParameters: queryParams,
        urlType: UrlType.shinigamiApi,
      );

      logInfo('Chapters list response received');

      final chaptersResponse =
          ShinigamiChapterListResponse.fromJson(response.data);

      if (!chaptersResponse.isSuccess) {
        throw Exception(
            'Failed to fetch chapters: ${chaptersResponse.message}');
      }

      return chaptersResponse;
    } catch (e, stackTrace) {
      logError(
        'Error fetching chapters for manga $mangaId',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get chapter detail by ID
  /// Returns complete chapter information including pages data
  Future<ShinigamiChapter> getChapterDetail(String chapterId) async {
    try {
      logInfo('Fetching chapter detail for ID: $chapterId');

      final response = await dioService.get(
        '/chapter/detail/$chapterId',
        urlType: UrlType.shinigamiApi,
      );

      logInfo('Chapter detail response received');

      final shinigamiResponse = ShinigamiResponse.fromJson(
        response.data,
        (data) => ShinigamiChapter.fromJson(data as Map<String, dynamic>),
      );

      if (!shinigamiResponse.isSuccess) {
        throw Exception(
            'Failed to fetch chapter detail: ${shinigamiResponse.message}');
      }

      return shinigamiResponse.data;
    } catch (e, stackTrace) {
      logError(
        'Error fetching chapter detail',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get chapter pages as ShinigamiPage objects
  /// Converts chapter data to individual page objects for easier handling
  Future<List<ShinigamiPage>> getChapterPages(String chapterId) async {
    try {
      logInfo('Fetching chapter pages for ID: $chapterId');

      final chapter = await getChapterDetail(chapterId);
      final pages = <ShinigamiPage>[];

      for (int i = 0; i < chapter.chapter.data.length; i++) {
        final filename = chapter.chapter.data[i];
        final page = ShinigamiPage.fromChapterData(
          chapterId: chapter.chapterId,
          pageNumber: i + 1,
          filename: filename,
          baseUrl: chapter.baseUrl,
          baseUrlLow: chapter.baseUrlLow,
          path: chapter.chapter.path,
        );
        pages.add(page);
      }

      logInfo('Generated ${pages.length} pages for chapter $chapterId');
      return pages;
    } catch (e, stackTrace) {
      logError(
        'Error fetching chapter pages',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get chapter navigation information
  /// Returns navigation data for prev/next chapter
  Future<ShinigamiChapterNavigation> getChapterNavigation(
      String chapterId) async {
    try {
      logInfo('Fetching chapter navigation for ID: $chapterId');

      final chapter = await getChapterDetail(chapterId);
      return ShinigamiChapterNavigation.fromChapter(chapter);
    } catch (e, stackTrace) {
      logError(
        'Error fetching chapter navigation',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get complete chapter data with single API call (optimized)
  /// Returns chapter detail, pages, and navigation in one call
  Future<Map<String, dynamic>> getCompleteChapterData(String chapterId) async {
    try {
      logInfo('Fetching complete chapter data for ID: $chapterId');

      // Single API call to get chapter detail
      final chapter = await getChapterDetail(chapterId);

      // Generate pages from chapter data (no additional API call)
      final pages = <ShinigamiPage>[];
      for (int i = 0; i < chapter.chapter.data.length; i++) {
        final filename = chapter.chapter.data[i];
        final page = ShinigamiPage.fromChapterData(
          chapterId: chapter.chapterId,
          pageNumber: i + 1,
          filename: filename,
          baseUrl: chapter.baseUrl,
          baseUrlLow: chapter.baseUrlLow,
          path: chapter.chapter.path,
        );
        pages.add(page);
      }

      // Generate navigation from chapter data (no additional API call)
      final navigation = ShinigamiChapterNavigation.fromChapter(chapter);

      logInfo(
          'Generated complete data: ${pages.length} pages for chapter $chapterId');

      return {
        'chapter': chapter,
        'pages': pages,
        'navigation': navigation,
        'page_count': pages.length,
      };
    } catch (e, stackTrace) {
      logError(
        'Error fetching complete chapter data',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get specific page URL by page number
  /// Returns the full URL for a specific page in the chapter
  Future<String?> getPageUrl(String chapterId, int pageNumber,
      {bool lowQuality = false}) async {
    try {
      logInfo('Fetching page URL for chapter $chapterId, page $pageNumber');

      final chapter = await getChapterDetail(chapterId);
      final baseUrl = lowQuality ? chapter.baseUrlLow : chapter.baseUrl;

      return chapter.chapter.getPageUrl(baseUrl, pageNumber);
    } catch (e, stackTrace) {
      logError(
        'Error fetching page URL',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get all page URLs for a chapter
  /// Returns list of all page URLs in the chapter
  Future<List<String>> getAllPageUrls(String chapterId,
      {bool lowQuality = false}) async {
    try {
      logInfo('Fetching all page URLs for chapter $chapterId');

      final chapter = await getChapterDetail(chapterId);
      final baseUrl = lowQuality ? chapter.baseUrlLow : chapter.baseUrl;

      return chapter.chapter.getPageUrls(baseUrl);
    } catch (e, stackTrace) {
      logError(
        'Error fetching all page URLs',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if chapter has next chapter
  Future<bool> hasNextChapter(String chapterId) async {
    try {
      final chapter = await getChapterDetail(chapterId);
      return chapter.hasNextChapter;
    } catch (e, stackTrace) {
      logError(
        'Error checking next chapter',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Check if chapter has previous chapter
  Future<bool> hasPrevChapter(String chapterId) async {
    try {
      final chapter = await getChapterDetail(chapterId);
      return chapter.hasPrevChapter;
    } catch (e, stackTrace) {
      logError(
        'Error checking previous chapter',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Get next chapter ID
  Future<String?> getNextChapterId(String chapterId) async {
    try {
      final chapter = await getChapterDetail(chapterId);
      return chapter.nextChapterId;
    } catch (e, stackTrace) {
      logError(
        'Error getting next chapter ID',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get previous chapter ID
  Future<String?> getPrevChapterId(String chapterId) async {
    try {
      final chapter = await getChapterDetail(chapterId);
      return chapter.prevChapterId;
    } catch (e, stackTrace) {
      logError(
        'Error getting previous chapter ID',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get chapter count (number of pages)
  Future<int> getChapterPageCount(String chapterId) async {
    try {
      final chapter = await getChapterDetail(chapterId);
      return chapter.pageCount;
    } catch (e, stackTrace) {
      logError(
        'Error getting chapter page count',
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }

  /// Get chapter basic info (without pages data)
  /// Useful for navigation and display purposes
  Future<Map<String, dynamic>> getChapterBasicInfo(String chapterId) async {
    try {
      final chapter = await getChapterDetail(chapterId);

      return {
        'id': chapter.chapterId,
        'manga_id': chapter.mangaId,
        'chapter_number': chapter.chapterNumber,
        'title': chapter.displayTitle,
        'page_count': chapter.pageCount,
        'has_next': chapter.hasNextChapter,
        'has_prev': chapter.hasPrevChapter,
        'next_chapter_id': chapter.nextChapterId,
        'prev_chapter_id': chapter.prevChapterId,
        'release_date': chapter.releaseDate?.toIso8601String(),
      };
    } catch (e, stackTrace) {
      logError(
        'Error getting chapter basic info',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Preload next chapter data for better user experience
  /// This can be called in background to cache next chapter
  Future<void> preloadNextChapter(String currentChapterId) async {
    try {
      final nextChapterId = await getNextChapterId(currentChapterId);
      if (nextChapterId != null) {
        logInfo('Preloading next chapter: $nextChapterId');
        // Just fetch the detail to cache it
        await getChapterDetail(nextChapterId);
        logInfo('Next chapter preloaded successfully');
      }
    } catch (e, stackTrace) {
      logError(
        'Error preloading next chapter',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow as this is a background operation
    }
  }

  /// Preload previous chapter data for better user experience
  /// This can be called in background to cache previous chapter
  Future<void> preloadPrevChapter(String currentChapterId) async {
    try {
      final prevChapterId = await getPrevChapterId(currentChapterId);
      if (prevChapterId != null) {
        logInfo('Preloading previous chapter: $prevChapterId');
        // Just fetch the detail to cache it
        await getChapterDetail(prevChapterId);
        logInfo('Previous chapter preloaded successfully');
      }
    } catch (e, stackTrace) {
      logError(
        'Error preloading previous chapter',
        error: e,
        stackTrace: stackTrace,
      );
      // Don't rethrow as this is a background operation
    }
  }
}
