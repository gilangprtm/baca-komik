import 'package:flutter/material.dart';
import '../../../../data/models/complete_comic_model.dart';

class ComicHeader extends StatelessWidget {
  final CompleteComic completeComic;

  const ComicHeader({
    Key? key,
    required this.completeComic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final comic = completeComic.comic;
    final alternativeTitle = comic.alternativeTitle;

    return Container(
      color: Colors.black,
      child: Column(
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
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                comic.coverImageUrl ?? '',
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
              comic.title,
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
                    Icons.star, Colors.amber, '${comic.voteCount / 100}'),
                const SizedBox(width: 24),
                _buildStatItem(Icons.remove_red_eye, Colors.blue,
                    '${comic.viewCount / 1000}k'),
                const SizedBox(width: 24),
                _buildStatItem(Icons.emoji_events, Colors.purple,
                    '${comic.bookmarkCount}'),
              ],
            ),
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
