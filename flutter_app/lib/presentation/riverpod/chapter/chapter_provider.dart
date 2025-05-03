import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'chapter_state.dart';
import 'chapter_notifier.dart';

final chapterProvider = StateNotifierProvider.autoDispose<ChapterNotifier, ChapterState>(
  (ref) => ChapterNotifier(const ChapterState(), ref),
);
