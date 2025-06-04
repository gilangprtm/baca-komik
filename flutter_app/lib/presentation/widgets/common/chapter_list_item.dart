import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/chapter_model.dart';

class ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback? onTap;
  final bool isRead;
  final bool isDownloaded;
  final bool isLastRead;

  const ChapterListItem({
    Key? key,
    required this.chapter,
    this.onTap,
    this.isRead = false,
    this.isDownloaded = false,
    this.isLastRead = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = chapter.releaseDate != null
        ? _formatDate(chapter.releaseDate!)
        : 'Unknown';

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isLastRead ? Colors.amber.withValues(alpha: 0.1) : null,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Chapter number and title
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter ${chapter.chapterNumber}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isRead ? Colors.grey : Colors.black,
                    ),
                  ),
                  if (chapter.title != null && chapter.title!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        chapter.title!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isRead ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Right side with date and indicators
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Release date
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                // Status indicators
                Row(
                  children: [
                    // Downloaded indicator
                    if (isDownloaded)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.download_done,
                          size: 16,
                          color: Colors.green,
                        ),
                      ),

                    // Read indicator
                    if (isRead)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.blue,
                        ),
                      ),

                    // Last read indicator
                    if (isLastRead)
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.bookmark,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Format the release date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}
