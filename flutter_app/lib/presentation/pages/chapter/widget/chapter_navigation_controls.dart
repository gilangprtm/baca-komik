import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/utils/type_utils.dart';
import '../../../../core/mahas/widget/mahas_bottomsheet.dart';
import '../../../riverpod/chapter/chapter_provider.dart';
import 'chapter_list_widget.dart';

/// Navigation controls for chapter page
class ChapterNavigationControls extends ConsumerWidget {
  const ChapterNavigationControls({super.key});

  /// Show chapter list modal for navigation
  void _showChapterList(BuildContext context, WidgetRef ref) {
    final chapter = ref.read(chapterProvider.select((state) => state.chapter));
    final notifier = ref.read(chapterProvider.notifier);

    if (chapter?.idKomik == null) return;

    MahasBottomSheet.show(
      context: context,
      title: 'Chapter List',
      height: 500,
      child: Container(
        height: 500,
        child: ChapterListWidget(
          comicId: chapter!.idKomik,
          currentChapterId: chapter.id,
          onChapterSelected: (selectedChapter) {
            Navigator.of(context).pop(); // Close bottom sheet
            notifier.goToChapter(selectedChapter.id);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextChapter = ref.watch(
      chapterProvider.select((state) => state.nextChapter),
    );
    final previousChapter = ref.watch(
      chapterProvider.select((state) => state.previousChapter),
    );
    final notifier = ref.read(chapterProvider.notifier);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Previous chapter button
            if (previousChapter != null)
              SizedBox(
                width: 60,
                height: 60,
                child: MahasButton(
                  type: ButtonType.primary,
                  borderRadius: MahasBorderRadius.circle,
                  color: AppColors.darkSurfaceColor,
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => notifier.previousChapter(),
                ),
              ),
            // Chapter list button
            SizedBox(
              width: 60,
              height: 60,
              child: MahasButton(
                type: ButtonType.primary,
                borderRadius: MahasBorderRadius.circle,
                color: AppColors.darkSurfaceColor,
                icon: const Icon(
                  Icons.format_list_bulleted,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () => _showChapterList(context, ref),
              ),
            ),
            // Next chapter button
            if (nextChapter != null)
              SizedBox(
                width: 60,
                height: 60,
                child: MahasButton(
                  type: ButtonType.primary,
                  borderRadius: MahasBorderRadius.circle,
                  color: AppColors.darkSurfaceColor,
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => notifier.nextChapter(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
