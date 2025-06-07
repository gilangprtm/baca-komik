import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../../data/models/comment_model.dart';
import '../../../riverpod/comic/comic_provider.dart';
import '../../../riverpod/comic/comic_state.dart';

class CommentsTab extends ConsumerWidget {
  const CommentsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch comments to optimize rebuilds
    final comments = ref.watch(
      comicProvider.select((state) => state.comments),
    );

    // Check if we have comments to display
    if (comments.isNotEmpty) {
      return _CommentsListView(comments: comments);
    }

    // Show loading or empty state
    return const _CommentsEmptyState();
  }
}

/// Optimized comments list view
class _CommentsListView extends StatelessWidget {
  final List<Comment> comments;

  const _CommentsListView({required this.comments});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: comments.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      child: Text(comment.user?.name.substring(0, 1) ?? '?'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.user?.name ?? 'Unknown User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Posted on ${comment.createdDate.day}/${comment.createdDate.month}/${comment.createdDate.year}',
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
                const SizedBox(height: 8),
                Text(comment.content),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Optimized empty state widget
class _CommentsEmptyState extends ConsumerWidget {
  const _CommentsEmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get comic ID from arguments
    final String? comicId = Mahas.argument<String>('comicId');

    // Watch comment status to show appropriate message
    final commentStatus = ref.watch(
      comicProvider.select((state) => state.commentStatus),
    );

    if (commentStatus == ComicStateStatus.loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading comments...'),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.comment, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Komentar akan segera hadir',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat komentar untuk komik ${comicId ?? "ini"}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Load comments
              ref.read(comicProvider.notifier).fetchComments(1);
            },
            child: const Text('Muat Komentar'),
          ),
        ],
      ),
    );
  }
}
