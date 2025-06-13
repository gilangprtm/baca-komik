import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../../data/models/shinigami/shinigami_models.dart';
import '../../../riverpod/comic/comic_provider.dart';
import '../../../riverpod/comic/comic_state.dart';
import '../../../routes/app_routes.dart';

class ChaptersTab extends StatelessWidget {
  const ChaptersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Only watch chapters to optimize rebuilds
        final chapters = ref.watch(comicChaptersProvider);
        final chapterStatus = ref.watch(comicChapterStatusProvider);

        // Check if we have chapters to display
        if (chapters.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh chapters from page 1
              await ref
                  .read(comicProvider.notifier)
                  .fetchComicChapters(page: 1);
            },
            child: _ChapterListView(chapters: chapters),
          );
        }

        // Show loading or empty state
        return _ChapterEmptyState(status: chapterStatus);
      },
    );
  }
}

/// Optimized chapter list view with pagination support
class _ChapterListView extends StatefulWidget {
  final List<ShinigamiChapter> chapters;

  const _ChapterListView({required this.chapters});

  @override
  State<_ChapterListView> createState() => _ChapterListViewState();
}

class _ChapterListViewState extends State<_ChapterListView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if user has scrolled to near the bottom
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Use Consumer to access ref in callback
      if (mounted) {
        // We'll handle this in the build method with Consumer
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Watch pagination state using helper methods
        final isLoadingMore = ref.watch(
          comicProvider.select((state) => state.isLoadingMoreChapters),
        );
        final hasMoreChapters = ref.watch(
          comicProvider.select((state) => state.hasMoreChapters),
        );

        // Handle scroll pagination
        void handleScrollPagination() {
          if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
            final canLoadMore = ref.read(
              comicProvider.select((state) => state.canLoadMoreChapters),
            );

            if (canLoadMore) {
              ref.read(comicProvider.notifier).loadMoreChapters();
            }
          }
        }

        // Update scroll listener
        _scrollController.removeListener(_onScroll);
        _scrollController.addListener(handleScrollPagination);

        return Column(
          children: [
            // Chapter list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.chapters.length + (hasMoreChapters ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show loading indicator at the end if there are more chapters
                  if (index == widget.chapters.length) {
                    return _buildLoadingIndicator(isLoadingMore);
                  }

                  final chapter = widget.chapters[index];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      leading: chapter.thumbnailImageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                chapter.thumbnailImageUrl!,
                                width: 40,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 40,
                                  height: 60,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              ),
                            )
                          : Container(
                              width: 40,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                      title: Text('Chapter ${chapter.chapterNumber}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (chapter.chapterTitle?.isNotEmpty == true)
                            Text(
                              chapter.chapterTitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          Text(
                            '${_formatViewCount(chapter.viewCount)} views • ${_formatRelativeTime(chapter.releaseDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        // Navigate to chapter
                        Mahas.routeTo(AppRoutes.chapter,
                            arguments: {'chapterId': chapter.chapterId});
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingIndicator(bool isLoadingMore) {
    if (isLoadingMore) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                color: AppColors.getTextPrimaryColor(context),
              ),
              SizedBox(height: 8),
              Text('Loading more chapters...'),
            ],
          ),
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Scroll to load more chapters',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }
  }

  String _formatViewCount(int viewCount) {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    } else {
      return viewCount.toString();
    }
  }

  String _formatRelativeTime(DateTime? releaseDate) {
    if (releaseDate == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(releaseDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
}

/// Optimized empty state widget
class _ChapterEmptyState extends StatelessWidget {
  final ComicStateStatus status;

  const _ChapterEmptyState({required this.status});

  @override
  Widget build(BuildContext context) {
    // Get comic ID from arguments
    final String? comicId = Mahas.argument<String>('comicId');

    if (status == ComicStateStatus.loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.getTextPrimaryColor(context),
            ),
            SizedBox(height: 16),
            Text('Loading chapters...'),
          ],
        ),
      );
    }

    if (status == ComicStateStatus.error) {
      return Consumer(
        builder: (context, ref, _) {
          final errorMessage = ref.watch(comicErrorProvider);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load chapters',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ?? 'Unknown error occurred',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(comicProvider.notifier)
                        .fetchComicChapters(page: 1);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      );
    }

    return Consumer(
      builder: (context, ref, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.list, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No chapters available',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Chapters for comic ${comicId ?? "this"} will appear here',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(comicProvider.notifier).fetchComicChapters(page: 1);
                },
                child: const Text('Load Chapters'),
              ),
            ],
          ),
        );
      },
    );
  }
}
