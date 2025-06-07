import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../riverpod/chapter/chapter_provider.dart';
import '../../riverpod/chapter/chapter_state.dart';
import 'widget/chapter_reader_content.dart';
import 'widget/chapter_navigation_controls.dart';
import 'widget/chapter_app_bar.dart';
import 'widget/chapter_state_widgets.dart';

class ChapterPage extends StatelessWidget {
  const ChapterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Consumer(
        builder: (context, ref, _) {
          final status = ref.watch(
            chapterProvider.select((state) => state.status),
          );
          final pages = ref.watch(
            chapterProvider.select((state) => state.pages),
          );
          final showControls = ref.watch(
            chapterProvider.select((state) => state.isReaderControlsVisible),
          );

          // Handle loading state
          if (status == ChapterStateStatus.loading) {
            return const ChapterLoadingWidget();
          }

          // Handle error state
          if (status == ChapterStateStatus.error) {
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
        },
      ),
    );
  }
}
