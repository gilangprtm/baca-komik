import 'package:flutter/material.dart';
import '../../../../data/models/shinigami/shinigami_models.dart';

class InfoTab extends StatelessWidget {
  final ShinigamiManga manga;

  const InfoTab({
    Key? key,
    required this.manga,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genres
            if (manga.taxonomy.genre.isNotEmpty)
              _buildInfoItem(
                  'Genre', manga.taxonomy.genre.map((g) => g.name).join(', ')),

            // Authors
            if (manga.taxonomy.author.isNotEmpty)
              _buildInfoItem('Author',
                  manga.taxonomy.author.map((a) => a.name).join(', ')),

            // Artists
            if (manga.taxonomy.artist.isNotEmpty)
              _buildInfoItem('Artist',
                  manga.taxonomy.artist.map((a) => a.name).join(', ')),

            // Format
            if (manga.taxonomy.format.isNotEmpty)
              _buildInfoItem('Format',
                  manga.taxonomy.format.map((f) => f.name).join(', ')),
            _buildInfoItem(
                'Released',
                manga.createdAt != null
                    ? '${manga.createdAt!.year}'
                    : 'Unknown'),
            _buildInfoItem('Views', '${manga.viewCount}'),
            _buildInfoItem('Bookmarks', '${manga.bookmarkCount}'),
            _buildInfoItem('Rating', '${manga.userRate}/10'),
            if (manga.description?.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                manga.description!,
                style: const TextStyle(fontSize: 14),
              ),
            ],
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
