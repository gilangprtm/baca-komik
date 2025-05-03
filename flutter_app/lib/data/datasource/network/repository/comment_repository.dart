import '../../../../core/base/base_network.dart';
import '../../../models/comment_model.dart';

class CommentRepository extends BaseRepository {
  /// Get comments for comic or chapter
  Future<Map<String, dynamic>> getComments({
    required String id,
    String type = 'comic', // 'comic' or 'chapter'
    int page = 1,
    int limit = 10,
    bool parentOnly = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'type': type,
        'page': page,
        'limit': limit,
        'parent_only': parentOnly,
      };

      final response = await dioService.get(
        '/comments/$id',
        queryParameters: queryParams,
      );

      final List<Comment> comments = (response.data['data'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList();

      return {
        'data': comments,
        'meta': response.data['meta'],
      };
    } catch (e, stackTrace) {
      logError(
        'Error fetching comments',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Post a comment
  Future<Comment> postComment({
    required String content,
    String? idKomik,
    String? idChapter,
    String? parentId,
  }) async {
    try {
      final data = <String, dynamic>{
        'content': content,
      };

      if (idKomik != null) data['id_komik'] = idKomik;
      if (idChapter != null) data['id_chapter'] = idChapter;
      if (parentId != null) data['parent_id'] = parentId;

      final response = await dioService.post(
        '/comments',
        data: data,
      );

      return Comment.fromJson(response.data);
    } catch (e, stackTrace) {
      logError(
        'Error posting comment',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
