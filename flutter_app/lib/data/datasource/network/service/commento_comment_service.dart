import '../../../../core/base/base_network.dart';
import '../../../models/shinigami/shinigami_models.dart';
import '../repository/commento_comment_repository.dart';

class CommentoCommentService extends BaseService {
  final CommentoCommentRepository _repository = CommentoCommentRepository();

  /// Get comments for a specific manga with performance monitoring
  ///
  /// [mangaId] - The manga ID to get comments for
  /// [page] - Page number (starts from 1)
  /// [pageSize] - Number of comments per page (default: 10)
  /// [lang] - Language code (default: 'en')
  /// [sortBy] - Sort order (default: 'insertedAt_desc' for newest first)
  Future<CommentoCommentResponse> getComments({
    required String mangaId,
    int page = 1,
    int pageSize = 10,
    String lang = 'en',
    String sortBy = 'insertedAt_desc',
  }) async {
    return await performanceAsync<CommentoCommentResponse>(
      operationName: 'getComments',
      function: () async {
        logger.i(
          'CommentoCommentService: Getting comments for manga $mangaId (page $page)',
          tag: 'CommentoCommentService',
        );

        final result = await _repository.getComments(
          mangaId: mangaId,
          page: page,
          pageSize: pageSize,
          lang: lang,
          sortBy: sortBy,
        );

        if (result.isSuccess) {
          logger.i(
            'CommentoCommentService: Successfully retrieved ${result.comments.length} comments',
            tag: 'CommentoCommentService',
          );
        } else {
          logger.e(
            'CommentoCommentService: Failed to get comments: ${result.errmsg}',
            tag: 'CommentoCommentService',
          );
        }

        return result;
      },
      tag: 'CommentoCommentService',
    );
  }

  /// Get comments for a specific chapter with performance monitoring
  ///
  /// [chapterId] - The chapter ID to get comments for
  /// [page] - Page number (starts from 1)
  /// [pageSize] - Number of comments per page (default: 10)
  /// [lang] - Language code (default: 'en')
  /// [sortBy] - Sort order (default: 'insertedAt_desc' for newest first)
  Future<CommentoCommentResponse> getChapterComments({
    required String chapterId,
    int page = 1,
    int pageSize = 10,
    String lang = 'en',
    String sortBy = 'insertedAt_desc',
  }) async {
    return await performanceAsync<CommentoCommentResponse>(
      operationName: 'getChapterComments',
      function: () async {
        logger.i(
          'CommentoCommentService: Getting comments for chapter $chapterId (page $page)',
          tag: 'CommentoCommentService',
        );

        final result = await _repository.getChapterComments(
          chapterId: chapterId,
          page: page,
          pageSize: pageSize,
          lang: lang,
          sortBy: sortBy,
        );

        if (result.isSuccess) {
          logger.i(
            'CommentoCommentService: Successfully retrieved ${result.comments.length} chapter comments',
            tag: 'CommentoCommentService',
          );
        } else {
          logger.e(
            'CommentoCommentService: Failed to get chapter comments: ${result.errmsg}',
            tag: 'CommentoCommentService',
          );
        }

        return result;
      },
      tag: 'CommentoCommentService',
    );
  }

  /// Get all comments for a manga with automatic pagination
  ///
  /// [mangaId] - The manga ID to get comments for
  /// [maxPages] - Maximum number of pages to fetch (default: 5)
  /// [pageSize] - Number of comments per page (default: 10)
  /// [lang] - Language code (default: 'en')
  /// [sortBy] - Sort order (default: 'insertedAt_desc' for newest first)
  Future<CommentoCommentResponse> getAllComments({
    required String mangaId,
    int maxPages = 5,
    int pageSize = 10,
    String lang = 'en',
    String sortBy = 'insertedAt_desc',
  }) async {
    return await performanceAsync<CommentoCommentResponse>(
      operationName: 'getAllComments',
      function: () async {
        logger.i(
          'CommentoCommentService: Getting all comments for manga $mangaId (max $maxPages pages)',
          tag: 'CommentoCommentService',
        );

        final result = await _repository.getAllComments(
          mangaId: mangaId,
          maxPages: maxPages,
          pageSize: pageSize,
          lang: lang,
          sortBy: sortBy,
        );

        if (result.isSuccess) {
          logger.i(
            'CommentoCommentService: Successfully retrieved ${result.comments.length} total comments',
            tag: 'CommentoCommentService',
          );
        } else {
          logger.e(
            'CommentoCommentService: Failed to get all comments: ${result.errmsg}',
            tag: 'CommentoCommentService',
          );
        }

        return result;
      },
      tag: 'CommentoCommentService',
    );
  }

