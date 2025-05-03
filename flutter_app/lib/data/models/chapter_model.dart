import 'page_model.dart';

class Chapter {
  final String id;
  final double chapterNumber;
  final String? title;
  final DateTime? releaseDate;
  final double? rating;
  final int viewCount;
  final int voteCount;
  final String? thumbnailImageUrl;
  final String idKomik;
  final ComicInfo? comic;
  final ChapterNavigation? nextChapter;
  final ChapterNavigation? prevChapter;
  final List<Page>? pages;

  Chapter({
    required this.id,
    required this.chapterNumber,
    this.title,
    this.releaseDate,
    this.rating,
    this.viewCount = 0,
    this.voteCount = 0,
    this.thumbnailImageUrl,
    required this.idKomik,
    this.comic,
    this.nextChapter,
    this.prevChapter,
    this.pages,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      chapterNumber: json['chapter_number'] is int
          ? (json['chapter_number'] as int).toDouble()
          : json['chapter_number'],
      title: json['title'],
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : null,
      rating: json['rating']?.toDouble(),
      viewCount: json['view_count'] ?? 0,
      voteCount: json['vote_count'] ?? 0,
      thumbnailImageUrl: json['thumbnail_image_url'],
      idKomik: json['id_komik'] ?? '',
      comic: json['comic'] != null ? ComicInfo.fromJson(json['comic']) : null,
      nextChapter: json['next_chapter'] != null
          ? ChapterNavigation.fromJson(json['next_chapter'])
          : null,
      prevChapter: json['prev_chapter'] != null
          ? ChapterNavigation.fromJson(json['prev_chapter'])
          : null,
      pages: null, // Pages are loaded separately
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_number': chapterNumber,
      'title': title,
      'release_date': releaseDate?.toIso8601String(),
      'rating': rating,
      'view_count': viewCount,
      'vote_count': voteCount,
      'thumbnail_image_url': thumbnailImageUrl,
      'id_komik': idKomik,
    };
  }
}

class ChapterNavigation {
  final String id;
  final double chapterNumber;

  ChapterNavigation({
    required this.id,
    required this.chapterNumber,
  });

  factory ChapterNavigation.fromJson(Map<String, dynamic> json) {
    return ChapterNavigation(
      id: json['id'],
      chapterNumber: json['chapter_number'] is int
          ? (json['chapter_number'] as int).toDouble()
          : json['chapter_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapter_number': chapterNumber,
    };
  }
}

class ComicInfo {
  final String id;
  final String title;
  final String? alternativeTitle;
  final String? coverImageUrl;

  ComicInfo({
    required this.id,
    required this.title,
    this.alternativeTitle,
    this.coverImageUrl,
  });

  factory ComicInfo.fromJson(Map<String, dynamic> json) {
    return ComicInfo(
      id: json['id'],
      title: json['title'],
      alternativeTitle: json['alternative_title'],
      coverImageUrl: json['cover_image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'alternative_title': alternativeTitle,
      'cover_image_url': coverImageUrl,
    };
  }
}
