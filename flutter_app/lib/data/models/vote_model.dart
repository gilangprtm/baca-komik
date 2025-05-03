class Vote {
  final String id;
  final String type; // 'comic' or 'chapter'

  Vote({
    required this.id,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
    };
  }
}

class VoteResponse {
  final bool success;

  VoteResponse({
    required this.success,
  });

  factory VoteResponse.fromJson(Map<String, dynamic> json) {
    return VoteResponse(
      success: json['success'],
    );
  }
}
