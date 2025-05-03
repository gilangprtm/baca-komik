import 'chapter_model.dart';
import 'metadata_models.dart';

class Comic {
  final String id;
  final String title;
  final String? alternativeTitle;
  final String? synopsis;
  final String? status;
  final int viewCount;
  final int voteCount;
  final int bookmarkCount;
  final String? coverImageUrl;
  final DateTime? createdDate;
  final DateTime? updatedDate;
  final List<Chapter>? chapters;
  final List<Genre>? genres;
  final List<Author>? authors;
  final List<Artist>? artists;
  final List<Format>? formats;

  Comic({
    required this.id,
    required this.title,
    this.alternativeTitle,
    this.synopsis,
    this.status,
    this.viewCount = 0,
    this.voteCount = 0,
    this.bookmarkCount = 0,
    this.coverImageUrl,
    this.createdDate,
    this.updatedDate,
    this.chapters,
    this.genres,
    this.authors,
    this.artists,
    this.formats,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      id: json['id'],
      title: json['title'],
      alternativeTitle: json['alternative_title'],
      synopsis: json['synopsis'],
      status: json['status'],
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
      chapters: json['chapters'] != null
          ? List<Chapter>.from(
              json['chapters'].map((x) => Chapter.fromJson(x)))
          : null,
      genres: json['genres'] != null
          ? List<Genre>.from(json['genres'].map((x) => Genre.fromJson(x)))
          : null,
      authors: json['authors'] != null
          ? List<Author>.from(json['authors'].map((x) => Author.fromJson(x)))
          : null,
      artists: json['artists'] != null
          ? List<Artist>.from(json['artists'].map((x) => Artist.fromJson(x)))
          : null,
      formats: json['formats'] != null
          ? List<Format>.from(json['formats'].map((x) => Format.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'alternative_title': alternativeTitle,
      'synopsis': synopsis,
      'status': status,
      'view_count': viewCount,
      'vote_count': voteCount,
      'bookmark_count': bookmarkCount,
      'cover_image_url': coverImageUrl,
      'created_date': createdDate?.toIso8601String(),
      'updated_date': updatedDate?.toIso8601String(),
    };
  }
}
