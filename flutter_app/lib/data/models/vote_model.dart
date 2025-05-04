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
  final String? message;

  VoteResponse({
    required this.success,
    this.message,
  });

  factory VoteResponse.fromJson(Map<String, dynamic> json) {
    return VoteResponse(
      success: json['success'] ?? false,
      message: json['message'],
    );
  }
}

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
}
