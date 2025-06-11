import 'shinigami_response_model.dart';
import 'shinigami_chapter_model.dart';

/// Chapter list item model for Shinigami API
/// This is different from ShinigamiChapter which is for chapter detail
class ShinigamiChapterItem {
  final String chapterId;
  final String mangaId;
  final String chapterTitle;
  final int chapterNumber;
  final String? thumbnailImageUrl;
  final int viewCount;
  final DateTime releaseDate;

  ShinigamiChapterItem({
    required this.chapterId,
    required this.mangaId,
    required this.chapterTitle,
    required this.chapterNumber,
    this.thumbnailImageUrl,
    required this.viewCount,
    required this.releaseDate,
  });

  factory ShinigamiChapterItem.fromJson(Map<String, dynamic> json) {
    return ShinigamiChapterItem(
      chapterId: json['chapter_id'] ?? '',
      mangaId: json['manga_id'] ?? '',
      chapterTitle: json['chapter_title'] ?? '',
      chapterNumber: json['chapter_number'] ?? 0,
      thumbnailImageUrl: json['thumbnail_image_url'],
      viewCount: json['view_count'] ?? 0,
      releaseDate:
          DateTime.tryParse(json['release_date'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapter_id': chapterId,
      'manga_id': mangaId,
      'chapter_title': chapterTitle,
      'chapter_number': chapterNumber,
      'thumbnail_image_url': thumbnailImageUrl,
      'view_count': viewCount,
      'release_date': releaseDate.toIso8601String(),
    };
  }

  // Helper methods for UI display
  String get displayTitle =>
      chapterTitle.isNotEmpty ? chapterTitle : 'Chapter $chapterNumber';

  String get displayChapterNumber => 'Chapter $chapterNumber';

  String get formattedTitle =>
      'Chapter $chapterNumber${chapterTitle.isNotEmpty ? ': $chapterTitle' : ''}';

  // Helper method to get relative time
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(releaseDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // Helper method to format view count
  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    } else {
      return viewCount.toString();
    }
  }

  // Helper method to format release date
  String get formattedReleaseDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${releaseDate.day} ${months[releaseDate.month - 1]} ${releaseDate.year}';
  }

  // Convert to ShinigamiChapter for compatibility (without page data)
  ShinigamiChapter toShinigamiChapter() {
    return ShinigamiChapter(
      chapterId: chapterId,
      mangaId: mangaId,
      chapterNumber: chapterNumber,
      chapterTitle: chapterTitle,
      baseUrl: '', // Will be filled when getting chapter detail
      baseUrlLow: '', // Will be filled when getting chapter detail
      chapter: ShinigamiChapterData(path: '', data: []), // Empty for list item
      thumbnailImageUrl: thumbnailImageUrl,
      viewCount: viewCount,
      releaseDate: releaseDate,
    );
  }
}

/// Chapter list response model
class ShinigamiChapterListResponse {
  final int retcode;
  final String message;
  final ShinigamiMeta meta;
  final List<ShinigamiChapterItem> data;

  ShinigamiChapterListResponse({
    required this.retcode,
    required this.message,
    required this.meta,
    required this.data,
  });

  factory ShinigamiChapterListResponse.fromJson(Map<String, dynamic> json) {
    return ShinigamiChapterListResponse(
      retcode: json['retcode'] ?? 0,
      message: json['message'] ?? '',
      meta: ShinigamiMeta.fromJson(json['meta'] ?? {}),
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => ShinigamiChapterItem.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'retcode': retcode,
      'message': message,
      'meta': meta,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods
  bool get isSuccess => retcode == 0;
  bool get hasData => data.isNotEmpty;
  int get totalChapters => meta.totalRecord ?? 0;
  bool get hasMore => (meta.page ?? 0) < (meta.totalPage ?? 0);

  // Convert to ShinigamiListResponse for compatibility
  ShinigamiListResponse<ShinigamiChapter> toShinigamiListResponse() {
    return ShinigamiListResponse<ShinigamiChapter>(
      data: data.map((item) => item.toShinigamiChapter()).toList(),
      meta: meta,
      facet: null,
    );
  }
}
