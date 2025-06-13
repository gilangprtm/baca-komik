import 'package:flutter/foundation.dart';

/// History model for storing user's reading history
/// Represents the last chapter read for each comic
@immutable
class HistoryModel {
  final int? id;
  final String comicId;
  final String chapterId;
  final String chapter;
  final String urlCover;
  final String title;
  final String nation;
  final int pagePosition;
  final int totalPages;
  final bool isCompleted;
  final DateTime readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HistoryModel({
    this.id,
    required this.comicId,
    required this.chapterId,
    required this.chapter,
    required this.urlCover,
    required this.title,
    required this.nation,
    this.pagePosition = 0,
    this.totalPages = 0,
    this.isCompleted = false,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create HistoryModel from database map
  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      id: map['id'] as int?,
      comicId: map['comic_id'] as String,
      chapterId: map['chapter_id'] as String,
      chapter: map['chapter'] as String,
      urlCover: map['url_cover'] as String,
      title: map['title'] as String,
      nation: map['nation'] as String,
      pagePosition: map['page_position'] as int? ?? 0,
      totalPages: map['total_pages'] as int? ?? 0,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      readAt: DateTime.fromMillisecondsSinceEpoch((map['read_at'] as int) * 1000),
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as int) * 1000),
    );
  }

  /// Convert HistoryModel to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'comic_id': comicId,
      'chapter_id': chapterId,
      'chapter': chapter,
      'url_cover': urlCover,
      'title': title,
      'nation': nation,
      'page_position': pagePosition,
      'total_pages': totalPages,
      'is_completed': isCompleted ? 1 : 0,
      'read_at': readAt.millisecondsSinceEpoch ~/ 1000,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Create a copy of HistoryModel with updated fields
  HistoryModel copyWith({
    int? id,
    String? comicId,
    String? chapterId,
    String? chapter,
    String? urlCover,
    String? title,
    String? nation,
    int? pagePosition,
    int? totalPages,
    bool? isCompleted,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistoryModel(
      id: id ?? this.id,
      comicId: comicId ?? this.comicId,
      chapterId: chapterId ?? this.chapterId,
      chapter: chapter ?? this.chapter,
      urlCover: urlCover ?? this.urlCover,
      title: title ?? this.title,
      nation: nation ?? this.nation,
      pagePosition: pagePosition ?? this.pagePosition,
      totalPages: totalPages ?? this.totalPages,
      isCompleted: isCompleted ?? this.isCompleted,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create HistoryModel for insertion (without id and with current timestamp)
  factory HistoryModel.create({
    required String comicId,
    required String chapterId,
    required String chapter,
    required String urlCover,
    required String title,
    required String nation,
    int pagePosition = 0,
    int totalPages = 0,
    bool isCompleted = false,
  }) {
    final now = DateTime.now();
    return HistoryModel(
      comicId: comicId,
      chapterId: chapterId,
      chapter: chapter,
      urlCover: urlCover,
      title: title,
      nation: nation,
      pagePosition: pagePosition,
      totalPages: totalPages,
      isCompleted: isCompleted,
      readAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Update reading progress
  HistoryModel updateProgress({
    int? pagePosition,
    int? totalPages,
    bool? isCompleted,
  }) {
    return copyWith(
      pagePosition: pagePosition ?? this.pagePosition,
      totalPages: totalPages ?? this.totalPages,
      isCompleted: isCompleted ?? this.isCompleted,
      readAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Mark chapter as completed
  HistoryModel markCompleted() {
    return copyWith(
      isCompleted: true,
      pagePosition: totalPages,
      readAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Update the readAt and updatedAt timestamp
  HistoryModel updateTimestamp() {
    final now = DateTime.now();
    return copyWith(
      readAt: now,
      updatedAt: now,
    );
  }

  /// Calculate reading progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (totalPages <= 0) return 0.0;
    return (pagePosition / totalPages).clamp(0.0, 1.0);
  }

  /// Get reading progress as percentage string
  String get progressText {
    if (totalPages <= 0) return '0%';
    final percentage = (progressPercentage * 100).round();
    return '$percentage%';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is HistoryModel &&
        other.id == id &&
        other.comicId == comicId &&
        other.chapterId == chapterId &&
        other.chapter == chapter &&
        other.urlCover == urlCover &&
        other.title == title &&
        other.nation == nation &&
        other.pagePosition == pagePosition &&
        other.totalPages == totalPages &&
        other.isCompleted == isCompleted &&
        other.readAt == readAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      comicId,
      chapterId,
      chapter,
      urlCover,
      title,
      nation,
      pagePosition,
      totalPages,
      isCompleted,
      readAt,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'HistoryModel('
        'id: $id, '
        'comicId: $comicId, '
        'chapterId: $chapterId, '
        'chapter: $chapter, '
        'urlCover: $urlCover, '
        'title: $title, '
        'nation: $nation, '
        'pagePosition: $pagePosition, '
        'totalPages: $totalPages, '
        'isCompleted: $isCompleted, '
        'readAt: $readAt, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
