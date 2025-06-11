import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/shinigami/shinigami_models.dart';
import 'search_state.dart';
import 'search_notifier.dart';

/// Main search provider
final searchProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(const SearchState(), ref),
);

/// Provider for top daily manga
final searchTopDailyProvider =
    Provider.autoDispose<List<ShinigamiManga>>((ref) {
  return ref.watch(searchProvider.select((state) => state.topDailyManga));
});

/// Provider for search results
final searchResultsProvider = Provider.autoDispose<List<ShinigamiManga>>((ref) {
  return ref.watch(searchProvider.select((state) => state.searchResults));
});

/// Provider for search query
final searchQueryProvider = Provider.autoDispose<String>((ref) {
  return ref.watch(searchProvider.select((state) => state.query));
});

/// Provider for top daily status
final searchTopDailyStatusProvider = Provider.autoDispose<SearchStatus>((ref) {
  return ref.watch(searchProvider.select((state) => state.topDailyStatus));
});

/// Provider for search status
final searchStatusProvider = Provider.autoDispose<SearchStatus>((ref) {
  return ref.watch(searchProvider.select((state) => state.searchStatus));
});

/// Provider for loading states
final searchLoadingProvider = Provider.autoDispose<Map<String, bool>>((ref) {
  final state = ref.watch(searchProvider);
  return {
    'is_top_daily_loading': state.isTopDailyLoading,
    'is_search_loading': state.isSearchLoading,
    'is_loading_more': state.isLoadingMoreSearch,
  };
});

/// Provider for error message
final searchErrorProvider = Provider.autoDispose<String?>((ref) {
  return ref.watch(searchProvider.select((state) => state.errorMessage));
});

/// Provider for search info
final searchInfoProvider = Provider.autoDispose<Map<String, dynamic>>((ref) {
  final state = ref.watch(searchProvider);
  return {
    'query': state.query,
    'is_searching': state.isSearching,
    'has_results': state.hasSearchResults,
    'total_results': state.totalSearchResults,
    'can_load_more': state.canLoadMoreSearch,
  };
});

/// Provider for data availability
final searchDataAvailableProvider =
    Provider.autoDispose<Map<String, bool>>((ref) {
  final state = ref.watch(searchProvider);
  return {
    'has_top_daily': state.hasTopDailyManga,
    'has_search_results': state.hasSearchResults,
  };
});

/// Provider for active filters
final searchActiveFiltersProvider =
    Provider.autoDispose<Map<String, String?>>((ref) {
  return ref.watch(searchProvider.select((state) => state.activeFilters));
});

/// Provider for filter status
final searchHasActiveFiltersProvider = Provider.autoDispose<bool>((ref) {
  return ref.watch(searchProvider.select((state) => state.hasActiveFilters));
});

/// Provider for pagination info
final searchPaginationProvider =
    Provider.autoDispose<Map<String, dynamic>>((ref) {
  final state = ref.watch(searchProvider);
  return {
    'current_page': state.currentSearchPage,
    'total_results': state.totalSearchResults,
    'has_more': state.hasMoreSearch,
    'is_loading_more': state.isLoadingMoreSearch,
  };
});
