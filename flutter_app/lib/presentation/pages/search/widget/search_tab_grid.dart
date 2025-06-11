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

/// Configuration for different search tab types
enum SearchTabType {
  popular,
  allManga,
  searchResults,
}

/// Configuration class for search tab grid
class SearchTabConfig {
  final SearchTabType type;
  final SearchStatus Function(SearchState state) statusSelector;
  final List<ShinigamiManga> Function(SearchState state) dataSelector;
  final bool Function(SearchState state) isLoadingMoreSelector;
  final bool Function(SearchState state) canLoadMoreSelector;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final String emptyMessage;
  final String errorMessage;
  final bool showChapters;

  const SearchTabConfig({
    required this.type,
    required this.statusSelector,
    required this.dataSelector,
    required this.isLoadingMoreSelector,
    required this.canLoadMoreSelector,
    required this.onRefresh,
    required this.onLoadMore,
    required this.emptyMessage,
    required this.errorMessage,
    required this.showChapters,
  });
}

/// Reusable search tab grid widget
class SearchTabGrid extends StatelessWidget {
  final SearchTabConfig config;

  const SearchTabGrid({
    Key? key,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Use ref.select for optimized watching
        final status = ref.watch(
          searchProvider.select(config.statusSelector),
        );

        switch (status) {
          case SearchStatus.initial:
          case SearchStatus.loading:
            // Check if data are empty without rebuilding when data change
            final hasData = ref.watch(
              searchProvider
                  .select((state) => config.dataSelector(state).isNotEmpty),
            );
            if (!hasData) {
              return _buildLoadingState();
            }
            return _buildGrid(context, ref);

          case SearchStatus.success:
            return _buildGrid(context, ref);

          case SearchStatus.error:
            final errorMessage = ref.watch(
              searchProvider.select((state) => state.errorMessage),
            );
            return _buildErrorState(context, errorMessage, ref);
        }
      },
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref) {
    // Select only the parts of state we need for scroll behavior
    final isLoadingMore = ref.watch(
      searchProvider.select(config.isLoadingMoreSelector),
    );
    final canLoadMore = ref.watch(
      searchProvider.select(config.canLoadMoreSelector),
    );

    return RefreshIndicator(
      onRefresh: config.onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent * 0.8 &&
              !isLoadingMore &&
              canLoadMore) {
            config.onLoadMore();
          }
          return false;
        },
        child: Column(
          children: [
            // Manga grid that only rebuilds when manga list changes
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final mangaList = ref.watch(
                    searchProvider.select(config.dataSelector),
                  );

                  if (mangaList.isEmpty) {
                    return Center(
                      child: Text(config.emptyMessage),
                    );
                  }

                  // Create list of comic card widgets
                  final comicItems = mangaList
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
                  searchProvider.select(config.isLoadingMoreSelector),
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
            errorMessage ?? config.errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => config.onRefresh(),
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
      showChapters: config.showChapters,
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

/// Factory class for creating search tab configurations
class SearchTabConfigs {
  static SearchTabConfig popular(WidgetRef ref) {
    final notifier = ref.read(searchProvider.notifier);

    return SearchTabConfig(
      type: SearchTabType.popular,
      statusSelector: (state) => state.topDailyStatus,
      dataSelector: (state) => state.topDailyManga,
      isLoadingMoreSelector: (state) => state.isLoadingMoreTopDaily,
      canLoadMoreSelector: (state) => state.canLoadMoreTopDaily,
      onRefresh: () => notifier.loadTopDailyManga(),
      onLoadMore: () => notifier.loadMoreTopDailyManga(),
      emptyMessage: 'No popular manga available',
      errorMessage: 'Failed to load popular manga',
      showChapters: false,
    );
  }

  static SearchTabConfig allManga(WidgetRef ref) {
    final notifier = ref.read(searchProvider.notifier);

    return SearchTabConfig(
      type: SearchTabType.allManga,
      statusSelector: (state) => state.searchStatus,
      dataSelector: (state) => state.searchResults,
      isLoadingMoreSelector: (state) => state.isLoadingMoreSearch,
      canLoadMoreSelector: (state) => state.canLoadMoreSearch,
      onRefresh: () => notifier.loadAllManga(),
      onLoadMore: () => notifier.loadMoreAllManga(),
      emptyMessage: 'No manga available',
      errorMessage: 'Failed to load manga',
      showChapters: true,
    );
  }

  static SearchTabConfig searchResults(WidgetRef ref) {
    final notifier = ref.read(searchProvider.notifier);

    return SearchTabConfig(
      type: SearchTabType.searchResults,
      statusSelector: (state) => state.searchStatus,
      dataSelector: (state) => state.searchResults,
      isLoadingMoreSelector: (state) => state.isLoadingMoreSearch,
      canLoadMoreSelector: (state) => state.canLoadMoreSearch,
      onRefresh: () => notifier.searchManga(),
      onLoadMore: () => notifier.loadMoreSearchResults(),
      emptyMessage: 'No manga found for your search',
      errorMessage: 'Failed to search manga',
      showChapters: true,
    );
  }
}
