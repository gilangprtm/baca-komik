import 'commento_comment_model.dart';

/// Base response model for Commento API
class CommentoResponse<T> {
  final int errno;
  final String errmsg;
  final T data;

  CommentoResponse({
    required this.errno,
    required this.errmsg,
    required this.data,
  });

  factory CommentoResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return CommentoResponse<T>(
      errno: json['errno'] ?? 0,
      errmsg: json['errmsg'] ?? '',
      data: fromJsonT(json['data']),
    );
  }

  bool get isSuccess => errno == 0;
  bool get hasError => errno != 0;
}

/// Paginated comment list response for Commento API
class CommentoCommentListResponse {
  final int page;
  final int totalPages;
  final int pageSize;
  final int count;
  final List<CommentoComment> data;

  CommentoCommentListResponse({
    required this.page,
    required this.totalPages,
    required this.pageSize,
    required this.count,
    required this.data,
  });

  factory CommentoCommentListResponse.fromJson(Map<String, dynamic> json) {
    return CommentoCommentListResponse(
      page: json['page'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      count: json['count'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => CommentoComment.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'totalPages': totalPages,
      'pageSize': pageSize,
      'count': count,
      'data': data.map((comment) => comment.toJson()).toList(),
    };
  }

  // Helper getters for pagination
  bool get hasMore => page < totalPages;
  bool get isFirstPage => page == 1;
  bool get isLastPage => page == totalPages;
  int get nextPage => hasMore ? page + 1 : page;
  int get prevPage => page > 1 ? page - 1 : 1;

  /// Get all root comments (level 0, not replies)
  List<CommentoComment> get rootComments {
    return data.where((comment) => comment.isRootComment).toList();
  }

  /// Get total comment count including all replies
  int get totalCommentCount {
    int total = data.length;
    for (final comment in data) {
      total += comment.totalReplyCount;
    }
    return total;
  }

  /// Check if there are any comments
  bool get hasComments => data.isNotEmpty;

  /// Check if response is empty
  bool get isEmpty => data.isEmpty;

  // Helper method to create empty response
  static CommentoCommentListResponse empty() {
    return CommentoCommentListResponse(
      page: 1,
      totalPages: 0,
      pageSize: 10,
      count: 0,
      data: [],
    );
  }

  @override
  String toString() {
    return 'CommentoCommentListResponse(page: $page/$totalPages, count: $count, comments: ${data.length})';
  }
}

/// Complete Commento API response wrapper
class CommentoCommentResponse extends CommentoResponse<CommentoCommentListResponse> {
  CommentoCommentResponse({
    required super.errno,
    required super.errmsg,
    required super.data,
  });

  factory CommentoCommentResponse.fromJson(Map<String, dynamic> json) {
    return CommentoCommentResponse(
      errno: json['errno'] ?? 0,
      errmsg: json['errmsg'] ?? '',
      data: CommentoCommentListResponse.fromJson(json['data'] ?? {}),
    );
  }

  /// Get comments from response data
  List<CommentoComment> get comments => data.data;

  /// Get pagination info
  CommentoCommentListResponse get pagination => data;

  /// Check if there are comments
  bool get hasComments => data.hasComments;

  /// Helper method to create empty response
  static CommentoCommentResponse empty() {
    return CommentoCommentResponse(
      errno: 0,
      errmsg: '',
      data: CommentoCommentListResponse.empty(),
    );
  }

  @override
  String toString() {
    return 'CommentoCommentResponse(success: $isSuccess, comments: ${comments.length}, pagination: $pagination)';
  }
}
