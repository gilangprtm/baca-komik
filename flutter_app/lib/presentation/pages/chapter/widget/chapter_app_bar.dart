import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../riverpod/chapter/chapter_provider.dart';

/// Custom app bar for chapter page
class ChapterAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ChapterAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = ref.watch(
      chapterProvider.select((state) => state.chapter),
    );

    return AppBar(
      backgroundColor: AppColors.darkSurfaceColor,
      title: Text(
        'Chapter ${chapter?.chapterNumber ?? ''}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
