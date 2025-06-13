import 'package:flutter/foundation.dart';

/// Comic Chapter model for tracking read chapters
/// Represents individual chapters that have been read by the user
@immutable
class ComicChapterModel {
  final int? id;
  final String comicId;
  final String chapter;
  final String chapterId;
  final bool isCompleted;
  final DateTime readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ComicChapterModel({
    this.id,
    required this.comicId,
    required this.chapter,
    required this.chapterId,
    this.isCompleted = false,
    required this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create ComicChapterModel from database map
  factory ComicChapterModel.fromMap(Map<String, dynamic> map) {
    return ComicChapterModel(
      id: map['id'] as int?,
      comicId: map['comic_id'] as String,
      chapter: map['chapter'] as String,
      chapterId: map['chapter_id'] as String,
      isCompleted: (map['is_completed'] as int? ?? 0) == 1,
      readAt: DateTime.fromMillisecondsSinceEpoch((map['read_at'] as int) * 1000),
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as int) * 1000),
    );
  }

  /// Convert ComicChapterModel to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'comic_id': comicId,
      'chapter': chapter,
      'chapter_id': chapterId,
      'is_completed': isCompleted ? 1 : 0,
      'read_at': readAt.millisecondsSinceEpoch ~/ 1000,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Create a copy of ComicChapterModel with updated fields
  ComicChapterModel copyWith({
    int? id,
    String? comicId,
    String? chapter,
    String? chapterId,
    bool? isCompleted,
    DateTime? readAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ComicChapterModel(
      id: id ?? this.id,
      comicId: comicId ?? this.comicId,
      chapter: chapter ?? this.chapter,
      chapterId: chapterId ?? this.chapterId,
      isCompleted: isCompleted ?? this.isCompleted,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create ComicChapterModel for insertion (without id and with current timestamp)
  factory ComicChapterModel.create({
    required String comicId,
    required String chapter,
    required String chapterId,
    bool isCompleted = false,
  }) {
    final now = DateTime.now();
    return ComicChapterModel(
      comicId: comicId,
      chapter: chapter,
      chapterId: chapterId,
      isCompleted: isCompleted,
      readAt: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Mark chapter as completed
  ComicChapterModel markCompleted() {
    return copyWith(
      isCompleted: true,
      readAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Mark chapter as incomplete
  ComicChapterModel markIncomplete() {
    return copyWith(
      isCompleted: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Update the readAt and updatedAt timestamp
  ComicChapterModel updateTimestamp() {
    final now = DateTime.now();
    return copyWith(
      readAt: now,
      updatedAt: now,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ComicChapterModel &&
        other.id == id &&
        other.comicId == comicId &&
        other.chapter == chapter &&
        other.chapterId == chapterId &&
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
      chapter,
      chapterId,
      isCompleted,
      readAt,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'ComicChapterModel('
        'id: $id, '
        'comicId: $comicId, '
        'chapter: $chapter, '
        'chapterId: $chapterId, '
        'isCompleted: $isCompleted, '
        'readAt: $readAt, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
