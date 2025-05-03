import '../../../../core/base/base_network.dart';
import '../../../models/complete_chapter_model.dart';
import '../repository/optimized_chapter_repository.dart';

class OptimizedChapterService extends BaseService {
  final OptimizedChapterRepository _repository = OptimizedChapterRepository();

  /// Get complete chapter details including pages, navigation, and user data
  /// Uses the optimized /chapters/{id}/complete endpoint
  Future<CompleteChapter> getCompleteChapterDetails(String id) async {
    return await performanceAsync(
      operationName: 'getCompleteChapterDetails',
      function: () => _repository.getCompleteChapterDetails(id),
    );
  }
  
  /// Mark chapter as read
  Future<bool> markChapterAsRead(String chapterId) async {
    return await performanceAsync(
      operationName: 'markChapterAsRead',
      function: () => _repository.markChapterAsRead(chapterId),
    );
  }
  
  /// Track chapter reading progress and update UI
  Future<void> trackReadingProgress(String chapterId, String comicId) async {
    await performanceAsync(
      operationName: 'trackReadingProgress',
      function: () async {
        // Mark chapter as read in the backend
        await _repository.markChapterAsRead(chapterId);
        
        // Log tracking information
        logger.i('Tracking reading progress for chapter: $chapterId of comic: $comicId', 
          tag: 'OptimizedChapterService');
        return;
      },
    );
  }
}
