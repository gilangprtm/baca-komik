import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../riverpod/chapter/chapter_provider.dart';
import '../../riverpod/comic/comic_provider.dart';
import '../../riverpod/history/history_provider.dart';
import 'widget/chapter_reader_content.dart';
import 'widget/chapter_navigation_controls.dart';
import 'widget/chapter_app_bar.dart';
import 'widget/chapter_state_widgets.dart';

class ChapterPage extends StatelessWidget {
  const ChapterPage({super.key});

  /// Handle back navigation and refresh operations
  Future<bool> _handleBackNavigation(WidgetRef ref) async {
    try {
      ref.read(comicProvider.notifier).refreshChapterReadStatus();
      ref.read(historyProvider.notifier).loadHistory();

      // Allow navigation to proceed
      return true;
    } catch (e) {
      // If refresh fails, still allow navigation
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) {
              await _handleBackNavigation(ref);
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.black,
            body: Consumer(
              builder: (context, ref, _) {
                try {
                  final isLoading = ref.watch(
                    chapterProvider.select((state) =>
                        state.isLoadingDetail || state.isLoadingPages),
                  );
                  final hasError = ref.watch(
                    chapterProvider.select((state) => state.hasError),
                  );
                  final pages = ref.watch(
                    chapterProvider.select((state) => state.pages),
                  );
                  final showControls = ref.watch(
                    chapterProvider.select((state) => state.showControls),
                  );

                  // Handle loading state
                  if (isLoading) {
                    return const ChapterLoadingWidget();
                  }

                  // Handle error state
                  if (hasError) {
                    return const ChapterErrorWidget();
                  }

                  // Handle empty state
                  if (pages.isEmpty) {
                    return const ChapterEmptyWidget();
                  }

                  return Stack(
                    children: [
                      // Main Content
                      const ChapterReaderContent(),

                      // Navigation Controls
                      if (showControls) const ChapterNavigationControls(),

                      // App Bar
                      if (showControls)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ChapterAppBar(),
                        ),
                    ],
                  );
                } catch (e) {
                  // Fallback for any provider errors
                  return const ChapterLoadingWidget();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
