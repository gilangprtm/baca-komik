import '../../../../core/base/base_network.dart';
import '../../../models/comic_model.dart';
import '../../../models/home_comic_model.dart';
import '../../../models/comics_response_model.dart';
import '../../../models/comic_chapters_response_model.dart';
import '../../../models/featured_comics_response_model.dart';
import '../repository/comic_repository.dart';
import '../repository/optimized_comic_repository.dart';

class ComicService extends BaseService {
  final ComicRepository _comicRepository = ComicRepository();
  final OptimizedComicRepository _optimizedComicRepository =
      OptimizedComicRepository();

  /// Get all comics with pagination and filtering
  Future<ComicsResponse> getComics({
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
      function: () async {
        try {
          final result = await _comicRepository.getComics(
            page: page,
            limit: limit,
            search: search,
            sort: sort,
            order: order,
            genre: genre,
            status: status,
          );

          return ComicsResponse.fromJson(result);
        } catch (e, stackTrace) {
          logger.e('Error fetching comics',
              error: e, stackTrace: stackTrace, tag: 'ComicService');
          return ComicsResponse.empty(page, limit);
        }
      },
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
  /// Returns a structured response with comic info, chapters list, and pagination metadata
  Future<ComicChaptersResponse> getComicChapters({
    required String comicId,
    int page = 1,
    int limit = 20,
    String sort = 'chapter_number',
    String order = 'desc',
  }) async {
    return await performanceAsync(
      operationName: 'getComicChapters',
      function: () async {
        try {
          // Get raw data from repository
          final rawData = await _comicRepository.getComicChapters(
            comicId: comicId,
            page: page,
            limit: limit,
            sort: sort,
            order: order,
          );

          // Convert to structured model
          return ComicChaptersResponse.fromJson(rawData);
        } catch (e, stackTrace) {
          logger.e('Error fetching comic chapters',
              error: e, stackTrace: stackTrace, tag: 'ComicService');
          return ComicChaptersResponse.empty(page, limit);
        }
      },
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
        try {
          final result = await _comicRepository.getComics(
            search: query,
            limit: 10,
          );

          final comicsResponse = ComicsResponse.fromJson(result);
          return comicsResponse.data;
        } catch (e, stackTrace) {
          logger.e('Error searching comics',
              error: e, stackTrace: stackTrace, tag: 'ComicService');
          return [];
        }
      },
    );
  }

  /// Get featured comics (recommended and popular)
  Future<FeaturedComicsResponse> getFeaturedComics() async {
    return await performanceAsync(
      operationName: 'getFeaturedComics',
      function: () async {
        try {
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

          // Convert responses to proper models
          final recommendedResponse =
              ComicsResponse.fromJson(recommendedResult);
          final popularResponse = ComicsResponse.fromJson(popularResult);

          return FeaturedComicsResponse(
            recommended: recommendedResponse.data,
            popular: popularResponse.data,
          );
        } catch (e, stackTrace) {
          logger.e('Error fetching featured comics',
              error: e, stackTrace: stackTrace, tag: 'ComicService');
          return FeaturedComicsResponse.empty();
        }
      },
    );
  }

  /// Get latest updated comics
  Future<List<Comic>> getLatestComics() async {
    return await performanceAsync(
      operationName: 'getLatestComics',
      function: () async {
        try {
          final result = await _comicRepository.getComics(
            sort: 'updated_date',
            order: 'desc',
            limit: 20,
          );

          final comicsResponse = ComicsResponse.fromJson(result);
          return comicsResponse.data;
        } catch (e, stackTrace) {
          logger.e('Error fetching latest comics',
              error: e, stackTrace: stackTrace, tag: 'ComicService');
          return [];
        }
      },
    );
  }

  /// Get home comics with their latest chapters
  /// This is a specialized method for the home page that returns HomeComic objects
  /// with their latest chapters already included
  /// Uses the optimized /comics/home endpoint
  Future<List<HomeComic>> getHomeComics({int page = 1, int limit = 20}) async {
    return await performanceAsync(
      operationName: 'getHomeComics',
      function: () async {
        try {
          // Use the optimized repository that directly accesses the /comics/home endpoint
          final result = await _optimizedComicRepository.getHomeComics(
            page: page,
            limit: limit,
          );

          // The optimized repository already returns properly typed HomeComic objects
          final homeComics = result['data'] as List<dynamic>;
          return homeComics
              .map((comic) => comic is HomeComic
                  ? comic
                  : HomeComic.fromJson(comic as Map<String, dynamic>))
              .toList();
        } catch (e, stackTrace) {
          // If the optimized endpoint fails, log the error
          logger.e('Error fetching home comics from optimized endpoint',
              error: e, stackTrace: stackTrace, tag: 'ComicService');

          // Fall back to the old method of fetching comics and chapters separately
          logger.i('Falling back to non-optimized endpoints',
              tag: 'ComicService');

          // Get comics without latest chapters
          final result = await _comicRepository.getComics(
            page: page,
            limit: limit,
            // Don't use updated_date since it's causing the error
            sort: 'created_date',
            order: 'desc',
          );

          final comicsResponse = ComicsResponse.fromJson(result);
          final comics = comicsResponse.data;

          // Convert to HomeComic with latest chapters
          final List<HomeComic> homeComics = [];

          for (final comic in comics) {
            // Get latest chapters for this comic
            final chaptersResponse = await getComicChapters(
              comicId: comic.id,
              limit: 2,
            );

            final chapters = chaptersResponse.chapters;

            // Create HomeComic with latest chapters
            final homeComic = HomeComic(
              id: comic.id,
              title: comic.title,
              alternativeTitle: comic.alternativeTitle,
              synopsis: comic.synopsis,
              status: comic.status,
              viewCount: comic.viewCount,
              voteCount: comic.voteCount,
              bookmarkCount: comic.bookmarkCount,
              coverImageUrl: comic.coverImageUrl,
              createdDate: comic.createdDate,
              updatedDate: comic.updatedDate,
              chapterCount: chapters.length,
              genres: comic.genres?.map((g) => g).toList() ?? [],
              latestChapters: chapters,
            );

            homeComics.add(homeComic);
          }

          return homeComics;
        }
      },
    );
  }
}
