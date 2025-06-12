import '../../../../core/base/base_network.dart';
import '../../../models/shinigami/shinigami_models.dart';
import '../db/dio_service.dart';

class CommentoCommentRepository extends BaseRepository {
  /// Get comments for a specific manga/series
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
    return await _getCommentsWithPath(
      pathParam: 'series/$mangaId',
      page: page,
      pageSize: pageSize,
      lang: lang,
      sortBy: sortBy,
    );
  }

  /// Get comments for a specific chapter
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
    return await _getCommentsWithPath(
      pathParam: 'chapter/$chapterId',
      page: page,
      pageSize: pageSize,
      lang: lang,
      sortBy: sortBy,
    );
  }

  /// Internal method to get comments with specific path
  Future<CommentoCommentResponse> _getCommentsWithPath({
    required String pathParam,
    int page = 1,
    int pageSize = 10,
    String lang = 'en',
    String sortBy = 'insertedAt_desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'path': pathParam,
        'pageSize': pageSize,
        'page': page,
        'lang': lang,
        'sortBy': sortBy,
      };

      logInfo('Fetching comments for path: $pathParam, page: $page');

      final response = await dioService.get(
        '/comment',
        queryParameters: queryParams,
        urlType: UrlType.commentApi,
      );

      if (response.data == null) {
        logError('Received null response data for comments');
        return CommentoCommentResponse.empty();
      }

      final commentResponse = CommentoCommentResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!commentResponse.isSuccess) {
        logError('Comment API returned error: ${commentResponse.errmsg}');
        return CommentoCommentResponse.empty();
      }

      logInfo(
        'Successfully fetched ${commentResponse.comments.length} comments '
        'for path $pathParam (page $page/${commentResponse.data.totalPages})',
      );

      return commentResponse;
    } catch (e, stackTrace) {
      logError(
        'Error fetching comments for path $pathParam',
        error: e,
        stackTrace: stackTrace,
      );

      // Return empty response instead of throwing
      return CommentoCommentResponse.empty();
    }
  }

  /// Get comments with automatic pagination
  /// Loads all comments by fetching multiple pages if needed
  ///
  /// [mangaId] - The manga ID to get comments for
  /// [maxPages] - Maximum number of pages to fetch (default: 5 to prevent infinite loading)
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
    try {
      logInfo(
          'Fetching all comments for manga ID: $mangaId (max $maxPages pages)');

      // Get first page to determine total pages
      final firstPageResponse = await getComments(
        mangaId: mangaId,
        page: 1,
        pageSize: pageSize,
        lang: lang,
        sortBy: sortBy,
      );

      if (!firstPageResponse.isSuccess || firstPageResponse.data.isEmpty) {
        return firstPageResponse;
      }

      final totalPages = firstPageResponse.data.totalPages;
      final pagesToFetch = totalPages > maxPages ? maxPages : totalPages;

      if (pagesToFetch <= 1) {
        return firstPageResponse;
      }

      // Fetch remaining pages
      final List<CommentoComment> allComments = [...firstPageResponse.comments];

      for (int page = 2; page <= pagesToFetch; page++) {
        final pageResponse = await getComments(
          mangaId: mangaId,
          page: page,
          pageSize: pageSize,
          lang: lang,
          sortBy: sortBy,
        );

        if (pageResponse.isSuccess) {
          allComments.addAll(pageResponse.comments);
        } else {
          logError('Failed to fetch page $page for manga $mangaId');
          break;
        }
      }

      // Create combined response
      final combinedData = CommentoCommentListResponse(
        page: 1,
        totalPages: totalPages,
        pageSize: allComments.length,
        count: firstPageResponse.data.count,
        data: allComments,
      );

      logInfo(
        'Successfully fetched ${allComments.length} total comments '
        'from $pagesToFetch pages for manga $mangaId',
      );

      return CommentoCommentResponse(
        errno: 0,
        errmsg: '',
        data: combinedData,
      );
    } catch (e, stackTrace) {
      logError(
        'Error fetching all comments for manga $mangaId',
        error: e,
        stackTrace: stackTrace,
      );

      return CommentoCommentResponse.empty();
    }
  }

  /// Get comment statistics for a manga
  /// Returns basic info about comments without fetching all data
  Future<Map<String, dynamic>> getCommentStats(String mangaId) async {
    try {
      logInfo('Fetching comment stats for manga ID: $mangaId');

      final response = await getComments(
        mangaId: mangaId,
        page: 1,
        pageSize: 1, // Minimal data to get stats
      );

      if (!response.isSuccess) {
        return {
          'total_comments': 0,
          'total_pages': 0,
          'has_comments': false,
        };
      }

      return {
        'total_comments': response.data.count,
        'total_pages': response.data.totalPages,
        'has_comments': response.data.hasComments,
        'page_size': response.data.pageSize,
      };
    } catch (e, stackTrace) {
      logError(
        'Error fetching comment stats for manga $mangaId',
        error: e,
        stackTrace: stackTrace,
      );

      return {
        'total_comments': 0,
        'total_pages': 0,
        'has_comments': false,
      };
    }
  }
}
