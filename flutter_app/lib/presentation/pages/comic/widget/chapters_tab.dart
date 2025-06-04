import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/mahas_utils.dart';
import '../../../riverpod/comic/comic_provider.dart';

class ChaptersTab extends ConsumerWidget {
  const ChaptersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get comic ID from arguments
    final String? comicId = Mahas.argument<String>('comicId');
    final state = ref.watch(comicProvider);
    final chapterList = state.chapterList;

    // Check if we have chapters to display
    if (chapterList != null && chapterList.data.isNotEmpty) {
      // TODO: Implement chapter list view
      return ListView.builder(
        itemCount: chapterList.data.length,
        itemBuilder: (context, index) {
          final chapter = chapterList.data[index];
          return ListTile(
            title: Text('Chapter ${chapter.chapterNumber}'),
            subtitle: chapter.title != null ? Text(chapter.title!) : null,
            trailing: Text(
              chapter.releaseDate != null
                  ? '${chapter.releaseDate!.day}/${chapter.releaseDate!.month}/${chapter.releaseDate!.year}'
                  : 'No date',
            ),
            onTap: () {
              // Navigate to chapter
              // Mahas.routeTo('/chapter', arguments: {'chapterId': chapter.id});
            },
          );
        },
      );
    }

    // Show placeholder when no chapters available
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.list, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Daftar chapter akan segera hadir',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat chapter untuk komik ${comicId ?? "ini"}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Reload chapters
              if (comicId != null) {
                ref.read(comicProvider.notifier).fetchComicChapters(comicId);
              }
            },
            child: const Text('Muat Chapter'),
          ),
        ],
      ),
    );
  }
}
