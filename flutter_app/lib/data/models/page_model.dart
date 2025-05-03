class Page {
  final String id;
  final String idChapter;
  final int pageNumber;
  final String imageUrl;

  Page({
    required this.id,
    required this.idChapter,
    required this.pageNumber,
    required this.imageUrl,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json['id'] ?? '',
      idChapter: json['id_chapter'],
      pageNumber: json['page_number'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_chapter': idChapter,
      'page_number': pageNumber,
      'image_url': imageUrl,
    };
  }
}

class ChapterPages {
  final ChapterInfo chapter;
  final List<Page> pages;
  final int count;

  ChapterPages({
    required this.chapter,
    required this.pages,
    required this.count,
  });

  factory ChapterPages.fromJson(Map<String, dynamic> json) {
    return ChapterPages(
      chapter: ChapterInfo.fromJson(json['chapter']),
      pages: List<Page>.from(json['pages'].map((x) => Page.fromJson(x))),
      count: json['count'],
    );
  }
}

class ChapterInfo {
  final String id;
  final double chapterNumber;
  final ComicInfo comic;

  ChapterInfo({
    required this.id,
    required this.chapterNumber,
    required this.comic,
  });

  factory ChapterInfo.fromJson(Map<String, dynamic> json) {
    return ChapterInfo(
      id: json['id'],
      chapterNumber: json['chapter_number'] is int
          ? (json['chapter_number'] as int).toDouble()
          : json['chapter_number'],
      comic: ComicInfo.fromJson(json['comic']),
    );
  }
}

class ComicInfo {
  final String id;
  final String title;

  ComicInfo({
    required this.id,
    required this.title,
  });

  factory ComicInfo.fromJson(Map<String, dynamic> json) {
    return ComicInfo(
      id: json['id'],
      title: json['title'],
    );
  }
}
