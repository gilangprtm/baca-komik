import 'comic_model.dart';

class Bookmark {
  final String idKomik;
  final String idUser;
  final DateTime? createdDate;
  final Comic? comic;

  Bookmark({
    required this.idKomik,
    required this.idUser,
    this.createdDate,
    this.comic,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      idKomik: json['id_komik'],
      idUser: json['id_user'],
      createdDate: json['created_date'] != null
          ? DateTime.parse(json['created_date'])
          : null,
      comic: json['mKomik'] != null ? Comic.fromJson(json['mKomik']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_komik': idKomik,
      'id_user': idUser,
      'created_date': createdDate?.toIso8601String(),
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
