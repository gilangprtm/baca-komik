import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_state.dart';
import 'search_notifier.dart';

final searchProvider = StateNotifierProvider.autoDispose<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(const SearchState(), ref),
);
