import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bookmark_state.dart';
import 'bookmark_notifier.dart';

final bookmarkProvider = StateNotifierProvider.autoDispose<BookmarkNotifier, BookmarkState>(
  (ref) => BookmarkNotifier(const BookmarkState(), ref),
);
