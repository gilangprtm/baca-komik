import 'page_model.dart';

class CompleteChapter {
  final ChapterDetail chapter;
  final List<Page> pages;
  final ChapterNavigation navigation;
  final UserChapterData userData;

  CompleteChapter({
    required this.chapter,
    required this.pages,
    required this.navigation,
    required this.userData,
  });

  factory CompleteChapter.fromJson(Map<String, dynamic> json) {
    return CompleteChapter(
      chapter: ChapterDetail.fromJson(json['chapter']),
      pages: List<Page>.from(
          json['pages'].map((x) => Page.fromJson({
                'id': '', // ID tidak ada di respons API
                'id_chapter': x['id_chapter'],
                'page_number': x['page_number'],
                'image_url': x['page_url'], // Perhatikan perbedaan nama field
              }))),
      navigation: ChapterNavigation.fromJson(json['navigation']),
      userData: UserChapterData.fromJson(json['user_data']),
    );
  }
}

class ChapterDetail {
  final String id;
  final double chapterNumber;
  final String? title;
  final DateTime? releaseDate;
  final double rating;
  final int viewCount;
  final int voteCount;
  final String idKomik;
  final String? thumbnailImageUrl;
  final ComicInfo comic;

  ChapterDetail({
    required this.id,
    required this.chapterNumber,
    this.title,
    this.releaseDate,
    this.rating = 0,
    this.viewCount = 0,
    this.voteCount = 0,
    required this.idKomik,
    this.thumbnailImageUrl,
    required this.comic,
  });

  factory ChapterDetail.fromJson(Map<String, dynamic> json) {
    return ChapterDetail(
      id: json['id'],
      chapterNumber: json['chapter_number'] is int
          ? (json['chapter_number'] as int).toDouble()
          : (json['chapter_number'] ?? 0).toDouble(),
      title: json['title'],
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : null,
      rating: json['rating'] is int
          ? (json['rating'] as int).toDouble()
          : (json['rating'] ?? 0).toDouble(),
      viewCount: json['view_count'] ?? 0,
      voteCount: json['vote_count'] ?? 0,
      idKomik: json['id_komik'],
      thumbnailImageUrl: json['thumbnail_image_url'],
      comic: ComicInfo.fromJson(json['comic']),
    );
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
}

class ChapterNavigation {
  final ChapterRef? nextChapter;
  final ChapterRef? prevChapter;

  ChapterNavigation({
    this.nextChapter,
    this.prevChapter,
  });

  factory ChapterNavigation.fromJson(Map<String, dynamic> json) {
    return ChapterNavigation(
      nextChapter: json['next_chapter'] != null
          ? ChapterRef.fromJson(json['next_chapter'])
          : null,
      prevChapter: json['prev_chapter'] != null
          ? ChapterRef.fromJson(json['prev_chapter'])
          : null,
    );
  }
}

class ChapterRef {
  final String id;
  final double chapterNumber;

  ChapterRef({
    required this.id,
    required this.chapterNumber,
  });

  factory ChapterRef.fromJson(Map<String, dynamic> json) {
    return ChapterRef(
      id: json['id'],
      chapterNumber: json['chapter_number']?.toDouble() ?? 0,
    );
  }
}

class UserChapterData {
  final bool isVoted;
  final bool isRead;

  UserChapterData({
    required this.isVoted,
    required this.isRead,
  });

  factory UserChapterData.fromJson(Map<String, dynamic> json) {
    return UserChapterData(
      isVoted: json['is_voted'] ?? false,
      isRead: json['is_read'] ?? false,
    );
  }
}
