import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../../data/models/shinigami/shinigami_models.dart';
import '../../../riverpod/comic/comic_provider.dart';
import '../../../routes/app_routes.dart';

class ComicActionButtons extends ConsumerWidget {
  final ShinigamiManga manga;

  const ComicActionButtons({
    Key? key,
    required this.manga,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch chapters and bookmark status
    final chapters = ref.watch(comicChaptersProvider);
    final isBookmarked = ref.watch(comicBookmarkProvider);
    final isLoadingBookmark =
        ref.watch(comicLoadingProvider)['is_loading_bookmark'] ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Read button
          ElevatedButton.icon(
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
          ),

          const SizedBox(height: 8),

          // Bookmark button
          OutlinedButton.icon(
            onPressed: isLoadingBookmark
                ? null
                : () {
                    ref.read(comicProvider.notifier).toggleBookmark();
                  },
            icon: isLoadingBookmark
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
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
          ),
        ],
      ),
    );
  }
}
