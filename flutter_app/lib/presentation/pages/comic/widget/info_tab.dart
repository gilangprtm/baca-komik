import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/complete_comic_model.dart';
import '../../../riverpod/comic/comic_provider.dart';

class InfoTab extends ConsumerWidget {
  final CompleteComic completeComic;

  const InfoTab({
    Key? key,
    required this.completeComic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comic = completeComic.comic;

    // Only watch chapterList length to optimize rebuilds
    final chapterCount = ref.watch(
      comicProvider.select((state) => state.chapterList?.data.length ?? 0),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem('Status', comic.status ?? 'Unknown'),
            _buildInfoItem(
                'Released',
                comic.createdDate != null
                    ? '${comic.createdDate!.year}'
                    : 'Unknown'),
            _buildInfoItem('Total Chapters', '$chapterCount'),
            _buildInfoItem('Views', '${comic.viewCount}'),
            _buildInfoItem('Bookmarks', '${comic.bookmarkCount}'),
            _buildInfoItem('Votes', '${comic.voteCount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
