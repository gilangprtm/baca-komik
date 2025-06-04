import 'comment_model.dart';
import 'pagination_model.dart';

class CommentsResponse {
  final List<Comment> data;
  final PaginationMeta meta;

  CommentsResponse({
    required this.data,
    required this.meta,
  });

  factory CommentsResponse.fromJson(Map<String, dynamic> json) {
    final List<Comment> comments = json['data'] is List
        ? (json['data'] as List)
            .map((c) =>
                c is Comment ? c : Comment.fromJson(c as Map<String, dynamic>))
            .toList()
        : [];

    return CommentsResponse(
      data: comments,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  // For empty responses or error handling
  factory CommentsResponse.empty(int page, int limit) {
    return CommentsResponse(
      data: <Comment>[],
      meta: PaginationMeta.empty(page, limit),
    );
  }
}
