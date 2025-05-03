import '../../../../core/base/base_network.dart';
import '../repository/comment_repository.dart';
import '../../../models/comment_model.dart';

class CommentService extends BaseService {
  final CommentRepository _commentRepository = CommentRepository();
  
  /// Get comments for comic or chapter
  Future<Map<String, dynamic>> getComments({
    required String id,
    String type = 'comic', // 'comic' or 'chapter'
    int page = 1,
    int limit = 10,
    bool parentOnly = false,
  }) async {
    return await performanceAsync(
      operationName: 'getComments',
      function: () => _commentRepository.getComments(
        id: id,
        type: type,
        page: page,
        limit: limit,
        parentOnly: parentOnly,
      ),
    );
  }
  
  /// Post a comment
  Future<Comment> postComment({
    required String content,
    String? idKomik,
    String? idChapter,
    String? parentId,
  }) async {
    return await performanceAsync(
      operationName: 'postComment',
      function: () => _commentRepository.postComment(
        content: content,
        idKomik: idKomik,
        idChapter: idChapter,
        parentId: parentId,
      ),
    );
  }
  
  /// Post a reply to a comment
  Future<Comment> postReply({
    required String content,
    required String parentId,
    String? idKomik,
    String? idChapter,
  }) async {
    return await performanceAsync(
      operationName: 'postReply',
      function: () => _commentRepository.postComment(
        content: content,
        parentId: parentId,
        idKomik: idKomik,
        idChapter: idChapter,
      ),
    );
  }
  
  /// Get comments with replies for a specific comic or chapter
  Future<List<Comment>> getCommentsWithReplies({
    required String id,
    String type = 'comic',
    int page = 1,
  }) async {
    return await performanceAsync(
      operationName: 'getCommentsWithReplies',
      function: () async {
        final result = await _commentRepository.getComments(
          id: id,
          type: type,
          page: page,
          parentOnly: false, // Get all comments including replies
        );
        
        return result['data'] as List<Comment>;
      },
    );
  }
}
