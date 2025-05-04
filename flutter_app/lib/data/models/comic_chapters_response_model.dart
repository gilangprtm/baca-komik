import 'chapter_model.dart';
import 'pagination_model.dart';

class ComicChaptersResponse {
  final ComicInfo? comicInfo;
  final List<Chapter> chapters;
  final PaginationMeta meta;

  ComicChaptersResponse({
    this.comicInfo,
    required this.chapters,
    required this.meta,
  });

  factory ComicChaptersResponse.fromJson(Map<String, dynamic> json) {
    return ComicChaptersResponse(
      comicInfo: json['comic'] != null
          ? ComicInfo.fromJson(json['comic'] as Map<String, dynamic>)
          : null,
      chapters: (json['data'] as List<dynamic>)
          .map((chapter) =>
              // Handle both cases: when chapter is already a Chapter object or when it's a Map
              chapter is Chapter
                  ? chapter
                  : Chapter.fromJson(chapter as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  // For empty responses or error handling
  factory ComicChaptersResponse.empty(int page, int limit) {
    return ComicChaptersResponse(
      comicInfo: null,
      chapters: <Chapter>[],
      meta: PaginationMeta.empty(page, limit),
    );
  }
}
