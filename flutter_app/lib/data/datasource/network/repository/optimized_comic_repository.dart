import '../../../../core/base/base_network.dart';
import '../../../models/home_comic_model.dart';
import '../../../models/discover_comics_response_model.dart';
import '../../../models/comic_model.dart';
import '../../../models/complete_comic_model.dart';
import '../../../models/metadata_models.dart';

class OptimizedComicRepository extends BaseRepository {
  /// Get home comics with their latest chapters
  /// Uses the optimized /comics/home endpoint
  /// This endpoint returns comics sorted by their latest chapters
  Future<Map<String, dynamic>> getHomeComics({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      final response =
          await dioService.get('/comics/home', queryParameters: queryParams);

      final List<HomeComic> comics = (response.data['data'] as List)
          .map((comic) => HomeComic.fromJson(comic))
          .toList();

      return {
        'data': comics,
        'meta': MetaData.fromJson(response.data['meta']),
      };
    } catch (e, stackTrace) {
      logError(
        'Error fetching home comics',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get discover comics with filtering options
  /// Uses the optimized /comics/discover endpoint
  Future<Map<String, dynamic>> getDiscoverComics({
    int page = 1,
    int limit = 10,
    String? search,
    String? country,
    String? genre,
    String? format,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (country != null && country.isNotEmpty) {
        queryParams['country'] = country;
      }

      if (genre != null && genre.isNotEmpty) {
        queryParams['genre'] = genre;
      }

      if (format != null && format.isNotEmpty) {
        queryParams['format'] = format;
      }

      final response = await dioService.get('/comics/discover',
          queryParameters: queryParams);

      // Parse the discover response structure
      final responseData = response.data;

      // Parse popular comics
      final List<PopularComic> popularComics =
          (responseData['popular'] as List? ?? [])
              .map((comic) => PopularComic.fromJson(comic))
              .toList();

      // Parse recommended comics
      final List<RecommendedComic> recommendedComics =
          (responseData['recommended'] as List? ?? [])
              .map((comic) => RecommendedComic.fromJson(comic))
              .toList();

      // Parse search results
      final searchResultsData = responseData['search_results'] ?? {};
      final List<Comic> searchResults =
          (searchResultsData['data'] as List? ?? [])
              .map((comic) => Comic.fromJson(comic))
              .toList();

      final MetaData meta = searchResultsData['meta'] != null
          ? MetaData.fromJson(searchResultsData['meta'])
          : MetaData(
              page: 1, limit: 20, total: 0, totalPages: 0, hasMore: false);

      return {
        'popular': popularComics,
        'recommended': recommendedComics,
        'search_results': {
          'data': searchResults,
          'meta': meta,
        },
      };
    } catch (e, stackTrace) {
      logError(
        'Error fetching discover comics',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get complete comic details including chapters and user data
  /// Uses the optimized /comics/{id}/complete endpoint
  Future<CompleteComic> getCompleteComicDetails(String id) async {
    try {
      final response = await dioService.get('/comics/$id/complete');
      return CompleteComic.fromJson(response.data);
    } catch (e, stackTrace) {
      logError(
        'Error fetching complete comic details',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
