import 'package:flutter/material.dart';
import '../../../../data/models/shinigami/shinigami_models.dart';

class ComicHeader extends StatelessWidget {
  final ShinigamiManga manga;

  const ComicHeader({
    Key? key,
    required this.manga,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final alternativeTitle = manga.alternativeTitle;

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // background blur image
          Positioned.fill(
            child: Image.network(
              manga.coverImageUrl ?? '',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.88),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Cover image
              Container(
                width: 180,
                height: 240,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    manga.coverImageUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.broken_image,
                            color: Colors.white, size: 40),
                      );
                    },
                  ),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  manga.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Alternative title if available
              if (alternativeTitle != null && alternativeTitle.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Text(
                    alternativeTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                const SizedBox(height: 16),

              // Stats row
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatItem(
                        Icons.star, Colors.amber, '${manga.userRate}'),
                    const SizedBox(width: 24),
                    _buildStatItem(Icons.remove_red_eye, Colors.blue,
                        '${(manga.viewCount / 1000).toStringAsFixed(1)}k'),
                    const SizedBox(width: 24),
                    _buildStatItem(Icons.bookmark, Colors.purple,
                        '${manga.bookmarkCount}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, Color color, String value) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}
