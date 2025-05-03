import 'user_model.dart';

class Comment {
  final String id;
  final String content;
  final String idUser;
  final String? idKomik;
  final String? idChapter;
  final String? parentId;
  final DateTime createdDate;
  final User? user;
  final List<CommentReply>? replies;

  Comment({
    required this.id,
    required this.content,
    required this.idUser,
    this.idKomik,
    this.idChapter,
    this.parentId,
    required this.createdDate,
    this.user,
    this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      idUser: json['id_user'],
      idKomik: json['id_komik'],
      idChapter: json['id_chapter'],
      parentId: json['parent_id'],
      createdDate: DateTime.parse(json['created_date']),
      user: json['mUser'] != null ? User.fromJson(json['mUser']) : null,
      replies: json['replies'] != null
          ? List<CommentReply>.from(
              json['replies'].map((x) => CommentReply.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'id_user': idUser,
      'id_komik': idKomik,
      'id_chapter': idChapter,
      'parent_id': parentId,
      'created_date': createdDate.toIso8601String(),
    };
  }
}

class CommentReply {
  final String id;
  final String content;
  final DateTime createdDate;
  final User user;

  CommentReply({
    required this.id,
    required this.content,
    required this.createdDate,
    required this.user,
  });

  factory CommentReply.fromJson(Map<String, dynamic> json) {
    return CommentReply(
      id: json['id'],
      content: json['content'],
      createdDate: DateTime.parse(json['created_date']),
      user: User.fromJson(json['mUser']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'created_date': createdDate.toIso8601String(),
    };
  }
}

class CommentRequest {
  final String content;
  final String? idKomik;
  final String? idChapter;
  final String? parentId;

  CommentRequest({
    required this.content,
    this.idKomik,
    this.idChapter,
    this.parentId,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'content': content,
    };
    
    if (idKomik != null) data['id_komik'] = idKomik;
    if (idChapter != null) data['id_chapter'] = idChapter;
    if (parentId != null) data['parent_id'] = parentId;
    
    return data;
  }
}
