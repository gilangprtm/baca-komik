import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'comic_state.dart';
import 'comic_notifier.dart';

final comicProvider = StateNotifierProvider.autoDispose<ComicNotifier, ComicState>(
  (ref) => ComicNotifier(const ComicState(), ref),
);
