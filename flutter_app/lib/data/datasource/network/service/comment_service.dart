import '../../../../core/base/base_network.dart';
import '../repository/comment_repository.dart';
import '../../../models/comment_model.dart';
import '../../../models/comments_response_model.dart';

class CommentService extends BaseService {
  final CommentRepository _commentRepository = CommentRepository();

  /// Get comments for comic or chapter with enhanced error handling
  /// and data processing
  Future<CommentsResponse> getComments({
    required String id,
    String type = 'comic', // 'comic' or 'chapter'
    int page = 1,
    int limit = 10,
    bool parentOnly = false,
  }) async {
    return await performanceAsync(
      operationName: 'getComments',
      function: () async {
        try {
          final result = await _commentRepository.getComments(
            id: id,
            type: type,
            page: page,
            limit: limit,
            parentOnly: parentOnly,
          );

          // Create and process CommentsResponse
          final commentsResponse = CommentsResponse.fromJson(result);

          // Sort comments by date (newest first)
          commentsResponse.data
              .sort((a, b) => b.createdDate.compareTo(a.createdDate));

          return commentsResponse;
        } catch (e, stackTrace) {
          logger.e('Error fetching comments',
              error: e, stackTrace: stackTrace, tag: 'CommentService');

          // Return empty result with pagination metadata to prevent UI crashes
          return CommentsResponse.empty(page, limit);
        }
      },
    );
  }

  /// Post a comment with validation and error handling
  Future<Comment> postComment({
    required String content,
    String? idKomik,
    String? idChapter,
    String? parentId,
  }) async {
    return await performanceAsync(
      operationName: 'postComment',
      function: () async {
        try {
          // Validate input parameters
          if (content.trim().isEmpty) {
            throw Exception('Comment content cannot be empty');
          }

          if (idKomik == null && idChapter == null) {
            throw Exception('Either comic ID or chapter ID must be provided');
          }

          // Trim content to remove extra whitespace
          final trimmedContent = content.trim();

          // Process content if needed (e.g., filter profanity, format mentions)
          final processedContent = _processCommentContent(trimmedContent);

          // Post the comment via repository
          final comment = await _commentRepository.postComment(
            content: processedContent,
            idKomik: idKomik,
            idChapter: idChapter,
            parentId: parentId,
          );

          return comment;
        } catch (e, stackTrace) {
          logger.e('Error posting comment',
              error: e, stackTrace: stackTrace, tag: 'CommentService');
          rethrow; // Re-throw to allow UI to handle the error
        }
      },
    );
  }

  /// Post a reply to a comment with validation
  Future<Comment> postReply({
    required String content,
    required String parentId,
    String? idKomik,
    String? idChapter,
  }) async {
    return await performanceAsync(
      operationName: 'postReply',
      function: () async {
        try {
          // Validate input parameters
          if (content.trim().isEmpty) {
            throw Exception('Reply content cannot be empty');
          }

          if (parentId.isEmpty) {
            throw Exception('Parent comment ID is required');
          }

          // Process content (same as for regular comments)
          final processedContent = _processCommentContent(content.trim());

          // Post the reply via repository
          final reply = await _commentRepository.postComment(
            content: processedContent,
            parentId: parentId,
            idKomik: idKomik,
            idChapter: idChapter,
          );

          return reply;
        } catch (e, stackTrace) {
          logger.e('Error posting reply',
              error: e, stackTrace: stackTrace, tag: 'CommentService');
          rethrow; // Re-throw to allow UI to handle the error
        }
      },
    );
  }

  /// Get comments with replies organized in a hierarchical structure
  Future<List<CommentThread>> getCommentsWithReplies({
    required String id,
    String type = 'comic',
    int page = 1,
    int limit = 20,
  }) async {
    return await performanceAsync(
      operationName: 'getCommentsWithReplies',
      function: () async {
        try {
          // Get all comments including replies
          final result = await _commentRepository.getComments(
            id: id,
            type: type,
            page: page,
            limit: limit,
            parentOnly: false, // Get all comments including replies
          );

          final List<Comment> allComments = (result['data'] as List)
              .map((c) => c is Comment
                  ? c
                  : Comment.fromJson(c as Map<String, dynamic>))
              .toList();

          // Organize comments into threads
          final Map<String, CommentThread> threads = {};
          final List<CommentThread> rootThreads = [];

          // First pass: identify parent comments
          for (final comment in allComments) {
            if (comment.parentId == null || comment.parentId!.isEmpty) {
              // This is a parent comment
              final thread = CommentThread(
                parentComment: comment,
                replies: [],
              );
              threads[comment.id] = thread;
              rootThreads.add(thread);
            }
          }

          // Second pass: organize replies under their parents
          for (final comment in allComments) {
            if (comment.parentId != null && comment.parentId!.isNotEmpty) {
              // This is a reply
              final parentThread = threads[comment.parentId];
              if (parentThread != null) {
                parentThread.replies.add(comment);
              } else {
                // Create a new thread if parent doesn't exist yet
                // (this can happen if API returns children but not parents)
                logger.w(
                    'Reply found without parent, creating placeholder thread',
                    tag: 'CommentService');

                final now = DateTime.now();

                // Create placeholder parent with required fields
                final placeholderParent = Comment(
                  id: comment.parentId!,
                  content: '[Comment not available]',
                  idUser: 'system',
                  createdDate: now,
                );

                final newThread = CommentThread(
                  parentComment: placeholderParent,
                  replies: [comment],
                );

                threads[placeholderParent.id] = newThread;
                rootThreads.add(newThread);
              }
            }
          }

          // Sort threads by most recent first
          rootThreads.sort((a, b) => b.parentComment.createdDate
              .compareTo(a.parentComment.createdDate));

          // Sort replies within each thread
          for (final thread in rootThreads) {
            thread.replies
                .sort((a, b) => a.createdDate.compareTo(b.createdDate));
          }

          return rootThreads;
        } catch (e, stackTrace) {
          logger.e('Error organizing comments into threads',
              error: e, stackTrace: stackTrace, tag: 'CommentService');
          return []; // Return empty list instead of throwing
        }
      },
    );
  }

  /// Delete a comment (if permitted)
  Future<bool> deleteComment(String commentId) async {
    return await performanceAsync(
      operationName: 'deleteComment',
      function: () async {
        try {
          // In a real app, you would implement this
          // await _commentRepository.deleteComment(commentId);

          logger.i('Deleting comment: $commentId', tag: 'CommentService');

          // For now, simulate success
          return true;
        } catch (e, stackTrace) {
          logger.e('Error deleting comment',
              error: e, stackTrace: stackTrace, tag: 'CommentService');
          return false;
        }
      },
    );
  }

  /// Helper method to process comment content
  String _processCommentContent(String content) {
    // In a real app, this would implement:
    // - Profanity filtering
    // - Mention formatting
    // - Link detection
    // - Emoji processing

    // For now, just return the content as-is
    return content;
  }
}

/// A class to organize comments into threads with replies
class CommentThread {
  final Comment parentComment;
  final List<Comment> replies;

  CommentThread({
    required this.parentComment,
    required this.replies,
  });
}
