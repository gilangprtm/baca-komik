import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../riverpod/search/search_provider.dart';
import '../../../riverpod/search/search_state.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/common/comic_card.dart';
import 'error_state_widget.dart';

/// Discover Tab - shows popular and recommended comics in horizontal lists
class DiscoverTab extends StatelessWidget {
  const DiscoverTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final discoverStatus = ref.watch(
          searchProvider.select((state) => state.discoverStatus),
        );

        switch (discoverStatus) {
          case SearchStatus.initial:
          case SearchStatus.loading:
            return const Center(
              child: CircularProgressIndicator(),
            );

          case SearchStatus.success:
            return _buildDiscoverContent(ref);

          case SearchStatus.error:
            final errorMessage = ref.watch(
              searchProvider.select((state) => state.errorMessage),
            );
            return ErrorStateWidget(
              message: errorMessage ?? 'Failed to load discover content',
              onRetry: () =>
                  ref.read(searchProvider.notifier).loadDiscoverContent(),
            );
        }
      },
    );
  }

  Widget _buildDiscoverContent(WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(searchProvider.notifier).loadDiscoverContent();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPopularSection(ref),
            const SizedBox(height: 24),
            _buildRecommendedSection(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSection(WidgetRef ref) {
    final popularComics = ref.watch(
      searchProvider.select((state) => state.popularComics),
    );

    if (popularComics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Comics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: popularComics.length,
            itemBuilder: (context, index) {
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                child: ComicCard(
                  comic: popularComics[index],
                  width: 180,
                  height: 310,
                  showTitle: true,
                  showGenre: false,
                  showChapters: false,
                  isGrid: false,
                  onTapKomik: () {
                    Mahas.routeTo(
                      AppRoutes.comic,
                      arguments: {'comicId': popularComics[index].id},
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection(WidgetRef ref) {
    final recommendedComics = ref.watch(
      searchProvider.select((state) => state.recommendedComics),
    );

    if (recommendedComics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Comics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 310,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendedComics.length,
            itemBuilder: (context, index) {
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                child: ComicCard(
                  comic: recommendedComics[index],
                  width: 180,
                  height: 310,
                  showTitle: true,
                  showGenre: false,
                  showChapters: false,
                  isGrid: false,
                  onTapKomik: () {
                    Mahas.routeTo(
                      AppRoutes.comic,
                      arguments: {'comicId': recommendedComics[index].id},
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
