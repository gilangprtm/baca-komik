import '../../../../core/base/base_network.dart';
import '../../../models/complete_comic_model.dart';
import '../../../models/home_comic_model.dart';
import '../../../models/discover_comics_response_model.dart';
import '../repository/optimized_comic_repository.dart';

class OptimizedComicService extends BaseService {
  final OptimizedComicRepository _repository = OptimizedComicRepository();

  /// Get home comics with their latest chapters
  /// Uses the optimized /comics/home endpoint
  /// Comics are automatically sorted by their latest chapters
  Future<List<HomeComic>> getHomeComics({
    int page = 1,
    int limit = 10,
  }) async {
    return await performanceAsync(
      operationName: 'getHomeComics',
      function: () async {
        try {
          final result = await _repository.getHomeComics(
            page: page,
            limit: limit,
          );

          // Process the data to ensure properly typed HomeComic objects
          final List<HomeComic> homeComics = (result['data'] as List<dynamic>)
              .map((comic) => comic is HomeComic
                  ? comic
                  : HomeComic.fromJson(comic as Map<String, dynamic>))
              .toList();

          // Sort by update date if available
          homeComics.sort((a, b) {
            if (a.updatedDate == null || b.updatedDate == null) return 0;
            return b.updatedDate!.compareTo(a.updatedDate!);
          });

          return homeComics;
        } catch (e, stackTrace) {
          logger.e('Error fetching home comics',
              error: e, stackTrace: stackTrace, tag: 'OptimizedComicService');
          // Return empty list instead of throwing to prevent UI crashes
          return [];
        }
      },
    );
  }

  /// Get discover comics by calling popular and recommended endpoints separately
  /// Uses /comics/popular and /comics/recommended endpoints
  Future<DiscoverComicsResponse> getDiscoverComics({
    int limit = 10,
  }) async {
    return await performanceAsync(
      operationName: 'getDiscoverComics',
      function: () async {
        try {
          // Call both endpoints in parallel
          final results = await Future.wait([
            _repository.getPopularComics(limit: limit),
            _repository.getRecommendedComics(limit: limit),
          ]);

          final popularResult = results[0];
          final recommendedResult = results[1];

          // Parse popular comics
          final List<PopularComic> popularComics =
              (popularResult['data'] as List)
                  .map((comic) => PopularComic.fromJson(comic))
                  .toList();

          // Parse recommended comics
          final List<RecommendedComic> recommendedComics =
              (recommendedResult['data'] as List)
                  .map((comic) => RecommendedComic.fromJson(comic))
                  .toList();

          // Create discover response
          final discoverResponse = DiscoverComicsResponse(
            popular: popularComics,
            recommended: recommendedComics,
            searchResults:
                SearchResults.empty(), // No search results for discover
          );

          // Log the successful fetch
          logger.i(
            'Successfully fetched discover comics: '
            'Popular: ${discoverResponse.popular.length}, '
            'Recommended: ${discoverResponse.recommended.length}',
            tag: 'OptimizedComicService',
          );

          return discoverResponse;
        } catch (e, stackTrace) {
          logger.e('Error fetching discover comics',
              error: e, stackTrace: stackTrace, tag: 'OptimizedComicService');
          // Return empty result to prevent UI crashes
          return DiscoverComicsResponse.empty();
        }
      },
    );
  }

  /// Get complete comic details including chapters and user data
  /// Uses the optimized /comics/{id}/complete endpoint
  Future<CompleteComic> getCompleteComicDetails(String id) async {
    return await performanceAsync(
      operationName: 'getCompleteComicDetails',
      function: () async {
        try {
          final completeComic = await _repository.getCompleteComicDetails(id);

          // NOTE: The API endpoint no longer returns chapter data
          // Chapter data should be fetched separately via getComicChapters

          return completeComic;
        } catch (e, stackTrace) {
          logger.e('Error fetching complete comic details',
              error: e, stackTrace: stackTrace, tag: 'OptimizedComicService');
          rethrow; // Re-throw as this is a critical error that needs to be handled by UI
        }
      },
    );
  }

  /// Get popular comics from the popular endpoint
  Future<List<PopularComic>> getPopularComics({
    String type = 'all_time',
    int limit = 10,
  }) async {
    return await performanceAsync(
      operationName: 'getPopularComics',
      function: () async {
        try {
          final result = await _repository.getPopularComics(
            type: type,
            limit: limit,
          );

          final List<PopularComic> comics = (result['data'] as List<dynamic>)
              .map((comic) =>
                  PopularComic.fromJson(comic as Map<String, dynamic>))
              .toList();

          return comics;
        } catch (e, stackTrace) {
          logger.e('Error fetching popular comics',
              error: e, stackTrace: stackTrace, tag: 'OptimizedComicService');
          return []; // Return empty list instead of throwing
        }
      },
    );
  }

  /// Get recommended comics from the recommended endpoint
  Future<List<RecommendedComic>> getRecommendedComics({
    int limit = 10,
  }) async {
    return await performanceAsync(
      operationName: 'getRecommendedComics',
      function: () async {
        try {
          final result = await _repository.getRecommendedComics(
            limit: limit,
          );

          final List<RecommendedComic> comics =
              (result['data'] as List<dynamic>)
                  .map((comic) =>
                      RecommendedComic.fromJson(comic as Map<String, dynamic>))
                  .toList();

          return comics;
        } catch (e, stackTrace) {
          logger.e('Error fetching recommended comics',
              error: e, stackTrace: stackTrace, tag: 'OptimizedComicService');
          return []; // Return empty list instead of throwing
        }
      },
    );
  }
}
