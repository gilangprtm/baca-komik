import 'package:flutter/material.dart';
import 'package:flutter_project/core/mahas/widget/mahas_image.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import '../../../core/utils/mahas_utils.dart';
import '../../../core/utils/type_utils.dart';
import '../../../data/models/shinigami/shinigami_models.dart';
import '../../../core/base/global_state.dart';
import '../../routes/app_routes.dart';

class ComicCard extends StatelessWidget {
  final ShinigamiManga comic;
  final VoidCallback? onTapKomik;
  final double width;
  final double height;
  final bool showTitle;
  final bool showGenre;
  final bool showRating;
  final bool isGrid;
  final bool showChapters;
  final bool showUp;

  const ComicCard({
    Key? key,
    required this.comic,
    this.onTapKomik,
    this.width = 120,
    this.height = 180,
    this.showTitle = true,
    this.showGenre = false,
    this.showRating = false,
    this.isGrid = false,
    this.showChapters = false,
    this.showUp = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract common properties based on comic type
    final String title = _getTitle();
    final String coverUrl = _getCoverUrl();
    final String? genre = showGenre ? _getGenre() : null;
    final double? rating = showRating ? _getRating() : null;
    final List<ShinigamiChapterListItem> latestChapters =
        showChapters ? _getLatestChapters() : [];

    // Check if any of the latest chapters was released today
    final bool hasChapterReleasedToday =
        _hasChapterReleasedToday(latestChapters);

    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      // Wrap in a SizedBox to constrain height and prevent overflow
      child: SizedBox(
        height: isGrid ? 280 : height + 80, // Adjust height based on content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image with rating badge
            GestureDetector(
              onTap: onTapKomik,
              child: Stack(
                children: [
                  // Cover image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      coverUrl,
                      width: width,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: width,
                          height: 250,
                          color: AppColors.darkBorderColor,
                          child: const Center(
                            child: Icon(Icons.book, color: Colors.grey),
                          ),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: width,
                          height: height,
                          color: AppColors.darkBorderColor,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.getTextPrimaryColor(context),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Country flag
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: MahasImage(
                      svgPath: 'assets/flags/${_getCountryFlagName()}.svg',
                      width: 20,
                      height: 20,
                      borderRadius: MahasBorderRadius.small,
                    ),
                  ),

                  // Badge "UP" only if has chapters released today
                  if (showUp)
                    if (hasChapterReleasedToday)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'UP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                  // Rating badge
                  if (showRating && rating != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Title
            if (showTitle)
              Container(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Center(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextPrimaryColor(context),
                      ),
                    ),
                  ),
                ),
              ),

            // Genre
            if (showGenre && genre != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  genre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),

            // Latest Chapters
            if (showChapters && latestChapters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasChapterReleasedToday) const SizedBox(height: 6),
                    ListView.builder(
                      itemCount:
                          latestChapters.length > 2 ? 2 : latestChapters.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return _buildChapterItem(latestChapters[index]);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Check if any chapter was released today or yesterday
  bool _hasChapterReleasedToday(List<ShinigamiChapterListItem> chapters) {
    if (chapters.isEmpty) return false;

    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day, now.hour - 33);

    final firstChapter = chapters[0];
    final releaseDate = firstChapter.createdAt;

    if (releaseDate != null) {
      final releaseDay = DateTime(releaseDate.year, releaseDate.month,
          releaseDate.day, releaseDate.hour);
      if (releaseDay.isAfter(yesterday)) {
        return true;
      }
    }

    return false;
  }

  // Helper methods to extract properties from ShinigamiManga
  String _getTitle() {
    return comic.title;
  }

  String _getCoverUrl() {
    final String? coverUrl = comic.coverImageUrl;

    // Use default image if coverUrl is null or empty
    if (coverUrl == null || coverUrl.isEmpty) {
      return '${GlobalState.baseUrl}/images/default-cover.jpg';
    }

    // Return the cover URL as-is
    return coverUrl;
  }

  String? _getGenre() {
    final genres = comic.taxonomy.genre;
    return genres.isNotEmpty ? genres.first.name : null;
  }

  double? _getRating() {
    return comic.userRate;
  }

  List<ShinigamiChapterListItem> _getLatestChapters() {
    final chapters = comic.chapters;
    if (chapters != null && chapters.isNotEmpty) {
      return chapters;
    }
    return [];
  }

  // Get country flag file name based on country_id
  String _getCountryFlagName() {
    final String? countryId = comic.countryId;

    // Map country_id to flag file name
    switch (countryId) {
      case 'KR':
        return 'kr';
      case 'JP':
        return 'jpn';
      case 'CN':
        return 'cn';
      default:
        return 'cn'; // Default to CN if country_id is not available
    }
  }

  Widget _buildChapterItem(ShinigamiChapterListItem chapter) {
    // Extract chapter info from model
    final String chapterNumber = chapter.chapterNumber.toString();
    final String chapterId = chapter.chapterId;
    final DateTime? releaseDate = chapter.createdAt;

    // Calculate time difference for display
    String timeAgo = '';
    if (releaseDate != null) {
      final difference = DateTime.now().difference(releaseDate);
      // hingga ke menit hitung
      if (difference.inDays > 0) {
        timeAgo = '${difference.inDays} hari';
      } else if (difference.inHours > 0) {
        timeAgo = '${difference.inHours} jam';
      } else if (difference.inMinutes > 0) {
        timeAgo = '${difference.inMinutes} menit';
      } else {
        timeAgo = 'Baru saja';
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigate to chapter detail page with comic model
        Mahas.routeTo(AppRoutes.chapter, arguments: {
          'chapterId': chapterId,
          'comic': comic,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Chapter number
            Text(
              'Chapter $chapterNumber',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            // Time ago
            Text(
              timeAgo,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
