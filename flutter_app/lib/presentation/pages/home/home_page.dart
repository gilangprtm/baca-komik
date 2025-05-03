import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/home_comic_model.dart';
import '../../riverpod/home/home_provider.dart';
import '../../riverpod/home/home_state.dart';
import '../../widgets/common/comic_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeProvider);
    final notifier = ref.read(homeProvider.notifier);

    return SafeArea(
      child: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state, dynamic notifier) {
    switch (state.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        if (state.comics.isEmpty) {
          return _buildLoadingState();
        }
        return _buildComicGrid(context, state, notifier);

      case HomeStatus.success:
        return _buildComicGrid(context, state, notifier);

      case HomeStatus.error:
        return _buildErrorState(context, state.errorMessage, notifier);
    }
  }

  Widget _buildComicGrid(BuildContext context, HomeState state, dynamic notifier) {
    return RefreshIndicator(
      onRefresh: () => notifier.refreshComics(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is ScrollEndNotification &&
              scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8 &&
              !state.isLoadingMore &&
              !state.hasReachedMax) {
            notifier.loadMoreComics();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.5, // Ubah dari 0.6 ke 0.5 untuk memberikan lebih banyak ruang vertikal
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= state.comics.length) {
                      return null;
                    }
                    return _buildComicItem(context, state.comics[index]);
                  },
                  childCount: state.comics.length,
                ),
              ),
            ),
            if (state.isLoadingMore)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
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
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage, dynamic notifier) {
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
