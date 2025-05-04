import 'package:flutter/material.dart';
import 'package:flutter_project/core/mahas/widget/mahas_image.dart';
import 'package:flutter_project/core/theme/app_colors.dart';
import '../../../core/utils/type_utils.dart';
import '../../../data/models/comic_model.dart';
import '../../../data/models/home_comic_model.dart';
import '../../../data/models/discover_comic_model.dart';
import '../../../core/base/global_state.dart';

class ComicCard extends StatelessWidget {
  final dynamic comic; // Can be Comic, HomeComic, or DiscoverComic
  final VoidCallback? onTapKomik;
  final double width;
  final double height;
  final bool showTitle;
  final bool showGenre;
  final bool showRating;
  final bool isGrid;
  final bool showChapters;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract common properties based on comic type
    final String title = _getTitle();
    final String coverUrl = _getCoverUrl();
    final String? genre = showGenre ? _getGenre() : null;
    final double? rating = showRating ? _getRating() : null;
    final List<dynamic> latestChapters =
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
                    // Badge "UP" only if has chapters released today
                    if (hasChapterReleasedToday)
                      Container(
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
                    if (hasChapterReleasedToday) const SizedBox(height: 6),
                    // Chapter list
                    ...latestChapters
                        .map((chapter) => _buildChapterItem(chapter))
                        .toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Check if any chapter was released today
  bool _hasChapterReleasedToday(List<dynamic> chapters) {
    if (chapters.isEmpty) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final releaseDate = chapters[0].releaseDate;
    if (releaseDate != null) {
      final releaseDay =
          DateTime(releaseDate.year, releaseDate.month, releaseDate.day);
      if (releaseDay.isAtSameMomentAs(today)) {
        return true;
      }
    }

    return false;
  }

  // Helper methods to extract properties based on comic type
  String _getTitle() {
    if (comic is Comic) {
      return (comic as Comic).title;
    } else if (comic is HomeComic) {
      return (comic as HomeComic).title;
    } else if (comic is DiscoverComic) {
      return (comic as DiscoverComic).title;
    }
    return 'Unknown';
  }

  String _getCoverUrl() {
    String? coverUrl;
    if (comic is Comic) {
      coverUrl = (comic as Comic).coverImageUrl;
    } else if (comic is HomeComic) {
      coverUrl = (comic as HomeComic).coverImageUrl;
    } else if (comic is DiscoverComic) {
      coverUrl = (comic as DiscoverComic).coverImageUrl;
    }

    // Use default image if coverUrl is null
    if (coverUrl == null) {
      return '${GlobalState.baseUrl}/images/default-cover.jpg';
    }

    // If URL doesn't start with http, prepend the base URL
    if (!coverUrl.startsWith('http')) {
      coverUrl = '${GlobalState.baseUrl}$coverUrl';
    }

    return coverUrl;
  }

  String? _getGenre() {
    if (comic is Comic) {
      final genres = (comic as Comic).genres;
      return genres != null && genres.isNotEmpty ? genres.first.name : null;
    } else if (comic is HomeComic) {
      final genres = (comic as HomeComic).genres;
      return genres.isNotEmpty ? genres.first.name : null;
    } else if (comic is DiscoverComic) {
      final genres = (comic as DiscoverComic).genres;
      return genres.isNotEmpty ? genres.first.name : null;
    }
    return null;
  }

  double? _getRating() {
    // Calculate rating based on vote count and bookmark count
    // This is a simplified calculation, you might want to adjust it
    if (comic is Comic) {
      final voteCount = (comic as Comic).voteCount;
      final bookmarkCount = (comic as Comic).bookmarkCount;
      if (voteCount > 0) {
        return (voteCount * 0.8 + bookmarkCount * 0.2) / 100;
      }
    } else if (comic is HomeComic) {
      final voteCount = (comic as HomeComic).voteCount;
      final bookmarkCount = (comic as HomeComic).bookmarkCount;
      if (voteCount > 0) {
        return (voteCount * 0.8 + bookmarkCount * 0.2) / 100;
      }
    } else if (comic is DiscoverComic) {
      final voteCount = (comic as DiscoverComic).voteCount;
      final bookmarkCount = (comic as DiscoverComic).bookmarkCount;
      if (voteCount > 0) {
        return (voteCount * 0.8 + bookmarkCount * 0.2) / 100;
      }
    }
    return null;
  }

  List<dynamic> _getLatestChapters() {
    if (comic is HomeComic) {
      return (comic as HomeComic).latestChapters;
    }
    return [];
  }

  // Get country flag file name based on country_id
  String _getCountryFlagName() {
    String? countryId;

    if (comic is Comic) {
      countryId = (comic as Comic).countryId;
    } else if (comic is HomeComic) {
      countryId = (comic as HomeComic).countryId;
    } else if (comic is DiscoverComic) {
      countryId = (comic as DiscoverComic).countryId;
    }

    // Map country_id to flag file name
    switch (countryId) {
      case 'KR':
        return 'kr';
      case 'JPN':
        return 'jpn';
      case 'CN':
        return 'cn';
      default:
        return 'cn'; // Default to CN if country_id is not available
    }
  }

  Widget _buildChapterItem(dynamic chapter) {
    // Extract chapter info
    final String chapterNumber = chapter.chapterNumber.toString();
    final DateTime? releaseDate = chapter.releaseDate;

    // Calculate time difference for display
    String timeAgo = '';
    if (releaseDate != null) {
      final difference = DateTime.now().difference(releaseDate);
      if (difference.inHours < 24) {
        timeAgo = '${difference.inHours} jam';
      } else {
        timeAgo = '${difference.inDays} hari';
      }
    }

    return GestureDetector(
      onTap: () {
        // Navigate to chapter detail page
        // Navigator.pushNamed(context, '/chapter/${comic.id}');
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
