import '../../../../core/base/base_network.dart';
import '../../../models/shinigami/shinigami_models.dart';
import '../repository/shinigami_repositories.dart';

class ShinigamiMangaService extends BaseService {
  final ShinigamiMangaRepository _repository = ShinigamiMangaRepository();

  /// Get manga list with pagination and filtering
  /// Supports search, sorting, and filtering by genre, format, country
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
    return await performanceAsync(
      operationName: 'getMangaList',
      function: () => _repository.getMangaList(
        page: page,
        pageSize: pageSize,
        search: search,
        isUpdate: isUpdate,
        sort: sort,
        genre: genre,
        format: format,
        country: country,
      ),
    );
  }

  /// Get latest updated manga with chapters
  /// Optimized for home page display with latest chapters included
  Future<ShinigamiListResponse<ShinigamiManga>> getLatestUpdatedManga({
    int page = 1,
    int pageSize = 12,
  }) async {
    return await performanceAsync(
      operationName: 'getLatestUpdatedManga',
      function: () => _repository.getLatestUpdatedManga(
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  /// Search manga by query
  /// Supports additional filtering by genre, format, country
  Future<ShinigamiListResponse<ShinigamiManga>> searchManga({
    required String query,
    int page = 1,
    int pageSize = 12,
    String? genre,
    String? format,
    String? country,
  }) async {
    return await performanceAsync(
      operationName: 'searchManga',
      function: () => _repository.searchManga(
        query: query,
        page: page,
        pageSize: pageSize,
        genre: genre,
        format: format,
        country: country,
      ),
    );
  }

  /// Get manga detail by ID
  /// Returns complete manga information including taxonomy
  Future<ShinigamiManga> getMangaDetail(String mangaId) async {
    return await performanceAsync(
      operationName: 'getMangaDetail',
      function: () => _repository.getMangaDetail(mangaId),
    );
  }

  /// Get recommended manga
  /// Returns manga marked as recommended
  Future<ShinigamiListResponse<ShinigamiManga>> getRecommendedManga({
    int page = 1,
    int pageSize = 12,
  }) async {
    return await performanceAsync(
      operationName: 'getRecommendedManga',
      function: () => _repository.getRecommendedManga(
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  /// Get manga by genre
  /// Returns manga filtered by specific genre
  Future<ShinigamiListResponse<ShinigamiManga>> getMangaByGenre({
    required String genre,
    int page = 1,
    int pageSize = 12,
  }) async {
    return await performanceAsync(
      operationName: 'getMangaByGenre',
      function: () => _repository.getMangaByGenre(
        genre: genre,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  /// Get manga by format (Manga, Manhwa, Manhua)
  /// Returns manga filtered by specific format
  Future<ShinigamiListResponse<ShinigamiManga>> getMangaByFormat({
    required String format,
    int page = 1,
    int pageSize = 12,
  }) async {
    return await performanceAsync(
      operationName: 'getMangaByFormat',
      function: () => _repository.getMangaByFormat(
        format: format,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  /// Get popular manga with sorting options
  /// Supports sorting by view_count, bookmark_count, or rank
  Future<ShinigamiListResponse<ShinigamiManga>> getPopularManga({
    int page = 1,
    int pageSize = 12,
    String sortBy = 'view_count',
  }) async {
    return await performanceAsync(
      operationName: 'getPopularManga',
      function: () => _repository.getPopularManga(
        page: page,
        pageSize: pageSize,
        sortBy: sortBy,
      ),
    );
  }

  /// Get top manga by filter (daily, weekly, monthly, all_time)
  /// Uses the /manga/top endpoint with filter parameter
  Future<ShinigamiListResponse<ShinigamiManga>> getTopManga({
    String filter = 'daily',
    int page = 1,
    int pageSize = 12,
  }) async {
    return await performanceAsync(
      operationName: 'getTopManga',
      function: () => _repository.getTopManga(
        filter: filter,
        page: page,
        pageSize: pageSize,
      ),
    );
  }

  /// Get manga for home page
  /// Combines latest updates and popular manga for home display
  Future<Map<String, dynamic>> getHomeMangaData({
    int latestPage = 1,
    int latestLimit = 10,
    int popularPage = 1,
    int popularLimit = 10,
  }) async {
    return await performanceAsync(
      operationName: 'getHomeMangaData',
      function: () async {
        try {
          // Fetch latest and popular manga in parallel
          final results = await Future.wait([
            _repository.getLatestUpdatedManga(
              page: latestPage,
              pageSize: latestLimit,
            ),
            _repository.getPopularManga(
              page: popularPage,
              pageSize: popularLimit,
              sortBy: 'view_count',
            ),
          ]);

          return {
            'latest': results[0],
            'popular': results[1],
          };
        } catch (e, stackTrace) {
          logger.e(
            'Error fetching home manga data',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiMangaService',
          );

          // Return empty responses on error
          return {
            'latest': ShinigamiListResponse.empty<ShinigamiManga>(),
            'popular': ShinigamiListResponse.empty<ShinigamiManga>(),
          };
        }
      },
    );
  }

  /// Get discover manga data
  /// Returns recommended and popular manga for discover page
  Future<Map<String, dynamic>> getDiscoverMangaData({
    int recommendedLimit = 10,
    int popularLimit = 10,
  }) async {
    return await performanceAsync(
      operationName: 'getDiscoverMangaData',
      function: () async {
        try {
          // Fetch recommended and popular manga in parallel
          final results = await Future.wait([
            _repository.getRecommendedManga(
              page: 1,
              pageSize: recommendedLimit,
            ),
            _repository.getPopularManga(
              page: 1,
              pageSize: popularLimit,
              sortBy: 'bookmark_count',
            ),
          ]);

          return {
            'recommended': results[0],
            'popular': results[1],
          };
        } catch (e, stackTrace) {
          logger.e(
            'Error fetching discover manga data',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiMangaService',
          );

          // Return empty responses on error
          return {
            'recommended': ShinigamiListResponse.empty<ShinigamiManga>(),
            'popular': ShinigamiListResponse.empty<ShinigamiManga>(),
          };
        }
      },
    );
  }

  /// Get manga with advanced filtering
  /// Combines multiple filters for advanced search
  Future<ShinigamiListResponse<ShinigamiManga>> getFilteredManga({
    int page = 1,
    int pageSize = 12,
    String? search,
    List<String>? genres,
    List<String>? formats,
    String? country,
    String? sort,
    int? minRating,
    int? minViewCount,
  }) async {
    return await performanceAsync(
      operationName: 'getFilteredManga',
      function: () async {
        // For now, use single genre and format
        // In future, API might support multiple values
        final genre = genres?.isNotEmpty == true ? genres!.first : null;
        final format = formats?.isNotEmpty == true ? formats!.first : null;

        final response = await _repository.getMangaList(
          page: page,
          pageSize: pageSize,
          search: search,
          genre: genre,
          format: format,
          country: country,
          sort: sort,
        );

        // Apply client-side filtering for rating and view count
        if (minRating != null || minViewCount != null) {
          final filteredData = response.data.where((manga) {
            if (minRating != null && (manga.userRate ?? 0) < minRating) {
              return false;
            }
            if (minViewCount != null && manga.viewCount < minViewCount) {
              return false;
            }
            return true;
          }).toList();

          return ShinigamiListResponse<ShinigamiManga>(
            data: filteredData,
            meta: response.meta,
            facet: response.facet,
          );
        }

        return response;
      },
    );
  }
}
