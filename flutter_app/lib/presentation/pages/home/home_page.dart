import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/home_comic_model.dart';
import '../../riverpod/home/home_provider.dart';
import '../../riverpod/home/home_state.dart';
import '../../widgets/common/comic_card.dart';
import '../../widgets/skeletons/skeleton_widgets.dart';
import '../../../core/mahas/widget/mahas_grid.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Only select the status to determine the high-level UI state
        final status = ref.watch(homeProvider.select((state) => state.status));

        switch (status) {
          case HomeStatus.initial:
          case HomeStatus.loading:
            // Check if comics are empty without rebuilding when comics change
            final hasComics = ref
                .watch(homeProvider.select((state) => state.comics.isNotEmpty));
            if (!hasComics) {
              return _buildLoadingState();
            }
            return _buildComicGrid(context, ref);

          case HomeStatus.success:
            return _buildComicGrid(context, ref);

          case HomeStatus.error:
            final errorMessage =
                ref.watch(homeProvider.select((state) => state.errorMessage));
            return _buildErrorState(context, errorMessage, ref);
        }
      },
    );
  }

  Widget _buildComicGrid(BuildContext context, WidgetRef ref) {
    // Select only the parts of state we need for scroll behavior
    final isLoadingMore =
        ref.watch(homeProvider.select((state) => state.isLoadingMore));
    final hasReachedMax =
        ref.watch(homeProvider.select((state) => state.hasReachedMax));
    final notifier = ref.read(homeProvider.notifier);

    return RefreshIndicator(
      onRefresh: () => notifier.refreshComics(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent * 0.8 &&
              !isLoadingMore &&
              !hasReachedMax) {
            notifier.loadMoreComics();
          }
          return false;
        },
        child: Column(
          children: [
            // Comic grid that only rebuilds when comics list changes
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final comics =
                      ref.watch(homeProvider.select((state) => state.comics));

                  // Create list of comic card widgets
                  final comicItems = comics
                      .map((comic) => _buildComicItem(context, comic))
                      .toList();

                  return MahasGrid(
                    items: comicItems,
                    crossAxisCount: 2,
                    childAspectRatio: 0.45,
                    padding: const EdgeInsets.all(8.0),
                  );
                },
              ),
            ),

            // Loading indicator that only rebuilds when isLoadingMore changes
            Consumer(
              builder: (context, ref, _) {
                final isLoading = ref
                    .watch(homeProvider.select((state) => state.isLoadingMore));

                if (!isLoading) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.getTextPrimaryColor(context),
                      ),
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

  Widget _buildComicItem(BuildContext context, HomeComic comic) {
    return ComicCard(
      comic: comic,
      width: double.infinity,
      height: 200,
      showTitle: true,
      showGenre: false,
      showChapters: true,
      isGrid: true,
      onTap: () {
        // Navigate to comic detail page
        // Navigator.pushNamed(context, '/comic/${comic.id}');
      },
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
    final notifier = ref.read(homeProvider.notifier);

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
            errorMessage ?? 'An error occurred',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => notifier.fetchComics(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
