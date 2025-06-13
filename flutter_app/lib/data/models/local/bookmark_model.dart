import 'package:flutter/foundation.dart';

/// Bookmark model for storing user's bookmarked comics
/// Represents a comic that user has bookmarked for easy access
@immutable
class BookmarkModel {
  final int? id;
  final String comicId;
  final String urlCover;
  final String title;
  final String nation;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookmarkModel({
    this.id,
    required this.comicId,
    required this.urlCover,
    required this.title,
    required this.nation,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create BookmarkModel from database map
  factory BookmarkModel.fromMap(Map<String, dynamic> map) {
    return BookmarkModel(
      id: map['id'] as int?,
      comicId: map['comic_id'] as String,
      urlCover: map['url_cover'] as String,
      title: map['title'] as String,
      nation: map['nation'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch((map['created_at'] as int) * 1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((map['updated_at'] as int) * 1000),
    );
  }

  /// Convert BookmarkModel to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'comic_id': comicId,
      'url_cover': urlCover,
      'title': title,
      'nation': nation,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Create a copy of BookmarkModel with updated fields
  BookmarkModel copyWith({
    int? id,
    String? comicId,
    String? urlCover,
    String? title,
    String? nation,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookmarkModel(
      id: id ?? this.id,
      comicId: comicId ?? this.comicId,
      urlCover: urlCover ?? this.urlCover,
      title: title ?? this.title,
      nation: nation ?? this.nation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create BookmarkModel for insertion (without id and with current timestamp)
  factory BookmarkModel.create({
    required String comicId,
    required String urlCover,
    required String title,
    required String nation,
  }) {
    final now = DateTime.now();
    return BookmarkModel(
      comicId: comicId,
      urlCover: urlCover,
      title: title,
      nation: nation,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Update the updatedAt timestamp
  BookmarkModel updateTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is BookmarkModel &&
        other.id == id &&
        other.comicId == comicId &&
        other.urlCover == urlCover &&
        other.title == title &&
        other.nation == nation &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      comicId,
      urlCover,
      title,
      nation,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'BookmarkModel('
        'id: $id, '
        'comicId: $comicId, '
        'urlCover: $urlCover, '
        'title: $title, '
        'nation: $nation, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
