import 'comic_model.dart';
import 'chapter_model.dart';
import 'pagination_model.dart';

class CompleteComic {
  final Comic comic;
  final UserComicData userData;

  CompleteComic({
    required this.comic,
    required this.userData,
  });

  factory CompleteComic.fromJson(Map<String, dynamic> json) {
    return CompleteComic(
      comic: Comic.fromJson(json['comic']),
      userData: UserComicData.fromJson(json['user_data']),
    );
  }
}

class ChapterList {
  final List<Chapter> data;
  final PaginationMeta meta;

  ChapterList({
    required this.data,
    required this.meta,
  });

  factory ChapterList.fromJson(Map<String, dynamic> json) {
    return ChapterList(
      data: List<Chapter>.from(json['data'].map((x) => Chapter.fromJson(x))),
      meta: PaginationMeta.fromJson(json['meta']),
    );
  }
}

class UserComicData {
  final bool isBookmarked;
  final bool isVoted;
  final String? lastReadChapter;

  UserComicData({
    required this.isBookmarked,
    required this.isVoted,
    this.lastReadChapter,
  });

  factory UserComicData.fromJson(Map<String, dynamic> json) {
    return UserComicData(
      isBookmarked: json['is_bookmarked'] ?? false,
      isVoted: json['is_voted'] ?? false,
      lastReadChapter: json['last_read_chapter'],
    );
  }

  UserComicData copyWith({
    bool? isBookmarked,
    bool? isVoted,
    String? lastReadChapter,
  }) {
    return UserComicData(
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isVoted: isVoted ?? this.isVoted,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
    );
  }
}
