import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vote_state.dart';
import 'vote_notifier.dart';

final voteProvider = StateNotifierProvider<VoteNotifier, VoteState>(
  (ref) => VoteNotifier(const VoteState(), ref),
);
