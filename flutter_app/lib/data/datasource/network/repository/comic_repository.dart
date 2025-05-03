

import '../../../../core/base/base_network.dart';
import '../../../models/comic_model.dart';
import '../../../models/chapter_model.dart';

class ComicRepository extends BaseRepository {
  /// Get all comics with pagination and filtering
  Future<Map<String, dynamic>> getComics({
    int page = 1,
    int limit = 20,
    String? search,
    String? sort,
    String? order,
    String? genre,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      if (order != null && order.isNotEmpty) {
        queryParams['order'] = order;
      }

      if (genre != null && genre.isNotEmpty) {
        queryParams['genre'] = genre;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await dioService.get('/comics', queryParameters: queryParams);

      final List<Comic> comics = (response.data['data'] as List)
          .map((comic) => Comic.fromJson(comic))
          .toList();

      return {
        'data': comics,
        'meta': response.data['meta'],
      };
    } catch (e, stackTrace) {
      logError(
        'Error fetching comics',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get comic details by ID
  Future<Comic> getComicDetails(String id) async {
    try {
      final response = await dioService.get('/comics/$id');
      return Comic.fromJson(response.data);
    } catch (e, stackTrace) {
      logError(
        'Error fetching comic details',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get comic chapters by comic ID
  Future<Map<String, dynamic>> getComicChapters({
    required String comicId,
    int page = 1,
    int limit = 20,
    String sort = 'chapter_number',
    String order = 'desc',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'sort': sort,
        'order': order,
      };

      final response = await dioService.get(
        '/comics/$comicId/chapters',
        queryParameters: queryParams,
      );

      final List<Chapter> chapters = (response.data['data'] as List)
          .map((chapter) => Chapter.fromJson(chapter))
          .toList();

      return {
        'comic': response.data['comic'],
        'data': chapters,
        'meta': response.data['meta'],
      };
    } catch (e, stackTrace) {
      logError(
        'Error fetching comic chapters',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
