import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/comment_model.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final Function(String)? onReply;
  final Function(String)? onViewReplies;
  final bool showReplies;
  final bool isReply;

  const CommentItem({
    Key? key,
    required this.comment,
    this.onReply,
    this.onViewReplies,
    this.showReplies = false,
    this.isReply = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasReplies = comment.replies != null && comment.replies!.isNotEmpty;
    final repliesCount = comment.replies?.length ?? 0;

    return Container(
      padding: EdgeInsets.only(
        left: isReply ? 40 : 16,
        right: 16,
        top: 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and timestamp
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 16,
                backgroundImage: comment.user?.avatarUrl != null
                    ? NetworkImage(comment.user!.avatarUrl!)
                    : null,
                child: comment.user?.avatarUrl == null
                    ? Text(
                        _getInitials(comment.user?.name ?? 'User'),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),

              const SizedBox(width: 8),

              // Username and timestamp
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user?.name ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      timeago.format(comment.createdDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Comment content
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              comment.content,
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Reply button and replies count
          if (!isReply)
            Row(
              children: [
                // Reply button
                if (onReply != null)
                  TextButton.icon(
                    onPressed: () => onReply!(comment.id),
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('Reply'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                const Spacer(),

                // View replies button
                if (hasReplies && onViewReplies != null && !showReplies)
                  TextButton.icon(
                    onPressed: () => onViewReplies!(comment.id),
                    icon: const Icon(Icons.comment, size: 16),
                    label: Text(
                        'View $repliesCount ${repliesCount == 1 ? 'reply' : 'replies'}'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),

          // Display replies if showReplies is true
          if (showReplies && hasReplies)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: comment.replies!.map((reply) {
                  return CommentReplyItem(reply: reply);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  // Get initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }
}

class CommentReplyItem extends StatelessWidget {
  final CommentReply reply;

  const CommentReplyItem({
    Key? key,
    required this.reply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 14,
            backgroundImage: reply.user.avatarUrl != null
                ? NetworkImage(reply.user.avatarUrl!)
                : null,
            child: reply.user.avatarUrl == null
                ? Text(
                    _getInitials(reply.user.name),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
                // Username and timestamp
                Row(
                  children: [
                    Text(
                      reply.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeago.format(reply.createdDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                // Reply content
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    reply.content,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Get initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name[0].toUpperCase();
    }
  }
}
