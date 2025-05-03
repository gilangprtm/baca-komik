import 'comic_model.dart';
import 'chapter_model.dart';
import 'metadata_models.dart';

class CompleteComic {
  final Comic comic;
  final ChapterList chapters;
  final UserComicData userData;

  CompleteComic({
    required this.comic,
    required this.chapters,
    required this.userData,
  });

  factory CompleteComic.fromJson(Map<String, dynamic> json) {
    return CompleteComic(
      comic: Comic.fromJson(json['comic']),
      chapters: ChapterList.fromJson(json['chapters']),
      userData: UserComicData.fromJson(json['user_data']),
    );
  }
}

class ChapterList {
  final List<Chapter> data;
  final MetaData meta;

  ChapterList({
    required this.data,
    required this.meta,
  });

  factory ChapterList.fromJson(Map<String, dynamic> json) {
    return ChapterList(
      data: List<Chapter>.from(json['data'].map((x) => Chapter.fromJson(x))),
      meta: MetaData.fromJson(json['meta']),
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
}
