import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comment_state.dart';
import 'comment_notifier.dart';

final commentProvider = StateNotifierProvider<CommentNotifier, CommentState>(
  (ref) => CommentNotifier(const CommentState(), ref),
);
