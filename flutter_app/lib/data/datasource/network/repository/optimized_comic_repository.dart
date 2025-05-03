import '../../../../core/base/base_network.dart';
import '../../../models/home_comic_model.dart';
import '../../../models/discover_comic_model.dart';
import '../../../models/complete_comic_model.dart';
import '../../../models/metadata_models.dart';

class OptimizedComicRepository extends BaseRepository {
  /// Get home comics with their latest chapters
  /// Uses the optimized /comics/home endpoint
  Future<Map<String, dynamic>> getHomeComics({
    int page = 1,
    int limit = 10,
    String sort = 'updated_date',
    String order = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sort': sort,
        'order': order,
      };

      final response = await dioService.get('/comics/home', queryParameters: queryParams);

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

      final response = await dioService.get('/comics/discover', queryParameters: queryParams);

      final List<DiscoverComic> comics = (response.data['data'] as List)
          .map((comic) => DiscoverComic.fromJson(comic))
          .toList();

      return {
        'data': comics,
        'meta': MetaData.fromJson(response.data['meta']),
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
