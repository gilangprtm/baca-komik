import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/widget/mahas_grid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../../data/models/local/bookmark_model.dart';
import '../../../riverpod/bookmark/bookmark_provider.dart';
import '../../../riverpod/bookmark/bookmark_state.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/skeletons/comic_grid_skeleton.dart';
import '../../../widgets/common/comic_card.dart';
import 'comic_adapter.dart';

class BookmarkTab extends StatelessWidget {
  const BookmarkTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Auto-load bookmarks when widget is built
        final status = ref.watch(
          bookmarkProvider.select((state) => state.status),
        );
        if (status == BookmarkStatus.initial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(bookmarkProvider.notifier).loadBookmarks();
          });
        }

        switch (status) {
          case BookmarkStatus.initial:
          case BookmarkStatus.loading:
            // Check if we have existing data
            final hasData = ref.watch(
              bookmarkProvider.select((state) => state.bookmarks.isNotEmpty),
            );
            if (!hasData) {
              return _BookmarkTabHelpers.buildLoadingState();
            }
            return _BookmarkTabHelpers.buildBookmarkGrid(context, ref);

          case BookmarkStatus.success:
            return _BookmarkTabHelpers.buildBookmarkGrid(context, ref);

          case BookmarkStatus.error:
            final errorMessage = ref.watch(
              bookmarkProvider.select((state) => state.errorMessage),
            );
            return _BookmarkTabHelpers.buildErrorState(
                context, errorMessage, ref);
        }
      },
    );
  }
}

class _BookmarkTabHelpers {
  static Widget buildLoadingState() {
    return const ComicGridSkeleton(
      crossAxisCount: 2,
      itemCount: 6,
    );
  }

  static Widget buildBookmarkGrid(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(bookmarkProvider.notifier).refreshBookmarks();
      },
      child: Column(
        children: [
          // Bookmark grid that only rebuilds when bookmark list changes
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final bookmarks = ref.watch(
                  bookmarkProvider.select((state) => state.bookmarks),
                );

                if (bookmarks.isEmpty) {
                  return buildEmptyState(context);
                }

                // Create list of comic card widgets
                final comicItems = bookmarks
                    .map((bookmark) => buildBookmarkItem(context, bookmark))
                    .toList();

                return MahasGrid(
                  items: comicItems,
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  padding: const EdgeInsets.all(8.0),
                );
              },
            ),
          ),

          // Loading more indicator
          Consumer(
            builder: (context, ref, _) {
              final isLoadingMore = ref.watch(
                bookmarkProvider.select((state) => state.isLoadingMore),
              );

              if (isLoadingMore) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.getTextPrimaryColor(context),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  static Widget buildBookmarkItem(
      BuildContext context, BookmarkModel bookmark) {
    return ComicCard(
      comic: BookmarkToShinigamiManga.convert(bookmark),
      width: double.infinity,
      height: 200,
      showTitle: true,
      showGenre: false,
      showRating: false,
      showChapters: false,
      isGrid: true,
      onTapKomik: () {
        Mahas.routeTo(
          AppRoutes.comic,
          arguments: {'comicId': bookmark.comicId},
        );
      },
    );
  }

  static Widget buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Bookmarks Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start bookmarking your favorite comics!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static Widget buildErrorState(
      BuildContext context, String? errorMessage, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Bookmarks',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Unknown error occurred',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(bookmarkProvider.notifier).loadBookmarks();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
