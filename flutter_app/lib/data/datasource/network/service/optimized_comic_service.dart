import '../../../../core/base/base_network.dart';
import '../../../models/complete_comic_model.dart';
import '../../../models/home_comic_model.dart';
import '../../../models/discover_comics_response_model.dart';
import '../../../models/comic_model.dart';
import '../../../models/pagination_model.dart';
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

  /// Get discover comics with filtering options
  /// Uses the optimized /comics/discover endpoint
  Future<DiscoverComicsResponse> getDiscoverComics({
    int page = 1,
    int limit = 10,
    String? search,
    String? country,
    String? genre,
    String? format,
  }) async {
    return await performanceAsync(
      operationName: 'getDiscoverComics',
      function: () async {
        try {
          final result = await _repository.getDiscoverComics(
            page: page,
            limit: limit,
            search: search,
            country: country,
            genre: genre,
            format: format,
          );

          // Create DiscoverComicsResponse from already parsed data
          final searchResultsData = result['search_results'];
          final metaData = searchResultsData['meta'];

          final discoverResponse = DiscoverComicsResponse(
            popular: result['popular'] as List<PopularComic>,
            recommended: result['recommended'] as List<RecommendedComic>,
            searchResults: SearchResults(
              data: searchResultsData['data'] as List<Comic>,
              meta: PaginationMeta(
                page: metaData.page,
                limit: metaData.limit,
                total: metaData.total,
                totalPages: metaData.totalPages,
                hasMore: metaData.hasMore,
              ),
            ),
          );

          // Apply additional sorting or filtering if needed
          if (search != null && search.isNotEmpty) {
            // For search results, improve relevance by prioritizing exact matches in title
            discoverResponse.searchResults.data.sort((a, b) {
              bool aExactMatch =
                  a.title.toLowerCase().contains(search.toLowerCase());
              bool bExactMatch =
                  b.title.toLowerCase().contains(search.toLowerCase());

              if (aExactMatch && !bExactMatch) return -1;
              if (!aExactMatch && bExactMatch) return 1;
              return 0;
            });
          }

          return discoverResponse;
        } catch (e, stackTrace) {
          logger.e('Error fetching discover comics',
              error: e, stackTrace: stackTrace, tag: 'OptimizedComicService');
          // Return empty result with pagination metadata to prevent UI crashes
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

  /// Get popular comics sorted by view count, vote count, or bookmark count
  Future<List<HomeComic>> getPopularComics({
    int page = 1,
    int limit = 10,
    String sortBy =
        'view_count', // 'view_count', 'vote_count', 'bookmark_count'
  }) async {
    return await performanceAsync(
      operationName: 'getPopularComics',
      function: () async {
        try {
          final result = await _repository.getDiscoverComics(
            page: page,
            limit: limit,
          );

          final List<HomeComic> comics = (result['data'] as List<dynamic>)
              .map((comic) => comic is HomeComic
                  ? comic
                  : HomeComic.fromJson(comic as Map<String, dynamic>))
              .toList();

          // Sort comics based on the requested metric
          switch (sortBy) {
            case 'vote_count':
              comics.sort((a, b) => b.voteCount.compareTo(a.voteCount));
              break;
            case 'bookmark_count':
              comics.sort((a, b) => b.bookmarkCount.compareTo(a.bookmarkCount));
              break;
            case 'view_count':
            default:
              comics.sort((a, b) => b.viewCount.compareTo(a.viewCount));
              break;
          }

          return comics;
        } catch (e, stackTrace) {
          logger.e('Error fetching popular comics',
              error: e, stackTrace: stackTrace, tag: 'OptimizedComicService');
          return []; // Return empty list instead of throwing
        }
      },
    );
  }
}
