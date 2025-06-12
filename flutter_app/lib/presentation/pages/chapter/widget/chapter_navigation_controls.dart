import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/mahas/widget/mahas_button.dart';
import '../../../../core/utils/type_utils.dart';
import '../../../../core/mahas/widget/mahas_bottomsheet.dart';
import '../../../riverpod/chapter/chapter_provider.dart';
import 'chapter_comments_widget.dart';
import 'chapter_list_widget.dart';

/// Navigation controls for chapter page
class ChapterNavigationControls extends StatelessWidget {
  const ChapterNavigationControls({super.key});

  /// Show chapter list modal for navigation
  void _showChapterList(BuildContext context, WidgetRef ref) {
    final chapter =
        ref.read(chapterProvider.select((state) => state.selectedChapter));
    final notifier = ref.read(chapterProvider.notifier);

    if (chapter?.mangaId == null) return;

    MahasBottomSheet.show(
      context: context,
      title: 'Chapter List',
      height: 500,
      child: Container(
        height: 500,
        child: ChapterListWidget(
          comicId: chapter!.mangaId,
          currentChapterId: chapter.chapterId,
          onChapterSelected: (selectedChapter) {
            Navigator.of(context).pop(); // Close bottom sheet
            notifier.goToChapter(selectedChapter.chapterId);
          },
        ),
      ),
    );
  }

  void _showCommentList(BuildContext context, WidgetRef ref) {
    MahasBottomSheet.show(
      context: context,
      title: 'Comments',
      height: MediaQuery.of(context).size.height * 0.8,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: const ChapterCommentsWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final hasNextChapter = ref.watch(
          chapterProvider.select((state) => state.hasNextChapter),
        );
        final hasPreviousChapter = ref.watch(
          chapterProvider.select((state) => state.hasPreviousChapter),
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
                if (hasPreviousChapter)
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
                      onPressed: () {
                        notifier.previousChapter();
                      },
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
                // Chapter comment button
                SizedBox(
                  width: 60,
                  height: 60,
                  child: MahasButton(
                    type: ButtonType.primary,
                    borderRadius: MahasBorderRadius.circle,
                    color: AppColors.darkSurfaceColor,
                    icon: const Icon(
                      Icons.comment,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      print('Comment button pressed');
                      _showCommentList(context, ref);
                    },
                  ),
                ),

                // Next chapter button
                if (hasNextChapter)
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
                      onPressed: () {
                        notifier.nextChapter();
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
