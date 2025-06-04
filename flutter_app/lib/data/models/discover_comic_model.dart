import 'metadata_models.dart';

class DiscoverComic {
  final String id;
  final String title;
  final String? alternativeTitle;
  final String? synopsis;
  final String? status;
  final String? countryId;
  final int viewCount;
  final int voteCount;
  final int bookmarkCount;
  final String? coverImageUrl;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final int chapterCount;
  final List<Genre> genres;
  final List<Format> formats;

  DiscoverComic({
    required this.id,
    required this.title,
    this.alternativeTitle,
    this.synopsis,
    this.status,
    this.countryId, // Added countryId parameter
    this.viewCount = 0,
    this.voteCount = 0,
    this.bookmarkCount = 0,
    this.coverImageUrl,
    this.createdDate,
    this.updatedDate,
    required this.chapterCount,
    required this.genres,
    required this.formats,
  });

  factory DiscoverComic.fromJson(Map<String, dynamic> json) {
    return DiscoverComic(
      id: json['id'],
      title: json['title'],
      alternativeTitle: json['alternative_title'],
      synopsis: json['synopsis'],
      status: json['status'],
      countryId: json['country_id'], // Added countryId from JSON
      viewCount: json['view_count'] ?? 0,
      voteCount: json['vote_count'] ?? 0,
      bookmarkCount: json['bookmark_count'] ?? 0,
      coverImageUrl: json['cover_image_url'],
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
      updatedDate: json['updated_date'] != null
          ? DateTime.parse(json['updated_date'])
          : null,
      chapterCount: json['chapter_count'] ?? 0,
      genres: json['genres'] != null
          ? List<Genre>.from(json['genres'].map((x) => Genre.fromJson(x)))
          : [],
      formats: json['formats'] != null
          ? List<Format>.from(json['formats'].map((x) => Format.fromJson(x)))
          : [],
    );
  }
}
