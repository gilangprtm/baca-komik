import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../../data/models/complete_comic_model.dart';
import '../../../riverpod/comic/comic_provider.dart';
import '../../../routes/app_routes.dart';

class ChaptersTab extends ConsumerWidget {
  const ChaptersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch chapterList to optimize rebuilds
    final chapterList = ref.watch(
      comicProvider.select((state) => state.chapterList),
    );

    // Check if we have chapters to display
    if (chapterList != null && chapterList.data.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          // Refresh chapters from page 1
          await ref.read(comicProvider.notifier).fetchComicChapters(page: 1);
        },
        child: _ChapterListView(chapterList: chapterList),
      );
    }

    // Show loading or empty state
    return const _ChapterEmptyState();
  }
}

/// Optimized chapter list view with pagination support
class _ChapterListView extends ConsumerStatefulWidget {
  final ChapterList chapterList;

  const _ChapterListView({required this.chapterList});

  @override
  ConsumerState<_ChapterListView> createState() => _ChapterListViewState();
}

class _ChapterListViewState extends ConsumerState<_ChapterListView> {
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
      // Load more chapters if available using helper method
      final canLoadMore = ref.read(
        comicProvider.select((state) => state.canLoadMoreChapters),
      );

      if (canLoadMore) {
        ref.read(comicProvider.notifier).loadMoreChapters();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch pagination state using helper methods
    final isLoadingMore = ref.watch(
      comicProvider.select((state) => state.isLoadingMoreChapters),
    );
    final hasMoreChapters = ref.watch(
      comicProvider.select((state) => state.hasMoreChapters),
    );

    return Column(
      children: [
        // Chapter list
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount:
                widget.chapterList.data.length + (hasMoreChapters ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the end if there are more chapters
              if (index == widget.chapterList.data.length) {
                return _buildLoadingIndicator(isLoadingMore);
              }

              final chapter = widget.chapterList.data[index];
              return ListTile(
                title: Text('Chapter ${chapter.chapterNumber}'),
                subtitle: chapter.title != null ? Text(chapter.title!) : null,
                trailing: Text(
                  chapter.releaseDate != null
                      ? '${chapter.releaseDate!.day}/${chapter.releaseDate!.month}/${chapter.releaseDate!.year}'
                      : 'No date',
                ),
                onTap: () {
                  // Navigate to chapter
                  Mahas.routeTo(AppRoutes.chapter,
                      arguments: {'chapterId': chapter.id});
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(bool isLoadingMore) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
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
}

/// Optimized empty state widget
class _ChapterEmptyState extends ConsumerWidget {
  const _ChapterEmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get comic ID from arguments
    final String? comicId = Mahas.argument<String>('comicId');

    // Watch loading state to show appropriate message
    final isLoadingChapters = ref.watch(
      comicProvider.select((state) => state.isLoadingMoreChapters),
    );

    if (isLoadingChapters) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading chapters...'),
          ],
        ),
      );
    }

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
              // Reload chapters from page 1
              if (comicId != null) {
                ref.read(comicProvider.notifier).fetchComicChapters(page: 1);
              }
            },
            child: const Text('Reload Chapters'),
          ),
        ],
      ),
    );
  }
}
