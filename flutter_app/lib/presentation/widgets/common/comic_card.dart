import 'package:flutter/material.dart';
import '../../../data/models/comic_model.dart';
import '../../../data/models/home_comic_model.dart';
import '../../../data/models/discover_comic_model.dart';
import '../../../core/base/global_state.dart';

class ComicCard extends StatelessWidget {
  final dynamic comic; // Can be Comic, HomeComic, or DiscoverComic
  final VoidCallback? onTap;
  final double width;
  final double height;
  final bool showTitle;
  final bool showGenre;
  final bool showRating;
  final bool isGrid;

  const ComicCard({
    Key? key,
    required this.comic,
    this.onTap,
    this.width = 120,
    this.height = 180,
    this.showTitle = true,
    this.showGenre = false,
    this.showRating = false,
    this.isGrid = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract common properties based on comic type
    final String title = _getTitle();
    final String coverUrl = _getCoverUrl();
    final String? genre = showGenre ? _getGenre() : null;
    final double? rating = showRating ? _getRating() : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image with rating badge
            Stack(
              children: [
                // Cover image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    coverUrl,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: width,
                        height: height,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: width,
                        height: height,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  ),
                ),
                
                // Rating badge
                if (showRating && rating != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
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
            
            // Title
            if (showTitle)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
          ],
        ),
      ),
    );
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
      return _calculateRating(voteCount, bookmarkCount);
    } else if (comic is HomeComic) {
      final voteCount = (comic as HomeComic).voteCount;
      final bookmarkCount = (comic as HomeComic).bookmarkCount;
      return _calculateRating(voteCount, bookmarkCount);
    } else if (comic is DiscoverComic) {
      final voteCount = (comic as DiscoverComic).voteCount;
      final bookmarkCount = (comic as DiscoverComic).bookmarkCount;
      return _calculateRating(voteCount, bookmarkCount);
    }
    return null;
  }
  
  // Helper method to calculate rating
  double _calculateRating(int voteCount, int bookmarkCount) {
    if (voteCount == 0 && bookmarkCount == 0) return 0.0;
    // Simple formula: (votes * 2 + bookmarks) / (total * 2) * 5
    final total = voteCount + bookmarkCount;
    final score = (voteCount * 2 + bookmarkCount) / (total * 2) * 5;
    return score.clamp(0.0, 5.0);
  }
}
