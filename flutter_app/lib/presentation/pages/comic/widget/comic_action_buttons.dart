import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../../data/models/shinigami/shinigami_models.dart';
import '../../../riverpod/comic/comic_provider.dart';
import '../../../routes/app_routes.dart';

class ComicActionButtons extends StatelessWidget {
  final ShinigamiManga manga;

  const ComicActionButtons({
    Key? key,
    required this.manga,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Read button
          Consumer(
            builder: (context, ref, _) {
              final chapters = ref.watch(comicChaptersProvider);

              return ElevatedButton.icon(
                onPressed: chapters.isNotEmpty
                    ? () {
                        // Navigate to first chapter
                        final firstChapter = chapters.first;
                        Mahas.routeTo(
                          AppRoutes.chapter,
                          arguments: {'chapterId': firstChapter.chapterId},
                        );
                      }
                    : null,
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(chapters.isNotEmpty ? 'Read' : 'No Chapters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // Bookmark button
          Consumer(
            builder: (context, ref, _) {
              final isBookmarked = ref.watch(comicBookmarkProvider);
              final isLoadingBookmark = ref.watch(
                comicLoadingProvider.select(
                    (loading) => loading['is_loading_bookmark'] ?? false),
              );

              return OutlinedButton.icon(
                onPressed: isLoadingBookmark
                    ? null
                    : () {
                        ref.read(comicProvider.notifier).toggleBookmark();
                      },
                icon: isLoadingBookmark
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            color: AppColors.getTextPrimaryColor(context),
                            strokeWidth: 2),
                      )
                    : Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? Colors.purple : null,
                      ),
                label: Text(isBookmarked ? 'Bookmarked' : 'Bookmark'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isBookmarked ? Colors.purple : null,
                  side: BorderSide(
                    color: isBookmarked ? Colors.purple : Colors.grey,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
