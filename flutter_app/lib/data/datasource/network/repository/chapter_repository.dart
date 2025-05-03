import '../../../../core/base/base_network.dart';
import '../../../models/chapter_model.dart';
import '../../../models/page_model.dart';

class ChapterRepository extends BaseRepository {
  /// Get chapter details by ID
  Future<Chapter> getChapterDetails(String id) async {
    try {
      final response = await dioService.get('/chapters/$id');
      return Chapter.fromJson(response.data);
    } catch (e, stackTrace) {
      logError(
        'Error fetching chapter details',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get chapter pages by chapter ID
  Future<ChapterPages> getChapterPages(String chapterId) async {
    try {
      final response = await dioService.get('/chapters/$chapterId/pages');
      return ChapterPages.fromJson(response.data);
    } catch (e, stackTrace) {
      logError(
        'Error fetching chapter pages',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
