import 'chapter_model.dart';
import 'metadata_models.dart';

class Comic {
  final String id;
  final String title;
  final String? alternativeTitle;
  final String? synopsis;
  final String? status;
  final String? countryId; // Added countryId property
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
    this.countryId, // Added countryId parameter
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
  
  /// Membuat salinan dari objek Comic dengan beberapa properti yang diperbarui
  Comic copyWith({
    String? id,
    String? title,
    String? alternativeTitle,
    String? synopsis,
    String? status,
    String? countryId,
    int? viewCount,
    int? voteCount,
    int? bookmarkCount,
    String? coverImageUrl,
    DateTime? createdDate,
    DateTime? updatedDate,
    List<Chapter>? chapters,
    List<Genre>? genres,
    List<Author>? authors,
    List<Artist>? artists,
    List<Format>? formats,
  }) {
    return Comic(
      id: id ?? this.id,
      title: title ?? this.title,
      alternativeTitle: alternativeTitle ?? this.alternativeTitle,
      synopsis: synopsis ?? this.synopsis,
      status: status ?? this.status,
      countryId: countryId ?? this.countryId,
      viewCount: viewCount ?? this.viewCount,
      voteCount: voteCount ?? this.voteCount,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
      chapters: chapters ?? this.chapters,
      genres: genres ?? this.genres,
      authors: authors ?? this.authors,
      artists: artists ?? this.artists,
      formats: formats ?? this.formats,
    );
  }
}
