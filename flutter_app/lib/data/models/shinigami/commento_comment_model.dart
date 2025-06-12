/// Comment model for Commento API
class CommentoComment {
  final String status;
  final String comment;
  final String link;
  final String nick;
  final int? pid;
  final int? rid;
  final int userId;
  final dynamic sticky;
  final int like;
  final int objectId;
  final int level;
  final String type;
  final dynamic label;
  final String avatar;
  final String orig;
  final int time;
  final List<CommentoComment> children;
  final CommentoReplyUser? replyUser;

  CommentoComment({
    required this.status,
    required this.comment,
    required this.link,
    required this.nick,
    this.pid,
    this.rid,
    required this.userId,
    this.sticky,
    required this.like,
    required this.objectId,
    required this.level,
    required this.type,
    this.label,
    required this.avatar,
    required this.orig,
    required this.time,
    required this.children,
    this.replyUser,
  });

  factory CommentoComment.fromJson(Map<String, dynamic> json) {
    return CommentoComment(
      status: json['status'] ?? '',
      comment: json['comment'] ?? '',
      link: json['link'] ?? '',
      nick: json['nick'] ?? '',
      pid: json['pid'],
      rid: json['rid'],
      userId: json['user_id'] ?? 0,
      sticky: json['sticky'],
      like: json['like'] ?? 0,
      objectId: json['objectId'] ?? 0,
      level: json['level'] ?? 0,
      type: json['type'] ?? '',
      label: json['label'],
      avatar: json['avatar'] ?? '',
      orig: json['orig'] ?? '',
      time: json['time'] ?? 0,
      children: (json['children'] as List<dynamic>?)
              ?.map((child) =>
                  CommentoComment.fromJson(child as Map<String, dynamic>))
              .toList() ??
          [],
      replyUser: json['reply_user'] != null
          ? CommentoReplyUser.fromJson(
              json['reply_user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'comment': comment,
      'link': link,
      'nick': nick,
      'pid': pid,
      'rid': rid,
      'user_id': userId,
      'sticky': sticky,
      'like': like,
      'objectId': objectId,
      'level': level,
      'type': type,
      'label': label,
      'avatar': avatar,
      'orig': orig,
      'time': time,
      'children': children.map((child) => child.toJson()).toList(),
      'reply_user': replyUser?.toJson(),
    };
  }

  /// Get formatted date from timestamp
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(time);

  /// Get clean comment text without newlines
  String get cleanComment => comment.trim().replaceAll('\n', ' ');

  /// Get original HTML content for rendering (includes emojis)
  String get htmlContent => comment;

  /// Get plain text content (fallback if HTML rendering fails)
  String get plainTextContent => cleanComment;

  /// Check if this is a root comment (not a reply)
  bool get isRootComment => level == 0 && pid == null;

  /// Check if this comment has replies
  bool get hasReplies => children.isNotEmpty;

  /// Get total reply count (including nested replies)
  int get totalReplyCount {
    int count = children.length;
    for (final child in children) {
      count += child.totalReplyCount;
    }
    return count;
  }

  /// Check if comment is approved
  bool get isApproved => status == 'approved';

  @override
  String toString() {
    return 'CommentoComment(nick: $nick, comment: $cleanComment, level: $level, children: ${children.length})';
  }
}

/// Reply user information for nested comments
class CommentoReplyUser {
  final String nick;
  final String link;
  final String avatar;

  CommentoReplyUser({
    required this.nick,
    required this.link,
    required this.avatar,
  });

  factory CommentoReplyUser.fromJson(Map<String, dynamic> json) {
    return CommentoReplyUser(
      nick: json['nick'] ?? '',
      link: json['link'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nick': nick,
      'link': link,
      'avatar': avatar,
    };
  }

  @override
  String toString() {
    return 'CommentoReplyUser(nick: $nick)';
  }
}
