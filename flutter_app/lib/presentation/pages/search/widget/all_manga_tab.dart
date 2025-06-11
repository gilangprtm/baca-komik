import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/widget/mahas_grid.dart';
import '../../../../data/models/shinigami/shinigami_models.dart';
import '../../../riverpod/search/search_provider.dart';
import '../../../riverpod/search/search_state.dart';
import '../../../widgets/common/comic_card.dart';
import '../../../widgets/skeletons/comic_grid_skeleton.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../routes/app_routes.dart';

class AllMangaTab extends ConsumerStatefulWidget {
  const AllMangaTab({Key? key}) : super(key: key);

  @override
  ConsumerState<AllMangaTab> createState() => _AllMangaTabState();
}

class _AllMangaTabState extends ConsumerState<AllMangaTab> {
  @override
  Widget build(BuildContext context) {
    // Use ref.select for optimized watching
    final status = ref.watch(
      searchProvider.select((state) => state.searchStatus),
    );

    switch (status) {
      case SearchStatus.initial:
      case SearchStatus.loading:
        // Check if manga are empty without rebuilding when manga change
        final hasManga = ref.watch(
          searchProvider.select((state) => state.searchResults.isNotEmpty),
        );
        if (!hasManga) {
          return _buildLoadingState();
        }
        return _buildMangaGrid(context, ref);

      case SearchStatus.success:
        return _buildMangaGrid(context, ref);

      case SearchStatus.error:
        final errorMessage = ref.watch(
          searchProvider.select((state) => state.errorMessage),
        );
        return _buildErrorState(context, errorMessage, ref);
    }
  }

  Widget _buildMangaGrid(BuildContext context, WidgetRef ref) {
    // Select only the parts of state we need for scroll behavior
    final isLoadingMore = ref.watch(
      searchProvider.select((state) => state.isLoadingMoreSearch),
    );
    final canLoadMore = ref.watch(
      searchProvider.select((state) => state.canLoadMoreSearch),
    );
    final notifier = ref.read(searchProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => notifier.loadAllManga(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent * 0.8 &&
              !isLoadingMore &&
              canLoadMore) {
            notifier.loadMoreAllManga();
          }
          return false;
        },
        child: Column(
          children: [
            // Manga grid that only rebuilds when manga list changes
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final allManga = ref.watch(
                    searchProvider.select((state) => state.searchResults),
                  );

                  if (allManga.isEmpty) {
                    return const Center(
                      child: Text('No manga available'),
                    );
                  }

                  // Create list of comic card widgets
                  final comicItems = allManga
                      .map((manga) => _buildComicItem(context, manga))
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

            // Loading indicator that only rebuilds when isLoadingMore changes
            Consumer(
              builder: (context, ref, _) {
                final isLoading = ref.watch(
                  searchProvider.select((state) => state.isLoadingMoreSearch),
                );

                if (!isLoading) return const SizedBox.shrink();

                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const ComicGridSkeleton(
      itemCount: 6,
      crossAxisCount: 2,
      childAspectRatio: 0.6,
      padding: EdgeInsets.all(8.0),
    );
  }

  Widget _buildErrorState(
      BuildContext context, String? errorMessage, WidgetRef ref) {
    final notifier = ref.read(searchProvider.notifier);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Failed to load manga',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => notifier.loadAllManga(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildComicItem(BuildContext context, ShinigamiManga manga) {
    return ComicCard(
      comic: manga,
      width: double.infinity,
      height: 200,
      showTitle: true,
      showGenre: false,
      showChapters: true,
      isGrid: true,
      onTapKomik: () {
        Mahas.routeTo(
          AppRoutes.comic,
          arguments: {'comicId': manga.mangaId},
        );
      },
    );
  }
}
