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

class SearchResultsSection extends ConsumerWidget {
  const SearchResultsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use ref.select to optimize rebuilds
    final searchQuery = ref.watch(
      searchProvider.select((state) => state.query),
    );

    if (searchQuery.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Search Results for "$searchQuery"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Search results content
          Consumer(
            builder: (context, ref, child) {
              // Use ref.select for optimized watching
              final searchResults = ref.watch(
                searchProvider.select((state) => state.searchResults),
              );
              final searchStatus = ref.watch(
                searchProvider.select((state) => state.searchStatus),
              );
              final errorMessage = ref.watch(
                searchProvider.select((state) => state.errorMessage),
              );
              final isLoadingMore = ref.watch(
                searchProvider.select((state) => state.isLoadingMoreSearch),
              );

              return _buildSearchResultsContent(
                context,
                ref,
                searchResults,
                searchStatus,
                errorMessage,
                isLoadingMore,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultsContent(
    BuildContext context,
    WidgetRef ref,
    List<ShinigamiManga> searchResults,
    SearchStatus status,
    String? errorMessage,
    bool isLoadingMore,
  ) {
    switch (status) {
      case SearchStatus.loading:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: _calculateGridHeight(6),
            child: ComicGridSkeleton(itemCount: 6),
          ),
        );

      case SearchStatus.error:
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ?? 'Failed to search manga',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(searchProvider.notifier).searchManga();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );

      case SearchStatus.success:
        if (searchResults.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('No manga found for your search'),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Constrain the grid height
            SizedBox(
              height: _calculateGridHeight(searchResults.length),
              child: MahasGrid(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                items: searchResults.map((manga) {
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
                }).toList(),
                crossAxisCount: 2,
                childAspectRatio: 0.45,
              ),
            ),

            // Loading more indicator
            if (isLoadingMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// Calculate grid height based on number of items
  double _calculateGridHeight(int itemCount) {
    if (itemCount == 0) return 0;

    const double itemHeight =
        280; // Height per item (based on childAspectRatio 0.45)
    const int crossAxisCount = 2;
    const double padding = 32; // Top and bottom padding

    final int rows = (itemCount / crossAxisCount).ceil();
    return (rows * itemHeight) + padding;
  }
}
