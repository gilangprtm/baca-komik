import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/mahas/widget/mahas_grid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../../data/models/local/history_model.dart';
import '../../../../data/models/shinigami/shinigami_models.dart';
import '../../../riverpod/history/history_provider.dart';
import '../../../riverpod/history/history_state.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/skeletons/comic_grid_skeleton.dart';
import '../../../widgets/common/comic_card.dart';
import 'comic_adapter.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Auto-load history when widget is built
        final status = ref.watch(
          historyProvider.select((state) => state.status),
        );
        if (status == HistoryStatus.initial) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(historyProvider.notifier).loadHistory();
          });
        }

        switch (status) {
          case HistoryStatus.initial:
          case HistoryStatus.loading:
            // Check if we have existing data
            final hasData = ref.watch(
              historyProvider.select((state) => state.history.isNotEmpty),
            );
            if (!hasData) {
              return _HistoryTabHelpers.buildLoadingState();
            }
            return _HistoryTabHelpers.buildHistoryGrid(context, ref);

          case HistoryStatus.success:
            return _HistoryTabHelpers.buildHistoryGrid(context, ref);

          case HistoryStatus.error:
            final errorMessage = ref.watch(
              historyProvider.select((state) => state.errorMessage),
            );
            return _HistoryTabHelpers.buildErrorState(
                context, errorMessage, ref);
        }
      },
    );
  }
}

class _HistoryTabHelpers {
  static Widget buildLoadingState() {
    return const ComicGridSkeleton(
      crossAxisCount: 2,
      itemCount: 6,
    );
  }

  static Widget buildHistoryGrid(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(historyProvider.notifier).refreshHistory();
      },
      child: Column(
        children: [
          // History grid that only rebuilds when history list changes
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final history = ref.watch(
                  historyProvider.select((state) => state.history),
                );

                if (history.isEmpty) {
                  return buildEmptyState(context);
                }

                // Create list of comic card widgets
                final comicItems = history
                    .map(
                        (historyItem) => buildHistoryItem(context, historyItem))
                    .toList();

                return MahasGrid(
                  items: comicItems,
                  crossAxisCount: 2,
                  childAspectRatio: 0.53,
                  padding: const EdgeInsets.all(8.0),
                );
              },
            ),
          ),

          // Loading more indicator
          Consumer(
            builder: (context, ref, _) {
              final isLoadingMore = ref.watch(
                historyProvider.select((state) => state.isLoadingMore),
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

  static Widget buildHistoryItem(
      BuildContext context, HistoryModel historyItem) {
    return ComicCard(
      comic: HistoryToShinigamiManga.convert(historyItem),
      width: double.infinity,
      height: 200,
      showChapters: true,
      showUp: false,
      onTapKomik: () {
        // Navigate to the last read chapter if available
        if (historyItem.chapterId.isNotEmpty) {
          // Create a basic comic model from history data for chapter navigation
          final basicComic = ShinigamiManga(
            mangaId: historyItem.comicId,
            title: historyItem.title,
            status: 1,
            coverImageUrl: historyItem.urlCover,
            viewCount: 0,
            bookmarkCount: 0,
            rank: 0,
            countryId: historyItem.nation,
            isRecommended: false,
            taxonomy: ShinigamiTaxonomy(
              artist: [],
              author: [],
              format: [],
              genre: [],
              type: [],
            ),
          );

          Mahas.routeTo(
            AppRoutes.chapter,
            arguments: {
              'chapterId': historyItem.chapterId,
              'comic': basicComic,
            },
          );
        } else {
          // Navigate to comic page if no chapter info
          Mahas.routeTo(
            AppRoutes.comic,
            arguments: {'comicId': historyItem.comicId},
          );
        }
      },
    );
  }

  static Widget buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Reading History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start reading comics to see your history here!',
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
            'Failed to Load History',
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
              ref.read(historyProvider.notifier).loadHistory();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
