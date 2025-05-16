import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../../data/models/complete_comic_model.dart';
import '../../../riverpod/comic/comic_provider.dart';

class ComicActionButtons extends ConsumerWidget {
  final CompleteComic completeComic;

  const ComicActionButtons({
    Key? key,
    required this.completeComic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Read button
          ElevatedButton.icon(
            onPressed: () {
              // Get comic ID from arguments
              final String? comicId = Mahas.argument<String>('comicId');
              // Use Provider to get chapters
              final state = ref.read(comicProvider);
              final chapterList = state.chapterList;

              // Navigate to first chapter if available
              if (comicId != null &&
                  chapterList != null &&
                  chapterList.data.isNotEmpty) {
                // Logic untuk navigasi ke chapter pertama
                // Contoh: Mahas.routeTo('/chapter', arguments: {'chapterId': chapterList.data.first.id});
              }
            },
            icon: const Icon(Icons.menu_book_rounded),
            label: const Text('Read'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Bookmark and Up Vote buttons
          Row(
            children: [
              // Bookmark button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Toggle bookmark status
                  },
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Bookmark'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Up Vote button toggle
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Up Vote the comic
                  },
                  icon: const Icon(Icons.upcoming),
                  label: const Text('Up Vote'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.grey),
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
