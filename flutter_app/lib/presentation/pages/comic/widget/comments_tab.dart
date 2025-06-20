import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../riverpod/comic/comic_provider.dart';
import '../../../riverpod/comic/comic_state.dart';
import '../../../widgets/common/comment_widget.dart';

class CommentsTab extends StatelessWidget {
  const CommentsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Watch comment status to determine what to show
        final commentStatus = ref.watch(
          comicProvider.select((state) => state.commentStatus),
        );

        switch (commentStatus) {
          case ComicStateStatus.initial:
            // Auto-fetch comments when tab is first loaded
            return const _CommentInitialView();

          case ComicStateStatus.loading:
            return CommentWidget(
              comments: const [],
              totalCount: 0,
              isLoading: true,
            );

          case ComicStateStatus.success:
            return Consumer(
              builder: (context, ref, _) {
                final comments = ref.watch(
                  comicProvider.select((state) => state.comments),
                );
                final totalCommentCount = ref.watch(
                  comicProvider.select((state) => state.totalCommentCount),
                );
                final isLoadingMore = ref.watch(
                  comicProvider.select((state) => state.isLoadingMoreComments),
                );

                return CommentWidget(
                  comments: comments,
                  totalCount: totalCommentCount,
                  isLoadingMore: isLoadingMore,
                  onLoadMore: () {
                    ref.read(comicProvider.notifier).loadMoreComments();
                  },
                  onRefresh: () async {
                    await ref.read(comicProvider.notifier).refreshComments();
                  },
                  emptyMessage: 'No comments yet for this manga',
                );
              },
            );

          case ComicStateStatus.error:
            return const _CommentErrorView();
        }
      },
    );
  }
}

class _CommentInitialView extends StatefulWidget {
  const _CommentInitialView();

  @override
  State<_CommentInitialView> createState() => _CommentInitialViewState();
}

class _CommentInitialViewState extends State<_CommentInitialView> {
  @override
  void initState() {
    super.initState();
    // Fetch comments after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final ref = ProviderScope.containerOf(context);
        ref.read(comicProvider.notifier).fetchComments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommentWidget(
      comments: const [],
      totalCount: 0,
      isLoading: true,
    );
  }
}

// Error view for comments
class _CommentErrorView extends StatelessWidget {
  const _CommentErrorView();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final errorMessage = ref.watch(
          comicProvider.select((state) => state.errorMessage),
        );

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load comments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Unknown error occurred',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(comicProvider.notifier).fetchComments();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }
}
