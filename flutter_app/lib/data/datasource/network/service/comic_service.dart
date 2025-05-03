import '../../../../core/base/base_network.dart';
import '../../../models/comic_model.dart';
import '../repository/comic_repository.dart';

class ComicService extends BaseService {
  final ComicRepository _comicRepository = ComicRepository();

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
    return await performanceAsync(
      operationName: 'getComics',
      function: () => _comicRepository.getComics(
        page: page,
        limit: limit,
        search: search,
        sort: sort,
        order: order,
        genre: genre,
        status: status,
      ),
    );
  }

  /// Get comic details by ID
  Future<Comic> getComicDetails(String id) async {
    return await performanceAsync(
      operationName: 'getComicDetails',
      function: () => _comicRepository.getComicDetails(id),
    );
  }

  /// Get comic chapters by comic ID
  Future<Map<String, dynamic>> getComicChapters({
    required String comicId,
    int page = 1,
    int limit = 20,
    String sort = 'chapter_number',
    String order = 'desc',
  }) async {
    return await performanceAsync(
      operationName: 'getComicChapters',
      function: () => _comicRepository.getComicChapters(
        comicId: comicId,
        page: page,
        limit: limit,
        sort: sort,
        order: order,
      ),
    );
  }

  /// Search comics by title
  Future<List<Comic>> searchComics(String query) async {
    if (query.isEmpty) {
      return [];
    }

    return await performanceAsync(
      operationName: 'searchComics',
      function: () async {
        final result = await _comicRepository.getComics(
          search: query,
          limit: 10,
        );
        return result['data'] as List<Comic>;
      },
    );
  }

  /// Get featured comics (recommended and popular)
  Future<Map<String, List<Comic>>> getFeaturedComics() async {
    return await performanceAsync(
      operationName: 'getFeaturedComics',
      function: () async {
        // Get recommended comics
        final recommendedResult = await _comicRepository.getComics(
          sort: 'rank',
          order: 'desc',
          limit: 10,
        );

        // Get popular comics
        final popularResult = await _comicRepository.getComics(
          sort: 'view_count',
          order: 'desc',
          limit: 10,
        );

        return {
          'recommended': recommendedResult['data'] as List<Comic>,
          'popular': popularResult['data'] as List<Comic>,
        };
      },
    );
  }

  /// Get latest updated comics
  Future<List<Comic>> getLatestComics() async {
    return await performanceAsync(
      operationName: 'getLatestComics',
      function: () async {
        final result = await _comicRepository.getComics(
          sort: 'updated_date',
          order: 'desc',
          limit: 20,
        );
        return result['data'] as List<Comic>;
      },
    );
  }
}