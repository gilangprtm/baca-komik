import '../../../../core/base/base_network.dart';
import '../../../models/shinigami/shinigami_models.dart';
import '../repository/shinigami_repositories.dart';

class ShinigamiMasterService extends BaseService {
  final ShinigamiMasterRepository _repository = ShinigamiMasterRepository();

  /// Get all available formats (Manga, Manhwa, Manhua)
  Future<List<ShinigamiFormat>> getFormats() async {
    return await performanceAsync(
      operationName: 'getFormats',
      function: () => _repository.getFormats(),
    );
  }

  /// Get all available genres
  Future<List<ShinigamiGenre>> getGenres() async {
    return await performanceAsync(
      operationName: 'getGenres',
      function: () => _repository.getGenres(),
    );
  }

  /// Get format by slug
  Future<ShinigamiFormat?> getFormatBySlug(String slug) async {
    return await performanceAsync(
      operationName: 'getFormatBySlug',
      function: () => _repository.getFormatBySlug(slug),
    );
  }

  /// Get genre by slug
  Future<ShinigamiGenre?> getGenreBySlug(String slug) async {
    return await performanceAsync(
      operationName: 'getGenreBySlug',
      function: () => _repository.getGenreBySlug(slug),
    );
  }

  /// Get popular genres (based on usage in manga)
  Future<List<ShinigamiGenre>> getPopularGenres({int limit = 10}) async {
    return await performanceAsync(
      operationName: 'getPopularGenres',
      function: () => _repository.getPopularGenres(limit: limit),
    );
  }

  /// Get all master data at once
  /// Useful for initialization or caching
  Future<Map<String, dynamic>> getAllMasterData() async {
    return await performanceAsync(
      operationName: 'getAllMasterData',
      function: () => _repository.getAllMasterData(),
    );
  }

  /// Search genres by name
  Future<List<ShinigamiGenre>> searchGenres(String query) async {
    return await performanceAsync(
      operationName: 'searchGenres',
      function: () => _repository.searchGenres(query),
    );
  }

  /// Search formats by name
  Future<List<ShinigamiFormat>> searchFormats(String query) async {
    return await performanceAsync(
      operationName: 'searchFormats',
      function: () => _repository.searchFormats(query),
    );
  }

  /// Get format statistics
  /// Returns count of manga per format
  Future<Map<String, int>> getFormatStatistics() async {
    return await performanceAsync(
      operationName: 'getFormatStatistics',
      function: () => _repository.getFormatStatistics(),
    );
  }

  /// Get genre statistics
  /// Returns count of manga per genre
  Future<Map<String, int>> getGenreStatistics() async {
    return await performanceAsync(
      operationName: 'getGenreStatistics',
      function: () => _repository.getGenreStatistics(),
    );
  }

  /// Check if format exists
  Future<bool> formatExists(String slug) async {
    return await performanceAsync(
      operationName: 'formatExists',
      function: () => _repository.formatExists(slug),
    );
  }

  /// Check if genre exists
  Future<bool> genreExists(String slug) async {
    return await performanceAsync(
      operationName: 'genreExists',
      function: () => _repository.genreExists(slug),
    );
  }

  /// Initialize master data cache
  /// Fetches and caches all master data for better performance
  Future<Map<String, dynamic>> initializeMasterDataCache() async {
    return await performanceAsync(
      operationName: 'initializeMasterDataCache',
      function: () async {
        try {
          final masterData = await _repository.getAllMasterData();

          return masterData;
        } catch (e, stackTrace) {
          logger.e(
            'Error initializing master data cache',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiMasterService',
          );

          // Return empty data on error
          return {
            'formats': <ShinigamiFormat>[],
            'genres': <ShinigamiGenre>[],
          };
        }
      },
    );
  }

  /// Get filter options for UI
  /// Returns formatted data for filter dropdowns and selections
  Future<Map<String, dynamic>> getFilterOptions() async {
    return await performanceAsync(
      operationName: 'getFilterOptions',
      function: () async {
        try {
          final masterData = await _repository.getAllMasterData();
          final formats = masterData['formats'] as List<ShinigamiFormat>;
          final genres = masterData['genres'] as List<ShinigamiGenre>;

          return {
            'formats': formats
                .map((format) => {
                      'value': format.slug,
                      'label': format.name,
                    })
                .toList(),
            'genres': genres
                .map((genre) => {
                      'value': genre.slug,
                      'label': genre.name,
                    })
                .toList(),
          };
        } catch (e, stackTrace) {
          logger.e(
            'Error getting filter options',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiMasterService',
          );

          return {
            'formats': <Map<String, String>>[],
            'genres': <Map<String, String>>[],
          };
        }
      },
    );
  }

  /// Validate filter values
  /// Checks if provided filter values are valid
  Future<Map<String, bool>> validateFilterValues({
    String? format,
    String? genre,
  }) async {
    return await performanceAsync(
      operationName: 'validateFilterValues',
      function: () async {
        try {
          final results = await Future.wait([
            format != null
                ? _repository.formatExists(format)
                : Future.value(true),
            genre != null ? _repository.genreExists(genre) : Future.value(true),
          ]);

          return {
            'format_valid': results[0],
            'genre_valid': results[1],
            'all_valid': results[0] && results[1],
          };
        } catch (e, stackTrace) {
          logger.e(
            'Error validating filter values',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiMasterService',
          );

          return {
            'format_valid': false,
            'genre_valid': false,
            'all_valid': false,
          };
        }
      },
    );
  }

  /// Get master data summary
  /// Returns summary information about available master data
  Future<Map<String, dynamic>> getMasterDataSummary() async {
    return await performanceAsync(
      operationName: 'getMasterDataSummary',
      function: () async {
        try {
          final masterData = await _repository.getAllMasterData();
          final formats = masterData['formats'] as List<ShinigamiFormat>;
          final genres = masterData['genres'] as List<ShinigamiGenre>;

          return {
            'total_formats': formats.length,
            'total_genres': genres.length,
            'format_names': formats.map((f) => f.name).toList(),
            'genre_names': genres.map((g) => g.name).toList(),
            'last_updated': DateTime.now().toIso8601String(),
          };
        } catch (e, stackTrace) {
          logger.e(
            'Error getting master data summary',
            error: e,
            stackTrace: stackTrace,
            tag: 'ShinigamiMasterService',
          );

          return {
            'total_formats': 0,
            'total_genres': 0,
            'format_names': <String>[],
            'genre_names': <String>[],
            'last_updated': DateTime.now().toIso8601String(),
          };
        }
      },
    );
  }
}
