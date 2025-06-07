import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/widget/mahas_grid.dart';
import '../../../../core/mahas/widget/mahas_searchbar.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../riverpod/search/search_provider.dart';
import '../../../riverpod/search/search_state.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/common/comic_card.dart';
import '../../../widgets/skeletons/comic_grid_skeleton.dart';
import 'error_state_widget.dart';

/// All Comics Tab - shows all comics with search and pagination
class AllComicsTab extends StatelessWidget {
  const AllComicsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(),

        // Comics content
        Expanded(
          child: Consumer(
            builder: (context, ref, _) {
              final allComicsStatus = ref.watch(
                searchProvider.select((state) => state.allComicsStatus),
              );

              switch (allComicsStatus) {
                case SearchStatus.initial:
                case SearchStatus.loading:
                  final hasComics = ref.watch(
                    searchProvider.select((state) => state.hasAllComics),
                  );

                  if (!hasComics) {
                    return const ComicGridSkeleton(
                      itemCount: 6,
                      crossAxisCount: 2,
                      childAspectRatio: 0.45, // Same as home page
                    );
                  }
                  return _buildAllComicsGrid(ref);

                case SearchStatus.success:
                  return _buildAllComicsGrid(ref);

                case SearchStatus.error:
                  final errorMessage = ref.watch(
                    searchProvider.select((state) => state.errorMessage),
                  );
                  return ErrorStateWidget(
                    message: errorMessage ?? 'Failed to load comics',
                    onRetry: () =>
                        ref.read(searchProvider.notifier).loadAllComics(),
                  );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Consumer(
      builder: (context, ref, _) {
        final notifier = ref.read(searchProvider.notifier);

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: MahasSearchBar(
            controller: notifier.searchController,
            hintText: 'Search comics...',
            onChanged: (query) {
              // Only update query, don't trigger search
              notifier.updateSearchQuery(query);
            },
            onSubmitted: (query) {
              // Trigger search when user submits (presses enter or search button)
              notifier.searchComics(query);
            },
            onClear: () {
              notifier.clearSearch();
            },
          ),
        );
      },
    );
  }

  Widget _buildAllComicsGrid(WidgetRef ref) {
    return Consumer(
      builder: (context, ref, _) {
        final notifier = ref.read(searchProvider.notifier);
        final allComics = ref.watch(
          searchProvider.select((state) => state.allComics),
        );
        final isLoadingMore = ref.watch(
          searchProvider.select((state) => state.isLoadingMoreAllComics),
        );

        // Create list of comic card widgets like in home page
        final comicItems =
            allComics.map((comic) => _buildComicItem(comic)).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await notifier.loadAllComics();
          },
          child: Column(
            children: [
              // Comic grid using MahasGrid like home page
              Expanded(
                child: MahasGrid(
                  items: comicItems,
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                  padding: const EdgeInsets.all(8.0),
                ),
              ),

              // Loading indicator
              if (isLoadingMore) _buildLoadingItem(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComicItem(dynamic comic) {
    return ComicCard(
      comic: comic,
      width: double.infinity,
      height: 200,
      showTitle: true,
      showGenre: false,
      showChapters: false, // No chapters for search page
      isGrid: true,
      onTapKomik: () {
        Mahas.routeTo(
          AppRoutes.comic,
          arguments: {'comicId': comic.id},
        );
      },
    );
  }

  Widget _buildLoadingItem() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
