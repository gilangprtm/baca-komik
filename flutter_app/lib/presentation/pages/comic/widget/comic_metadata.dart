import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/complete_comic_model.dart';

class ComicMetadata extends StatelessWidget {
  final CompleteComic completeComic;

  const ComicMetadata({
    Key? key,
    required this.completeComic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final comic = completeComic.comic;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (comic.synopsis != null && comic.synopsis!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                comic.synopsis!,
                style: TextStyle(
                  color: AppColors.getTextPrimaryColor(context),
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Genres
          if (comic.genres != null && comic.genres!.isNotEmpty)
            _buildMetadataRow(
                'Genre', comic.genres!.map((g) => g.name).join(', ')),

          // Authors
          if (comic.authors != null && comic.authors!.isNotEmpty)
            _buildMetadataRow(
                'Author', comic.authors!.map((a) => a.name).join(', ')),

          // Artists
          if (comic.artists != null && comic.artists!.isNotEmpty)
            _buildMetadataRow(
                'Artist', comic.artists!.map((a) => a.name).join(', ')),

          // Format
          if (comic.formats != null && comic.formats!.isNotEmpty)
            _buildMetadataRow(
                'Format', comic.formats!.map((f) => f.name).join(', ')),

          const SizedBox(height: 16),

          // Read more button for description
          if (comic.synopsis != null && comic.synopsis!.isNotEmpty)
            TextButton(
              onPressed: () {
                // Show full description dialog
              },
              child: const Text('... Read More'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey,
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
