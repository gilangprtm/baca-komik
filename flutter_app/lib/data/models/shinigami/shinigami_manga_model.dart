import 'shinigami_taxonomy_model.dart';

/// Main manga model for Shinigami API
class ShinigamiManga {
  final String mangaId;
  final String title;
  final String? alternativeTitle;
  final String? description;
  final String? releaseYear;
  final int status;
  final String? coverImageUrl;
  final String? coverPortraitUrl;
  final int viewCount;
  final double? userRate;
  final int bookmarkCount;
  final int rank;
  final String? countryId;
  final bool isRecommended;
  final String? latestChapterId;
  final int? latestChapterNumber;
  final DateTime? latestChapterTime;
  final ShinigamiTaxonomy taxonomy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<ShinigamiChapterListItem>? chapters; // For is_update=true response

  ShinigamiManga({
    required this.mangaId,
    required this.title,
    this.alternativeTitle,
    this.description,
    this.releaseYear,
    required this.status,
    this.coverImageUrl,
    this.coverPortraitUrl,
    required this.viewCount,
    this.userRate,
    required this.bookmarkCount,
    required this.rank,
    this.countryId,
    required this.isRecommended,
    this.latestChapterId,
    this.latestChapterNumber,
    this.latestChapterTime,
    required this.taxonomy,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.chapters,
  });

  factory ShinigamiManga.fromJson(Map<String, dynamic> json) {
    return ShinigamiManga(
      mangaId: json['manga_id'] ?? '',
      title: json['title'] ?? '',
      alternativeTitle: json['alternative_title'],
      description: json['description'],
      releaseYear: json['release_year'],
      status: json['status'] != null ? (json['status'] as num).toInt() : 1,
      coverImageUrl: json['cover_image_url'],
      coverPortraitUrl: json['cover_portrait_url'],
      viewCount:
          json['view_count'] != null ? (json['view_count'] as num).toInt() : 0,
      userRate: json['user_rate']?.toDouble(),
      bookmarkCount: json['bookmark_count'] != null
          ? (json['bookmark_count'] as num).toInt()
          : 0,
      rank: json['rank'] != null ? (json['rank'] as num).toInt() : 0,
      countryId: json['country_id'],
      isRecommended: json['is_recommended'] ?? false,
      latestChapterId: json['latest_chapter_id'],
      latestChapterNumber: json['latest_chapter_number'] != null
          ? (json['latest_chapter_number'] as num).toInt()
          : null,
      latestChapterTime: json['latest_chapter_time'] != null
          ? DateTime.parse(json['latest_chapter_time'])
          : null,
      taxonomy: ShinigamiTaxonomy.fromJson(json['taxonomy'] ?? {}),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      chapters: json['chapters'] != null
          ? (json['chapters'] as List<dynamic>)
              .map((chapter) => ShinigamiChapterListItem.fromJson(
                  chapter as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manga_id': mangaId,
      'title': title,
      'alternative_title': alternativeTitle,
      'description': description,
      'release_year': releaseYear,
      'status': status,
      'cover_image_url': coverImageUrl,
      'cover_portrait_url': coverPortraitUrl,
      'view_count': viewCount,
      'user_rate': userRate,
      'bookmark_count': bookmarkCount,
      'rank': rank,
      'country_id': countryId,
      'is_recommended': isRecommended,
      'latest_chapter_id': latestChapterId,
      'latest_chapter_number': latestChapterNumber,
      'latest_chapter_time': latestChapterTime?.toIso8601String(),
      'taxonomy': taxonomy.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'chapters': chapters?.map((chapter) => chapter.toJson()).toList(),
    };
  }

  // Helper getters for UI display
  String get displayTitle => title;
  String get displayCoverUrl => coverImageUrl ?? '';
  String get displayPortraitUrl => coverPortraitUrl ?? coverImageUrl ?? '';
  String get displayDescription => description ?? '';
  String get displayYear => releaseYear ?? '';
  String get displayStatus => status == 1 ? 'Ongoing' : 'Completed';
  String get displayRating =>
      userRate != null ? userRate!.toStringAsFixed(1) : '0.0';
  String get displayViewCount => _formatCount(viewCount);
  String get displayBookmarkCount => _formatCount(bookmarkCount);

  // Get display strings for taxonomy
  String get displayGenres => taxonomy.genresJoined;
  String get displayAuthors => taxonomy.authorsJoined;
  String get displayArtists => taxonomy.artistsJoined;
  String get displayFormat => taxonomy.firstFormat ?? '';
  String get displayType => taxonomy.firstType ?? '';

  // Helper method to format large numbers
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  // Check if manga has latest chapter info
  bool get hasLatestChapter =>
      latestChapterId != null && latestChapterNumber != null;

  // Get latest chapter display text
  String get latestChapterDisplay =>
      hasLatestChapter ? 'Chapter ${latestChapterNumber}' : 'No chapters';
}

/// Chapter list item for manga with chapters (is_update=true response)
class ShinigamiChapterListItem {
  final String chapterId;
  final int chapterNumber;
  final DateTime? createdAt;

  ShinigamiChapterListItem({
    required this.chapterId,
    required this.chapterNumber,
    this.createdAt,
  });

  factory ShinigamiChapterListItem.fromJson(Map<String, dynamic> json) {
    return ShinigamiChapterListItem(
      chapterId: json['chapter_id'] ?? '',
      chapterNumber: json['chapter_number'] != null
          ? (json['chapter_number'] as num).toInt()
          : 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'chapter_number': chapterNumber,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
