import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../riverpod/chapter/chapter_provider.dart';

/// Custom app bar for chapter page
class ChapterAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChapterAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final chapter = ref.watch(
          chapterProvider.select((state) => state.selectedChapter),
        );

        return AppBar(
          backgroundColor: AppColors.getBackgroundColor(context),
          title: Text(
            'Chapter ${chapter?.chapterNumber ?? ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColors.getTextPrimaryColor(context),
            ),
            onPressed: () => Mahas.back(),
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
