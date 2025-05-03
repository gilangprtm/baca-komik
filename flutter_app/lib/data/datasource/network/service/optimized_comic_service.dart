import '../../../../core/base/base_network.dart';
import '../../../models/complete_comic_model.dart';
import '../repository/optimized_comic_repository.dart';

class OptimizedComicService extends BaseService {
  final OptimizedComicRepository _repository = OptimizedComicRepository();

  /// Get home comics with their latest chapters
  /// Uses the optimized /comics/home endpoint
  Future<Map<String, dynamic>> getHomeComics({
    int page = 1,
    int limit = 10,
    String sort = 'updated_date',
    String order = 'desc',
  }) async {
    return await performanceAsync(
      operationName: 'getHomeComics',
      function: () => _repository.getHomeComics(
        page: page,
        limit: limit,
        sort: sort,
        order: order,
      ),
    );
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
    return await performanceAsync(
      operationName: 'getDiscoverComics',
      function: () => _repository.getDiscoverComics(
        page: page,
        limit: limit,
        search: search,
        country: country,
        genre: genre,
        format: format,
      ),
    );
  }

  /// Get complete comic details including chapters and user data
  /// Uses the optimized /comics/{id}/complete endpoint
  Future<CompleteComic> getCompleteComicDetails(String id) async {
    return await performanceAsync(
      operationName: 'getCompleteComicDetails',
      function: () => _repository.getCompleteComicDetails(id),
    );
  }
}
