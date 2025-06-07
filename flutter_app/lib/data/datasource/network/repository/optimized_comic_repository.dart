import '../../../../core/base/base_network.dart';
import '../../../models/home_comic_model.dart';
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

  /// Get popular comics from /comics/popular endpoint
  Future<Map<String, dynamic>> getPopularComics({
    String type = 'all_time',
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'type': type,
        'limit': limit,
      };

      final response =
          await dioService.get('/comics/popular', queryParameters: queryParams);

      return response.data;
    } catch (e, stackTrace) {
      logError(
        'Error fetching popular comics',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get recommended comics from /comics/recommended endpoint
  Future<Map<String, dynamic>> getRecommendedComics({
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };

      final response = await dioService.get('/comics/recommended',
          queryParameters: queryParams);

      return response.data;
    } catch (e, stackTrace) {
      logError(
        'Error fetching recommended comics',
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
