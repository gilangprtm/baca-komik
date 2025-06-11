/// Chapter detail model for Shinigami API
class ShinigamiChapter {
  final String chapterId;
  final String mangaId;
  final int chapterNumber;
  final String? chapterTitle;
  final String baseUrl;
  final String baseUrlLow;
  final ShinigamiChapterData chapter;
  final String? thumbnailImageUrl;
  final int viewCount;
  final String? prevChapterId;
  final int? prevChapterNumber;
  final String? nextChapterId;
  final int? nextChapterNumber;
  final DateTime? releaseDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ShinigamiChapter({
    required this.chapterId,
    required this.mangaId,
    required this.chapterNumber,
    this.chapterTitle,
    required this.baseUrl,
    required this.baseUrlLow,
    required this.chapter,
    this.thumbnailImageUrl,
    required this.viewCount,
    this.prevChapterId,
    this.prevChapterNumber,
    this.nextChapterId,
    this.nextChapterNumber,
    this.releaseDate,
    this.createdAt,
    this.updatedAt,
  });

  factory ShinigamiChapter.fromJson(Map<String, dynamic> json) {
    return ShinigamiChapter(
      chapterId: json['chapter_id'] ?? '',
      mangaId: json['manga_id'] ?? '',
      chapterNumber: json['chapter_number'] ?? 0,
      chapterTitle: json['chapter_title'],
      baseUrl: json['base_url'] ?? '',
      baseUrlLow: json['base_url_low'] ?? '',
      chapter: ShinigamiChapterData.fromJson(json['chapter'] ?? {}),
      thumbnailImageUrl: json['thumbnail_image_url'],
      viewCount: json['view_count'] ?? 0,
      prevChapterId: json['prev_chapter_id'],
      prevChapterNumber: json['prev_chapter_number'],
      nextChapterId: json['next_chapter_id'],
      nextChapterNumber: json['next_chapter_number'],
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'manga_id': mangaId,
      'chapter_number': chapterNumber,
      'chapter_title': chapterTitle,
      'base_url': baseUrl,
      'base_url_low': baseUrlLow,
      'chapter': chapter.toJson(),
      'thumbnail_image_url': thumbnailImageUrl,
      'view_count': viewCount,
      'prev_chapter_id': prevChapterId,
      'prev_chapter_number': prevChapterNumber,
      'next_chapter_id': nextChapterId,
      'next_chapter_number': nextChapterNumber,
      'release_date': releaseDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper methods for UI display
  String get displayTitle => chapterTitle?.isNotEmpty == true 
      ? chapterTitle! 
      : 'Chapter $chapterNumber';
  
  String get displayChapterNumber => 'Chapter $chapterNumber';
  
  // Navigation helpers
  bool get hasPrevChapter => prevChapterId != null;
  bool get hasNextChapter => nextChapterId != null;
  bool get isFirstChapter => !hasPrevChapter;
  bool get isLastChapter => !hasNextChapter;

  // Get page URLs
  List<String> get pageUrls => chapter.getPageUrls(baseUrl);
  List<String> get lowQualityPageUrls => chapter.getPageUrls(baseUrlLow);
  
  // Get page count
  int get pageCount => chapter.data.length;
}

/// Chapter data containing path and image filenames
class ShinigamiChapterData {
  final String path;
  final List<String> data;

  ShinigamiChapterData({
    required this.path,
    required this.data,
  });

  factory ShinigamiChapterData.fromJson(Map<String, dynamic> json) {
    return ShinigamiChapterData(
      path: json['path'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'data': data,
    };
  }

  // Helper method to construct full image URLs
  List<String> getPageUrls(String baseUrl) {
    return data.map((filename) => '$baseUrl$path$filename').toList();
  }

  // Get page URL for specific page number (1-based)
  String? getPageUrl(String baseUrl, int pageNumber) {
    if (pageNumber < 1 || pageNumber > data.length) return null;
    return '$baseUrl$path${data[pageNumber - 1]}';
  }
}

/// Page model for Shinigami chapter pages
class ShinigamiPage {
  final String chapterId;
  final int pageNumber;
  final String imageUrl;
  final String? lowQualityImageUrl;

  ShinigamiPage({
    required this.chapterId,
    required this.pageNumber,
    required this.imageUrl,
    this.lowQualityImageUrl,
  });

  factory ShinigamiPage.fromChapterData({
    required String chapterId,
    required int pageNumber,
    required String filename,
    required String baseUrl,
    required String baseUrlLow,
    required String path,
  }) {
    return ShinigamiPage(
      chapterId: chapterId,
      pageNumber: pageNumber,
      imageUrl: '$baseUrl$path$filename',
      lowQualityImageUrl: '$baseUrlLow$path$filename',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'page_number': pageNumber,
      'image_url': imageUrl,
      'low_quality_image_url': lowQualityImageUrl,
    };
  }

  // Helper getter for display
  String get displayUrl => imageUrl;
  String get displayLowQualityUrl => lowQualityImageUrl ?? imageUrl;
}

/// Chapter navigation model
class ShinigamiChapterNavigation {
  final String? prevChapterId;
  final int? prevChapterNumber;
  final String? nextChapterId;
  final int? nextChapterNumber;

  ShinigamiChapterNavigation({
    this.prevChapterId,
    this.prevChapterNumber,
    this.nextChapterId,
    this.nextChapterNumber,
  });

  factory ShinigamiChapterNavigation.fromChapter(ShinigamiChapter chapter) {
    return ShinigamiChapterNavigation(
      prevChapterId: chapter.prevChapterId,
      prevChapterNumber: chapter.prevChapterNumber,
      nextChapterId: chapter.nextChapterId,
      nextChapterNumber: chapter.nextChapterNumber,
    );
  }

  bool get hasPrev => prevChapterId != null;
  bool get hasNext => nextChapterId != null;
  bool get isFirst => !hasPrev;
  bool get isLast => !hasNext;
}
