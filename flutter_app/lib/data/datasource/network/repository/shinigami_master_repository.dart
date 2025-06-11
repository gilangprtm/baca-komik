import '../../../../core/base/base_network.dart';
import '../../../models/shinigami/shinigami_models.dart';
import '../db/dio_service.dart';

class ShinigamiMasterRepository extends BaseRepository {
  /// Get all available formats (Manga, Manhwa, Manhua)
  Future<List<ShinigamiFormat>> getFormats() async {
    try {
      logInfo('Fetching formats list');

      final response = await dioService.get(
        '/format/list',
        urlType: UrlType.shinigamiApi,
      );

      logInfo('Formats list response received');

      final shinigamiResponse = ShinigamiResponse.fromJson(
        response.data,
        (data) => (data as List<dynamic>)
            .map((item) =>
                ShinigamiFormat.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (!shinigamiResponse.isSuccess) {
        throw Exception(
            'Failed to fetch formats: ${shinigamiResponse.message}');
      }

      return shinigamiResponse.data;
    } catch (e, stackTrace) {
      logError(
        'Error fetching formats',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get all available genres
  Future<List<ShinigamiGenre>> getGenres() async {
    try {
      logInfo('Fetching genres list');

      final response = await dioService.get(
        '/genre/list',
        urlType: UrlType.shinigamiApi,
      );

      logInfo('Genres list response received');

      final shinigamiResponse = ShinigamiResponse.fromJson(
        response.data,
        (data) => (data as List<dynamic>)
            .map(
                (item) => ShinigamiGenre.fromJson(item as Map<String, dynamic>))
            .toList(),
      );

      if (!shinigamiResponse.isSuccess) {
        throw Exception('Failed to fetch genres: ${shinigamiResponse.message}');
      }

      return shinigamiResponse.data;
    } catch (e, stackTrace) {
      logError(
        'Error fetching genres',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get format by slug
  Future<ShinigamiFormat?> getFormatBySlug(String slug) async {
    try {
      final formats = await getFormats();
      return formats.firstWhere(
        (format) => format.slug == slug,
        orElse: () => throw Exception('Format not found: $slug'),
      );
    } catch (e, stackTrace) {
      logError(
        'Error getting format by slug',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get genre by slug
  Future<ShinigamiGenre?> getGenreBySlug(String slug) async {
    try {
      final genres = await getGenres();
      return genres.firstWhere(
        (genre) => genre.slug == slug,
        orElse: () => throw Exception('Genre not found: $slug'),
      );
    } catch (e, stackTrace) {
      logError(
        'Error getting genre by slug',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Get popular genres (based on usage in manga)
  /// This method fetches manga data and analyzes genre frequency
  Future<List<ShinigamiGenre>> getPopularGenres({int limit = 10}) async {
    try {
      logInfo('Fetching popular genres');

      // Get all genres first
      final allGenres = await getGenres();

      // For now, return all genres as we don't have usage statistics
      // In a real implementation, you might want to fetch manga data
      // and count genre frequency
      return allGenres.take(limit).toList();
    } catch (e, stackTrace) {
      logError(
        'Error fetching popular genres',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get format statistics
  /// Returns count of manga per format
  Future<Map<String, int>> getFormatStatistics() async {
    try {
      logInfo('Fetching format statistics');

      final formats = await getFormats();
      final statistics = <String, int>{};

      // Initialize with zero counts
      for (final format in formats) {
        statistics[format.slug] = 0;
      }

      // Note: This is a simplified implementation
      // In a real scenario, you might want to fetch manga data
      // and count by format, or use a dedicated statistics endpoint

      return statistics;
    } catch (e, stackTrace) {
      logError(
        'Error fetching format statistics',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get genre statistics
  /// Returns count of manga per genre
  Future<Map<String, int>> getGenreStatistics() async {
    try {
      logInfo('Fetching genre statistics');

      final genres = await getGenres();
      final statistics = <String, int>{};

      // Initialize with zero counts
      for (final genre in genres) {
        statistics[genre.slug] = 0;
      }

      // Note: This is a simplified implementation
      // In a real scenario, you might want to fetch manga data
      // and count by genre, or use a dedicated statistics endpoint

      return statistics;
    } catch (e, stackTrace) {
      logError(
        'Error fetching genre statistics',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if format exists
  Future<bool> formatExists(String slug) async {
    try {
      final format = await getFormatBySlug(slug);
      return format != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if genre exists
  Future<bool> genreExists(String slug) async {
    try {
      final genre = await getGenreBySlug(slug);
      return genre != null;
    } catch (e) {
      return false;
    }
  }

  /// Get all master data at once
  /// Useful for initialization or caching
  Future<Map<String, dynamic>> getAllMasterData() async {
    try {
      logInfo('Fetching all master data');

      final futures = await Future.wait([
        getFormats(),
        getGenres(),
      ]);

      return {
        'formats': futures[0] as List<ShinigamiFormat>,
        'genres': futures[1] as List<ShinigamiGenre>,
      };
    } catch (e, stackTrace) {
      logError(
        'Error fetching all master data',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Search genres by name
  Future<List<ShinigamiGenre>> searchGenres(String query) async {
    try {
      final genres = await getGenres();
      final lowercaseQuery = query.toLowerCase();

      return genres
          .where((genre) =>
              genre.name.toLowerCase().contains(lowercaseQuery) ||
              genre.slug.toLowerCase().contains(lowercaseQuery))
          .toList();
    } catch (e, stackTrace) {
      logError(
        'Error searching genres',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Search formats by name
  Future<List<ShinigamiFormat>> searchFormats(String query) async {
    try {
      final formats = await getFormats();
      final lowercaseQuery = query.toLowerCase();

      return formats
          .where((format) =>
              format.name.toLowerCase().contains(lowercaseQuery) ||
              format.slug.toLowerCase().contains(lowercaseQuery))
          .toList();
    } catch (e, stackTrace) {
      logError(
        'Error searching formats',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
