import 'package:flutter/foundation.dart';

enum VoteStateStatus { initial, loading, success, error }

@immutable
class VoteState {
  final VoteStateStatus status;
  final Map<String, bool> comicVotes; // Map of comic IDs to vote status
  final Map<String, bool> chapterVotes; // Map of chapter IDs to vote status
  final String? errorMessage;
  final bool isVoting;

  const VoteState({
    this.status = VoteStateStatus.initial,
    this.comicVotes = const {},
    this.chapterVotes = const {},
    this.errorMessage,
    this.isVoting = false,
  });

  VoteState copyWith({
    VoteStateStatus? status,
    Map<String, bool>? comicVotes,
    Map<String, bool>? chapterVotes,
    String? errorMessage,
    bool? isVoting,
  }) {
    return VoteState(
      status: status ?? this.status,
      comicVotes: comicVotes ?? this.comicVotes,
      chapterVotes: chapterVotes ?? this.chapterVotes,
      errorMessage: errorMessage ?? this.errorMessage,
      isVoting: isVoting ?? this.isVoting,
    );
  }

  // Helper methods
  bool isComicVoted(String comicId) => comicVotes[comicId] ?? false;
  bool isChapterVoted(String chapterId) => chapterVotes[chapterId] ?? false;
}
