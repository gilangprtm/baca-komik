import '../../../../core/base/base_network.dart';
import '../../../models/complete_chapter_model.dart';

class OptimizedChapterRepository extends BaseRepository {
  /// Get complete chapter details including pages, navigation, and user data
  /// Uses the optimized /chapters/{id}/complete endpoint
  Future<CompleteChapter> getCompleteChapterDetails(String id) async {
    try {
      final response = await dioService.get('/chapters/$id/complete');
      return CompleteChapter.fromJson(response.data);
    } catch (e, stackTrace) {
      logError(
        'Error fetching complete chapter details',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// Mark chapter as read
  Future<bool> markChapterAsRead(String chapterId) async {
    try {
      final response = await dioService.post(
        '/chapters/$chapterId/read',
        data: {
          'is_read': true,
        },
      );
      return response.data['success'] ?? false;
    } catch (e, stackTrace) {
      logError(
        'Error marking chapter as read',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
