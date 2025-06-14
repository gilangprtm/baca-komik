import '../../../../core/base/base_network.dart';
import '../../../models/shinigami/shinigami_models.dart';
import '../db/dio_service.dart';

class ShinigamiMangaRepository extends BaseRepository {
  /// Get manga list with pagination
  /// Supports search, sorting, and filtering
  Future<ShinigamiListResponse<ShinigamiManga>> getMangaList({
    int page = 1,
    int pageSize = 12,
    String? search,
    bool? isUpdate,
    String? sort,
    String? genre,
    String? format,
    String? country,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      // Add optional parameters
      if (search != null && search.isNotEmpty) {
        queryParams['q'] = search;
      }
      if (isUpdate != null) {
        queryParams['is_update'] = isUpdate;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }
      if (genre != null && genre.isNotEmpty) {
        queryParams['genre'] = genre;
      }
      if (format != null && format.isNotEmpty) {
        queryParams['format'] = format;
      }
      if (country != null && country.isNotEmpty) {
        queryParams['country'] = country;
      }

      final response = await dioService.get(
        '/manga/list',
        queryParameters: queryParams,
        urlType: UrlType.shinigamiApi,
      );

      return ShinigamiListResponse.fromJson(
        response.data,
        (json) => ShinigamiManga.fromJson(json),
      );
    } catch (e, stackTrace) {
      logError(
        'Error fetching manga list',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get latest updated manga with chapters
  /// This is optimized for home page display
  Future<ShinigamiListResponse<ShinigamiManga>> getLatestUpdatedManga({
    int page = 1,
    int pageSize = 12,
  }) async {
    try {
      return await getMangaList(
        page: page,
        pageSize: pageSize,
        isUpdate: true,
        sort: 'latest',
      );
    } catch (e, stackTrace) {
      logError(
        'Error fetching latest updated manga',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Search manga by query
  Future<ShinigamiListResponse<ShinigamiManga>> searchManga({
    required String query,
    int page = 1,
    int pageSize = 12,
    String? genre,
    String? format,
    String? country,
  }) async {
    try {
      return await getMangaList(
        page: page,
        pageSize: pageSize,
        search: query,
        genre: genre,
        format: format,
        country: country,
      );
    } catch (e, stackTrace) {
      logError(
        'Error searching manga',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get manga detail by ID
  Future<ShinigamiManga> getMangaDetail(String mangaId) async {
    try {
      final response = await dioService.get(
        '/manga/detail/$mangaId',
        urlType: UrlType.shinigamiApi,
      );

      final shinigamiResponse = ShinigamiResponse.fromJson(
        response.data,
        (data) => ShinigamiManga.fromJson(data as Map<String, dynamic>),
      );

      if (!shinigamiResponse.isSuccess) {
        throw Exception(
            'Failed to fetch manga detail: ${shinigamiResponse.message}');
      }

      return shinigamiResponse.data;
    } catch (e, stackTrace) {
      logError(
        'Error fetching manga detail',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get recommended manga
  Future<ShinigamiListResponse<ShinigamiManga>> getRecommendedManga({
    int page = 1,
    int pageSize = 12,
  }) async {
    try {
      // Get all manga and filter recommended ones
      final response = await getMangaList(
        page: page,
        pageSize: pageSize,
      );

      // Filter only recommended manga
      final recommendedManga =
          response.data.where((manga) => manga.isRecommended).toList();

      return ShinigamiListResponse<ShinigamiManga>(
        data: recommendedManga,
        meta: response.meta,
        facet: response.facet,
      );
    } catch (e, stackTrace) {
      logError(
        'Error fetching recommended manga',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get manga by genre
  Future<ShinigamiListResponse<ShinigamiManga>> getMangaByGenre({
    required String genre,
    int page = 1,
    int pageSize = 12,
  }) async {
    try {
      return await getMangaList(
        page: page,
        pageSize: pageSize,
        genre: genre,
      );
    } catch (e, stackTrace) {
      logError(
        'Error fetching manga by genre',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get manga by format (Manga, Manhwa, Manhua)
  Future<ShinigamiListResponse<ShinigamiManga>> getMangaByFormat({
    required String format,
    int page = 1,
    int pageSize = 12,
  }) async {
    try {
      return await getMangaList(
        page: page,
        pageSize: pageSize,
        format: format,
      );
    } catch (e, stackTrace) {
      logError(
        'Error fetching manga by format',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get popular manga (sorted by view count or bookmark count)
  Future<ShinigamiListResponse<ShinigamiManga>> getPopularManga({
    int page = 1,
    int pageSize = 12,
    String sortBy = 'view_count', // 'view_count', 'bookmark_count', 'rank'
  }) async {
    try {
      final response = await getMangaList(
        page: page,
        pageSize: pageSize,
      );

      // Sort the data based on the sortBy parameter
      final sortedData = List<ShinigamiManga>.from(response.data);
      sortedData.sort((a, b) {
        switch (sortBy) {
          case 'view_count':
            return b.viewCount.compareTo(a.viewCount);
          case 'bookmark_count':
            return b.bookmarkCount.compareTo(a.bookmarkCount);
          case 'rank':
            return a.rank.compareTo(b.rank); // Lower rank is better
          default:
            return b.viewCount.compareTo(a.viewCount);
        }
      });

      return ShinigamiListResponse<ShinigamiManga>(
        data: sortedData,
        meta: response.meta,
        facet: response.facet,
      );
    } catch (e, stackTrace) {
      logError(
        'Error fetching popular manga',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get top manga by filter (daily, weekly, monthly, all_time)
  Future<ShinigamiListResponse<ShinigamiManga>> getTopManga({
    String filter = 'daily', // 'daily', 'weekly', 'monthly', 'all_time'
    int page = 1,
    int pageSize = 12,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'filter': filter,
        'page': page,
        'page_size': pageSize,
      };

      final response = await dioService.get(
        '/manga/top',
        queryParameters: queryParams,
        urlType: UrlType.shinigamiApi,
      );

      return ShinigamiListResponse.fromJson(
        response.data,
        (json) => ShinigamiManga.fromJson(json),
      );
    } catch (e, stackTrace) {
      logError(
        'Error fetching top manga',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
