import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/shinigami/shinigami_models.dart';

/// Reusable comment widget that can be used for both comic and chapter comments
class CommentWidget extends StatelessWidget {
  final List<CommentoComment> comments;
  final int totalCount;
  final bool isLoading;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;
  final String emptyMessage;
  final bool showCommentCount;

  const CommentWidget({
    Key? key,
    required this.comments,
    required this.totalCount,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.onRefresh,
    this.emptyMessage = 'No comments yet',
    this.showCommentCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _CommentLoadingView();
    }

    if (comments.isEmpty) {
      return _CommentEmptyView(message: emptyMessage);
    }

    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: _CommentListView(
        comments: comments,
        totalCount: totalCount,
        isLoadingMore: isLoadingMore,
        onLoadMore: onLoadMore,
        showCommentCount: showCommentCount,
      ),
    );
  }
}

class _CommentLoadingView extends StatelessWidget {
  const _CommentLoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.getTextPrimaryColor(context),
          ),
          SizedBox(height: 16),
          Text(
            'Loading comments...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentEmptyView extends StatelessWidget {
  final String message;

  const _CommentEmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.comment_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Be the first to comment!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentListView extends StatefulWidget {
  final List<CommentoComment> comments;
  final int totalCount;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final bool showCommentCount;

  const _CommentListView({
    required this.comments,
    required this.totalCount,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.showCommentCount = true,
  });

  @override
  State<_CommentListView> createState() => _CommentListViewState();
}

class _CommentListViewState extends State<_CommentListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more comments when near bottom
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showCommentCount)
          // Comment count header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Text(
              '${widget.totalCount} Comments',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Comments list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.comments.length + (widget.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget.comments.length) {
                // Loading indicator at bottom
                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                  ),
                );
              }

              final comment = widget.comments[index];
              return CommentItem(comment: comment);
            },
          ),
        ),
      ],
    );
  }
}

class CommentItem extends StatelessWidget {
  final CommentoComment comment;

  const CommentItem({Key? key, required this.comment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and timestamp
            Row(
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage: comment.avatar.isNotEmpty
                      ? NetworkImage(comment.avatar)
                      : null,
                  child: comment.avatar.isEmpty
                      ? Text(
                          comment.nick.isNotEmpty
                              ? comment.nick[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // User name and timestamp
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.nick,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTimestamp(comment.dateTime),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Like count
                if (comment.like > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.red[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        comment.like.toString(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Comment content with HTML support
            CommentContent(comment: comment),

            // Replies with read more functionality
            if (comment.hasReplies) ...[
              const SizedBox(height: 12),
              CommentRepliesSection(comment: comment),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class CommentRepliesSection extends StatefulWidget {
  final CommentoComment comment;

  const CommentRepliesSection({Key? key, required this.comment})
      : super(key: key);

  @override
  State<CommentRepliesSection> createState() => _CommentRepliesSectionState();
}

class _CommentRepliesSectionState extends State<CommentRepliesSection> {
  bool _showAllReplies = false;
  static const int _maxVisibleReplies = 2;

  @override
  Widget build(BuildContext context) {
    final replies = widget.comment.children;
    final hasMoreReplies = replies.length > _maxVisibleReplies;
    final visibleReplies =
        _showAllReplies ? replies : replies.take(_maxVisibleReplies).toList();

    return Container(
      margin: const EdgeInsets.only(left: 20),
      padding: const EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visible replies
          ...visibleReplies.map((reply) => CommentReply(reply: reply)),

          // Read more / Show less button
          if (hasMoreReplies)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllReplies = !_showAllReplies;
                  });
                },
                child: Text(
                  _showAllReplies
                      ? 'Show less replies'
                      : 'Show ${replies.length - _maxVisibleReplies} more replies',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CommentReply extends StatelessWidget {
  final CommentoComment reply;

  const CommentReply({Key? key, required this.reply}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply avatar (smaller)
          CircleAvatar(
            radius: 12,
            backgroundImage:
                reply.avatar.isNotEmpty ? NetworkImage(reply.avatar) : null,
            child: reply.avatar.isEmpty
                ? Text(
                    reply.nick.isNotEmpty ? reply.nick[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),

          // Reply content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reply user and timestamp
                Row(
                  children: [
                    Text(
                      reply.nick,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(reply.dateTime),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Reply text with HTML support
                CommentContent(
                  comment: reply,
                  fontSize: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class CommentContent extends StatelessWidget {
  final CommentoComment comment;
  final double fontSize;

  const CommentContent({
    Key? key,
    required this.comment,
    this.fontSize = 14,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if content has HTML (contains < and > characters)
    final hasHtml =
        comment.htmlContent.contains('<') && comment.htmlContent.contains('>');

    if (hasHtml) {
      // Render HTML content with emoji support
      return Html(
        data: comment.htmlContent,
        style: {
          "body": Style(
            fontSize: FontSize(fontSize),
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
          ),
          "img": Style(
            width: Width(20),
            height: Height(20),
            display: Display.inlineBlock,
            verticalAlign: VerticalAlign.middle,
          ),
        },
        onLinkTap: (url, attributes, element) {
          // Handle link taps if needed
          // For now, we'll just ignore them
        },
      );
    } else {
      // Fallback to plain text if no HTML
      return Text(
        comment.plainTextContent,
        style: TextStyle(fontSize: fontSize),
      );
    }
  }
}
