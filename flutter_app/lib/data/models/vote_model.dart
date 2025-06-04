/// Model untuk request vote
class VoteRequest {
  final String? idKomik;
  final String? idChapter;

  VoteRequest({
    this.idKomik,
    this.idChapter,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (idKomik != null) data['id_komik'] = idKomik;
    if (idChapter != null) data['id_chapter'] = idChapter;

    return data;
  }
}

/// Model untuk response vote dari API
class VoteResponse {
  final String idUser;
  final String? idKomik;
  final String? idChapter;
  final DateTime createdAt;

  VoteResponse({
    required this.idUser,
    this.idKomik,
    this.idChapter,
    required this.createdAt,
  });

  factory VoteResponse.fromJson(Map<String, dynamic> json) {
    return VoteResponse(
      idUser: json['id_user'],
      idKomik: json['id_komik'],
      idChapter: json['id_chapter'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// Model untuk response success/error
class VoteResult {
  final bool success;
  final String message;
  final bool voted;
  final int voteCount;

  VoteResult({
    required this.success,
    required this.message,
    required this.voted,
    required this.voteCount,
  });

  factory VoteResult.fromJson(Map<String, dynamic> json) {
    return VoteResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      voted: json['voted'] ?? false,
      voteCount: json['vote_count'] ?? 0,
    );
  }
}

/// Model untuk delete vote response
class DeleteVoteResponse {
  final bool success;

  DeleteVoteResponse({
    required this.success,
  });

  factory DeleteVoteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteVoteResponse(
      success: json['success'] ?? false,
    );
  }
}
