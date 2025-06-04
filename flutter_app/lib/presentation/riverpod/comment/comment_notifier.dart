import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/network/service/comment_service.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/pagination_model.dart';
import 'comment_state.dart';

class CommentNotifier extends BaseStateNotifier<CommentState> {
  final CommentService _commentService = CommentService();

  CommentNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();
    // Initialize with empty state
  }

  /// Set current content (comic or chapter) for comments
  void setCurrentContent(String id, CommentType type) {
    state = state.copyWith(
      currentId: id,
      currentType: type,
      comments: [], // Reset comments when changing content
      meta: null,
      status: CommentStateStatus.initial,
    );

    // Fetch comments for the new content
    fetchComments();
  }

  /// Fetch comments for the current content
  Future<void> fetchComments({bool refresh = false}) async {
    try {
      // Validate that we have a current ID and type
      if (state.currentId == null || state.currentType == null) {
        return;
      }

      // If refreshing, reset to initial page, otherwise keep current state
      final page = refresh ? 1 : (state.meta?.currentPage ?? 0) + 1;

      // Only show loading indicator on first page or refresh
      if (page == 1) {
        state = state.copyWith(status: CommentStateStatus.loading);
      } else {
        state = state.copyWith(isLoadingMore: true);
      }

      // Fetch comments from service
      final commentsResponse = await _commentService.getComments(
        id: state.currentId!,
        type: state.typeString,
        page: page,
        limit: 20,
        parentOnly: true, // Only get parent comments initially
      );

      // Extract data and metadata
      final List<Comment> comments = commentsResponse.data;
      final PaginationMeta meta = commentsResponse.meta;

      // If refreshing, replace the list, otherwise append
      final updatedComments =
          page == 1 ? comments : [...state.comments, ...comments];

      // Update state with new data
      state = state.copyWith(
        status: CommentStateStatus.success,
        comments: updatedComments,
        meta: meta,
        isLoadingMore: false,
        hasMore: page < meta.lastPage,
      );
    } catch (e, stackTrace) {
      logger.e('Error fetching comments', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        status: CommentStateStatus.error,
        errorMessage: 'Failed to load comments: ${e.toString()}',
        isLoadingMore: false,
      );
    }
  }

  /// Post a new comment
  Future<void> postComment(String content) async {
    try {
      // Validate that we have a current ID and type
      if (state.currentId == null || state.currentType == null) {
        return;
      }

      state = state.copyWith(isPosting: true);

      // Prepare parameters based on content type
      String? idKomik;
      String? idChapter;

      if (state.currentType == CommentType.comic) {
        idKomik = state.currentId;
      } else {
        idChapter = state.currentId;
      }

      // Post comment through service
      final comment = await _commentService.postComment(
        content: content,
        idKomik: idKomik,
        idChapter: idChapter,
      );

      // Add the new comment to the top of the list
      final updatedComments = [comment, ...state.comments];

      // Update state with new comment
      state = state.copyWith(
        comments: updatedComments,
        isPosting: false,
      );
    } catch (e, stackTrace) {
      logger.e('Error posting comment', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to post comment: ${e.toString()}',
        isPosting: false,
      );
    }
  }

  /// Post a reply to a comment
  Future<void> postReply(String content, String parentId) async {
    try {
      // Validate that we have a current ID and type
      if (state.currentId == null || state.currentType == null) {
        return;
      }

      state = state.copyWith(isPosting: true);

      // Prepare parameters based on content type
      String? idKomik;
      String? idChapter;

      if (state.currentType == CommentType.comic) {
        idKomik = state.currentId;
      } else {
        idChapter = state.currentId;
      }

      // Post reply through service
      final reply = await _commentService.postReply(
        content: content,
        parentId: parentId,
        idKomik: idKomik,
        idChapter: idChapter,
      );

      // Find the parent comment and add the reply
      final updatedComments = List<Comment>.from(state.comments);
      final parentIndex = updatedComments.indexWhere((c) => c.id == parentId);

      if (parentIndex != -1) {
        // Convert reply to CommentReply (if user is null, we can't create a CommentReply)
        if (reply.user == null) {
          state = state.copyWith(isPosting: false);
          return;
        }

        final commentReply = CommentReply(
          id: reply.id,
          content: reply.content,
          createdDate: reply.createdDate,
          user: reply.user!,
        );

        // Create a new parent comment with the reply added
        final parent = updatedComments[parentIndex];
        final replies = parent.replies ?? [];
        final updatedParent = Comment(
          id: parent.id,
          content: parent.content,
          idUser: parent.idUser,
          idKomik: parent.idKomik,
          idChapter: parent.idChapter,
          parentId: parent.parentId,
          createdDate: parent.createdDate,
          user: parent.user,
          replies: [...replies, commentReply],
        );

        // Replace the parent in the list
        updatedComments[parentIndex] = updatedParent;
      }

      // Update state with updated comments
      state = state.copyWith(
        comments: updatedComments,
        isPosting: false,
      );
    } catch (e, stackTrace) {
      logger.e('Error posting reply', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        errorMessage: 'Failed to post reply: ${e.toString()}',
        isPosting: false,
      );
    }
  }

  /// Load replies for a specific comment
  Future<void> loadReplies(String commentId) async {
    try {
      // Find the comment
      final commentIndex = state.comments.indexWhere((c) => c.id == commentId);
      if (commentIndex == -1) return;

      // Get the comment
      final comment = state.comments[commentIndex];

      // If replies are already loaded, no need to fetch again
      if (comment.replies != null && comment.replies!.isNotEmpty) return;

      state = state.copyWith(isLoadingMore: true);

      // Fetch comments with replies
      final result = await _commentService.getComments(
        id: commentId,
        type: 'reply', // Special type for replies
        limit: 50, // Get more replies at once
      );

      // Extract data
      final List<Comment> replies = result.data;

      // Convert replies to CommentReply objects (filter out replies without user)
      final commentReplies = replies
          .where((reply) => reply.user != null)
          .map((reply) => CommentReply(
                id: reply.id,
                content: reply.content,
                createdDate: reply.createdDate,
                user: reply.user!,
              ))
          .toList();

      // Create updated comment with replies
      final updatedComment = Comment(
        id: comment.id,
        content: comment.content,
        idUser: comment.idUser,
        idKomik: comment.idKomik,
        idChapter: comment.idChapter,
        parentId: comment.parentId,
        createdDate: comment.createdDate,
        user: comment.user,
        replies: commentReplies,
      );

      // Update the comment in the list
      final updatedComments = List<Comment>.from(state.comments);
      updatedComments[commentIndex] = updatedComment;

      state = state.copyWith(
        comments: updatedComments,
        isLoadingMore: false,
      );
    } catch (e, stackTrace) {
      logger.e('Error loading replies', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoadingMore: false,
      );
    }
  }
}
