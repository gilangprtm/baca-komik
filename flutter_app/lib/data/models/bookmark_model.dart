import 'comic_model.dart';

class Bookmark {
  final String idKomik;
  final String idUser;
  final DateTime? createdAt;
  final Comic? comic;

  Bookmark({
    required this.idKomik,
    required this.idUser,
    this.createdAt,
    this.comic,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      idKomik: json['id_komik'],
      idUser: json['id_user'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      comic: json['mKomik'] != null ? Comic.fromJson(json['mKomik']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_komik': idKomik,
      'id_user': idUser,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class BookmarkRequest {
  final String idKomik;

  BookmarkRequest({
    required this.idKomik,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_komik': idKomik,
    };
  }
}