  /// Get comment statistics for a manga
  /// Returns basic info about comments without fetching all data
  ///
  /// [mangaId] - The manga ID to get comment stats for
  Future<Map<String, dynamic>> getCommentStats(String mangaId) async {
    return await performanceAsync<Map<String, dynamic>>(
      operationName: 'getCommentStats',
      function: () async {
        logger.i(
          'CommentoCommentService: Getting comment stats for manga $mangaId',
          tag: 'CommentoCommentService',
        );

        final result = await _repository.getCommentStats(mangaId);

        logger.i(
          'CommentoCommentService: Retrieved comment stats - '
          'Total: ${result['total_comments']}, Has comments: ${result['has_comments']}',
          tag: 'CommentoCommentService',
        );

        return result;
      },
      tag: 'CommentoCommentService',
    );
  }

  /// Get comments with caching and error handling
  /// This method provides additional error handling and can be extended with caching
  ///
  /// [mangaId] - The manga ID to get comments for
  /// [page] - Page number (starts from 1)
  /// [pageSize] - Number of comments per page (default: 10)
  /// [retryOnError] - Whether to retry on error (default: true)
  Future<CommentoCommentResponse> getCommentsWithRetry({
    required String mangaId,
    int page = 1,
    int pageSize = 10,
    bool retryOnError = true,
  }) async {
    return await performanceAsync<CommentoCommentResponse>(
      operationName: 'getCommentsWithRetry',
      function: () async {
        logger.i(
          'CommentoCommentService: Getting comments with retry for manga $mangaId',
          tag: 'CommentoCommentService',
        );

        try {
          final result = await getComments(
            mangaId: mangaId,
            page: page,
            pageSize: pageSize,
          );

          if (!result.isSuccess && retryOnError) {
            logger.w(
              'CommentoCommentService: First attempt failed, retrying...',
              tag: 'CommentoCommentService',
            );

            // Wait a bit before retry
            await Future.delayed(const Duration(milliseconds: 500));

            return await getComments(
              mangaId: mangaId,
              page: page,
              pageSize: pageSize,
            );
          }

          return result;
        } catch (e, stackTrace) {
          logger.e(
            'CommentoCommentService: Error getting comments with retry',
            error: e,
            stackTrace: stackTrace,
            tag: 'CommentoCommentService',
          );

          return CommentoCommentResponse.empty();
        }
      },
      tag: 'CommentoCommentService',
    );
  }

  /// Check if a manga has comments
  /// Quick method to check if comments exist without fetching all data
  ///
  /// [mangaId] - The manga ID to check
  Future<bool> hasComments(String mangaId) async {
    return await performanceAsync<bool>(
      operationName: 'hasComments',
      function: () async {
        logger.i(
          'CommentoCommentService: Checking if manga $mangaId has comments',
          tag: 'CommentoCommentService',
        );

        final stats = await getCommentStats(mangaId);
        final hasComments = stats['has_comments'] as bool? ?? false;

        logger.i(
          'CommentoCommentService: Manga $mangaId has comments: $hasComments',
          tag: 'CommentoCommentService',
        );

        return hasComments;
      },
      tag: 'CommentoCommentService',
    );
  }

  /// Get total comment count for a manga
  ///
  /// [mangaId] - The manga ID to get comment count for
  Future<int> getCommentCount(String mangaId) async {
    return await performanceAsync<int>(
      operationName: 'getCommentCount',
      function: () async {
        logger.i(
          'CommentoCommentService: Getting comment count for manga $mangaId',
          tag: 'CommentoCommentService',
        );

        final stats = await getCommentStats(mangaId);
        final count = stats['total_comments'] as int? ?? 0;

        logger.i(
          'CommentoCommentService: Manga $mangaId has $count comments',
          tag: 'CommentoCommentService',
        );

        return count;
      },
      tag: 'CommentoCommentService',
    );
  }
}
