import 'chapter_model.dart';

class BookmarkDetail {
  final String bookmarkId;
  final BookmarkedComic comic;

  BookmarkDetail({
    required this.bookmarkId,
    required this.comic,
  });

  factory BookmarkDetail.fromJson(Map<String, dynamic> json) {
    return BookmarkDetail(
      bookmarkId: json['bookmark_id'],
      comic: json['comic'] != null
          ? BookmarkedComic.fromJson(json['comic'])
          : throw Exception('Comic data is missing'),
    );
  }
}

class BookmarkedComic {
  final String id;
  final String title;
  final String? alternativeTitle;
  final String? coverImageUrl;
  final String? status;
  final DateTime? updatedDate;
  final Chapter? latestChapter;

  BookmarkedComic({
    required this.id,
    required this.title,
    this.alternativeTitle,
    this.coverImageUrl,
    this.status,
    this.updatedDate,
    this.latestChapter,
  });

  factory BookmarkedComic.fromJson(Map<String, dynamic> json) {
    return BookmarkedComic(
      id: json['id'],
      title: json['title'],
      alternativeTitle: json['alternative_title'],
      coverImageUrl: json['cover_image_url'],
      status: json['status'],
      updatedDate: json['updated_date'] != null
          ? DateTime.parse(json['updated_date'])
          : null,
      latestChapter: json['latest_chapter'] != null
          ? Chapter.fromJson(json['latest_chapter'])
          : null,
    );
  }
}
