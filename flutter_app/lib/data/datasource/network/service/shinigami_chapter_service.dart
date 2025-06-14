import '../../../../core/base/base_network.dart';
import '../../../models/shinigami/shinigami_models.dart';
import '../repository/shinigami_repositories.dart';

class ShinigamiChapterService extends BaseService {
  final ShinigamiChapterRepository _repository = ShinigamiChapterRepository();

  /// Get chapters list by manga ID with pagination
  /// Returns paginated list of chapters for a manga
  Future<ShinigamiListResponse<ShinigamiChapter>> getChaptersByMangaId({
    required String mangaId,
    int page = 1,
    int pageSize = 24,
    String sortBy = 'chapter_number',
    String sortOrder = 'desc',
  }) async {
    return await performanceAsync(
      operationName: 'getChaptersByMangaId',
      function: () async {
        final response = await _repository.getChaptersByMangaId(
          mangaId: mangaId,
          page: page,
          pageSize: pageSize,
          sortBy: sortBy,
          sortOrder: sortOrder,
        );

        // Convert to ShinigamiListResponse for compatibility
        return response.toShinigamiListResponse();
      },
    );
  }

  /// Get chapter detail by ID
  /// Returns complete chapter information including pages data and navigation
  Future<ShinigamiChapter> getChapterDetail(String chapterId) async {
    return await performanceAsync(
      operationName: 'getChapterDetail',
      function: () => _repository.getChapterDetail(chapterId),
    );
  }

  /// Get chapter pages as ShinigamiPage objects
  /// Converts chapter data to individual page objects for easier handling
  Future<List<ShinigamiPage>> getChapterPages(String chapterId) async {
    return await performanceAsync(
      operationName: 'getChapterPages',
      function: () => _repository.getChapterPages(chapterId),
    );
  }

  /// Get chapter navigation information
  /// Returns navigation data for prev/next chapter
  Future<ShinigamiChapterNavigation> getChapterNavigation(
      String chapterId) async {
    return await performanceAsync(
      operationName: 'getChapterNavigation',
      function: () => _repository.getChapterNavigation(chapterId),
    );
  }

  /// Get specific page URL by page number
  /// Returns the full URL for a specific page in the chapter
  Future<String?> getPageUrl(String chapterId, int pageNumber,
      {bool lowQuality = false}) async {
    return await performanceAsync(
      operationName: 'getPageUrl',
      function: () =>
          _repository.getPageUrl(chapterId, pageNumber, lowQuality: lowQuality),
    );
  }

  /// Get all page URLs for a chapter
  /// Returns list of all page URLs in the chapter
  Future<List<String>> getAllPageUrls(String chapterId,
      {bool lowQuality = false}) async {
    return await performanceAsync(
      operationName: 'getAllPageUrls',
      function: () =>
          _repository.getAllPageUrls(chapterId, lowQuality: lowQuality),
    );
  }

  /// Get chapter basic info (without pages data)
  /// Useful for navigation and display purposes
  Future<Map<String, dynamic>> getChapterBasicInfo(String chapterId) async {
    return await performanceAsync(
      operationName: 'getChapterBasicInfo',
      function: () => _repository.getChapterBasicInfo(chapterId),
    );
  }

  /// Get complete chapter data for reading
  /// Optimized method that fetches chapter detail and pages in parallel
  Future<Map<String, dynamic>> getCompleteChapterData(String chapterId) async {
    return await performanceAsync(
      operationName: 'getCompleteChapterData',
      function: () async {
        try {
          // Use optimized repository method with single API call
          final chapterData =
              await _repository.getCompleteChapterData(chapterId);

          final pages = chapterData['pages'] as List<ShinigamiPage>;

          return {
            ...chapterData,
            'page_urls': pages.map((page) => page.imageUrl).toList(),
            'low_quality_urls':
                pages.map((page) => page.lowQualityImageUrl).toList(),
          };
        } catch (e, stackTrace) {
          logger.e(
            'Error fetching complete chapter data',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiChapterService',
          );
          rethrow;
        }
      },
    );
  }

