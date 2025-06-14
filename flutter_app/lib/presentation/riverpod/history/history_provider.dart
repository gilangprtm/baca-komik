import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/local/history_model.dart';
import 'history_notifier.dart';
import 'history_state.dart';

/// Main history provider
final historyProvider =
    StateNotifierProvider.autoDispose<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(const HistoryState(), ref);
});

/// History list provider
final historyListProvider = Provider.autoDispose<List<HistoryModel>>((ref) {
  return ref.watch(historyProvider.select((state) => state.history));
});

/// History status provider
final historyStatusProvider = Provider.autoDispose<HistoryStatus>((ref) {
  return ref.watch(historyProvider.select((state) => state.status));
});

/// History loading state provider
final historyLoadingProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(historyProvider.select((state) => state.isLoading));
});

/// History loading more state provider
final historyLoadingMoreProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(historyProvider.select((state) => state.isLoadingMore));
});

/// History error message provider
final historyErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(historyProvider.select((state) => state.errorMessage));
});

/// History count provider
final historyCountProvider = Provider.autoDispose<int>((ref) {
  return ref.watch(historyProvider.select((state) => state.totalCount));
});

/// History empty state provider
final historyEmptyProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(historyProvider.select((state) => state.isEmpty));
});

/// History has more provider
final historyHasMoreProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(historyProvider.select((state) => state.hasMore));
});

/// Provider to get history for specific comic
final comicHistoryProvider = FutureProvider.autoDispose
    .family<HistoryModel?, String>((ref, comicId) async {
  final notifier = ref.read(historyProvider.notifier);
  return await notifier.getComicHistory(comicId);
});

/// History pagination info provider
final historyPaginationProvider =
    Provider.autoDispose<Map<String, dynamic>>((ref) {
  final state = ref.watch(historyProvider);
  return {
    'current_page': state.currentPage,
    'total_count': state.totalCount,
    'has_more': state.hasMore,
    'can_load_more': state.canLoadMore,
  };
});

/// Recent history provider (last 5 items)
final recentHistoryProvider = Provider.autoDispose<List<HistoryModel>>((ref) {
  final history = ref.watch(historyListProvider);
  return history.take(5).toList();
});

/// Most read comics provider (based on history frequency)
final mostReadComicsProvider = Provider.autoDispose<List<HistoryModel>>((ref) {
  final history = ref.watch(historyListProvider);

  // Group by comic ID and count frequency
  final Map<String, HistoryModel> comicMap = {};
  final Map<String, int> readCount = {};

  for (final item in history) {
    comicMap[item.comicId] = item;
    readCount[item.comicId] = (readCount[item.comicId] ?? 0) + 1;
  }

  // Sort by read count and return top 10
  final sortedEntries = readCount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sortedEntries.take(10).map((entry) => comicMap[entry.key]!).toList();
});
