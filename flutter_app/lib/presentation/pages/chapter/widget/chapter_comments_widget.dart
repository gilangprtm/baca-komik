import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../riverpod/chapter/chapter_provider.dart';
import '../../../riverpod/chapter/chapter_state.dart';
import '../../../widgets/common/comment_widget.dart';

/// Chapter comments widget that uses the reusable CommentWidget
class ChapterCommentsWidget extends StatelessWidget {
  const ChapterCommentsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Watch comment status to determine what to show
        final commentStatus = ref.watch(
          chapterProvider.select((state) => state.commentStatus),
        );

        switch (commentStatus) {
          case ChapterStateStatus.initial:
            // Auto-fetch comments when widget is first loaded
            return const _ChapterCommentInitialView();

          case ChapterStateStatus.loading:
            return CommentWidget(
              comments: const [],
              totalCount: 0,
              isLoading: true,
            );

          case ChapterStateStatus.success:
            return Consumer(
              builder: (context, ref, _) {
                final comments = ref.watch(
                  chapterProvider.select((state) => state.comments),
                );
                final totalCommentCount = ref.watch(
                  chapterProvider.select((state) => state.totalCommentCount),
                );
                final isLoadingMore = ref.watch(
                  chapterProvider
                      .select((state) => state.isLoadingMoreComments),
                );

                return CommentWidget(
                  comments: comments,
                  totalCount: totalCommentCount,
                  isLoadingMore: isLoadingMore,
                  onLoadMore: () {
                    ref.read(chapterProvider.notifier).loadMoreComments();
                  },
                  onRefresh: () async {
                    await ref.read(chapterProvider.notifier).refreshComments();
                  },
                  emptyMessage: 'No comments yet for this chapter',
                  showCommentCount: false,
                );
              },
            );

          case ChapterStateStatus.error:
            return const _ChapterCommentErrorView();
        }
      },
    );
  }
}

class _ChapterCommentInitialView extends StatefulWidget {
  const _ChapterCommentInitialView();

  @override
  State<_ChapterCommentInitialView> createState() =>
      _ChapterCommentInitialViewState();
}

class _ChapterCommentInitialViewState
    extends State<_ChapterCommentInitialView> {
  @override
  void initState() {
    super.initState();
    // Fetch comments after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final ref = ProviderScope.containerOf(context);
        ref.read(chapterProvider.notifier).fetchComments();
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

class _ChapterCommentErrorView extends StatelessWidget {
  const _ChapterCommentErrorView();

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final errorMessage = ref.watch(
          chapterProvider.select((state) => state.errorMessage),
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
                  ref.read(chapterProvider.notifier).fetchComments();
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