  /// Check navigation availability
  /// Returns navigation status for UI controls
  Future<Map<String, bool>> getNavigationStatus(String chapterId) async {
    return await performanceAsync(
      operationName: 'getNavigationStatus',
      function: () async {
        try {
          final results = await Future.wait([
            _repository.hasNextChapter(chapterId),
            _repository.hasPrevChapter(chapterId),
          ]);

          return {
            'has_next': results[0],
            'has_prev': results[1],
            'is_first': !(results[1]),
            'is_last': !(results[0]),
          };
        } catch (e, stackTrace) {
          logger.e(
            'Error checking navigation status',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiChapterService',
          );

          // Return safe defaults on error
          return {
            'has_next': false,
            'has_prev': false,
            'is_first': true,
            'is_last': true,
          };
        }
      },
    );
  }

  /// Get navigation chapter IDs
  /// Returns prev and next chapter IDs for navigation
  Future<Map<String, String?>> getNavigationChapterIds(String chapterId) async {
    return await performanceAsync(
      operationName: 'getNavigationChapterIds',
      function: () async {
        try {
          final results = await Future.wait([
            _repository.getNextChapterId(chapterId),
            _repository.getPrevChapterId(chapterId),
          ]);

          return {
            'next_chapter_id': results[0],
            'prev_chapter_id': results[1],
          };
        } catch (e, stackTrace) {
          logger.e(
            'Error getting navigation chapter IDs',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiChapterService',
          );

          return {
            'next_chapter_id': null,
            'prev_chapter_id': null,
          };
        }
      },
    );
  }

  /// Preload adjacent chapters for better user experience
  /// Preloads next and previous chapters in background
  Future<void> preloadAdjacentChapters(String currentChapterId) async {
    return await performanceAsync(
      operationName: 'preloadAdjacentChapters',
      function: () async {
        try {
          // Run preloading in parallel without waiting for completion
          unawaited(Future.wait([
            _repository.preloadNextChapter(currentChapterId),
            _repository.preloadPrevChapter(currentChapterId),
          ]));
        } catch (e, stackTrace) {
          logger.e(
            'Error starting preload for adjacent chapters',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiChapterService',
          );
          // Don't rethrow as this is a background operation
        }
      },
    );
  }

  /// Get chapter reading data with preloading
  /// Optimized for chapter reading with background preloading
  Future<Map<String, dynamic>> getChapterReadingData(String chapterId) async {
    return await performanceAsync(
      operationName: 'getChapterReadingData',
      function: () async {
        try {
          // Get complete chapter data
          final chapterData = await getCompleteChapterData(chapterId);

          // Start preloading adjacent chapters in background
          unawaited(preloadAdjacentChapters(chapterId));

          return chapterData;
        } catch (e, stackTrace) {
          logger.e(
            'Error fetching chapter reading data',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiChapterService',
          );
          rethrow;
        }
      },
    );
  }

  /// Get page count for a chapter
  /// Quick method to get just the page count
  Future<int> getChapterPageCount(String chapterId) async {
    return await performanceAsync(
      operationName: 'getChapterPageCount',
      function: () => _repository.getChapterPageCount(chapterId),
    );
  }

  /// Navigate to next chapter
  /// Returns next chapter ID if available
  Future<String?> navigateToNextChapter(String currentChapterId) async {
    return await performanceAsync(
      operationName: 'navigateToNextChapter',
      function: () => _repository.getNextChapterId(currentChapterId),
    );
  }

  /// Navigate to previous chapter
  /// Returns previous chapter ID if available
  Future<String?> navigateToPrevChapter(String currentChapterId) async {
    return await performanceAsync(
      operationName: 'navigateToPrevChapter',
      function: () => _repository.getPrevChapterId(currentChapterId),
    );
  }
}

// Helper function for unawaited futures
void unawaited(Future<void> future) {
  // Intentionally not awaiting the future
}
