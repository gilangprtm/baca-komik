import 'package:flutter/foundation.dart';
import '../../../data/models/shinigami/shinigami_models.dart';

enum SearchStatus { initial, loading, success, error }

@immutable
class SearchState {
  // Search query
  final String query;

  // Top daily manga state (GET /manga/top?filter=daily)
  final SearchStatus topDailyStatus;
  final List<ShinigamiManga> topDailyManga;
  final ShinigamiMeta? topDailyMeta;
  final bool isLoadingMoreTopDaily;

  // Search results state (GET /manga/list with search query)
  final SearchStatus searchStatus;
  final List<ShinigamiManga> searchResults;
  final ShinigamiMeta? searchMeta;
  final bool isLoadingMoreSearch;
  final bool hasMoreSearch;

  // Common state
  final String? errorMessage;

  // Filter state
  final String? selectedGenre;
  final String? selectedFormat;
  final String? selectedCountry;
  final String? sortBy;

  const SearchState({
    this.query = '',
    this.topDailyStatus = SearchStatus.initial,
    this.topDailyManga = const [],
    this.topDailyMeta,
    this.isLoadingMoreTopDaily = false,
    this.searchStatus = SearchStatus.initial,
    this.searchResults = const [],
    this.searchMeta,
    this.isLoadingMoreSearch = false,
    this.hasMoreSearch = true,
    this.errorMessage,
    this.selectedGenre,
    this.selectedFormat,
    this.selectedCountry,
    this.sortBy,
  });

  SearchState copyWith({
    String? query,
    SearchStatus? topDailyStatus,
    List<ShinigamiManga>? topDailyManga,
    ShinigamiMeta? topDailyMeta,
    bool? isLoadingMoreTopDaily,
    SearchStatus? searchStatus,
    List<ShinigamiManga>? searchResults,
    ShinigamiMeta? searchMeta,
    bool? isLoadingMoreSearch,
    bool? hasMoreSearch,
    String? errorMessage,
    String? selectedGenre,
    String? selectedFormat,
    String? selectedCountry,
    String? sortBy,
  }) {
    return SearchState(
      query: query ?? this.query,
      topDailyStatus: topDailyStatus ?? this.topDailyStatus,
      topDailyManga: topDailyManga ?? this.topDailyManga,
      topDailyMeta: topDailyMeta ?? this.topDailyMeta,
      isLoadingMoreTopDaily:
          isLoadingMoreTopDaily ?? this.isLoadingMoreTopDaily,
      searchStatus: searchStatus ?? this.searchStatus,
      searchResults: searchResults ?? this.searchResults,
      searchMeta: searchMeta ?? this.searchMeta,
      isLoadingMoreSearch: isLoadingMoreSearch ?? this.isLoadingMoreSearch,
      hasMoreSearch: hasMoreSearch ?? this.hasMoreSearch,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedGenre: selectedGenre ?? this.selectedGenre,
      selectedFormat: selectedFormat ?? this.selectedFormat,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  // Helper methods for search
  bool get isSearching => query.isNotEmpty;
  bool get canLoadMoreSearch => hasMoreSearch && !isLoadingMoreSearch;
  int get currentSearchPage => searchMeta?.currentPage ?? 0;
  int get totalSearchResults => searchMeta?.total ?? 0;
  bool get hasSearchResults => searchResults.isNotEmpty;

  // Helper methods for top daily
  bool get hasTopDailyManga => topDailyManga.isNotEmpty;
  bool get isTopDailyLoading => topDailyStatus == SearchStatus.loading;
  bool get isSearchLoading => searchStatus == SearchStatus.loading;
  bool get canLoadMoreTopDaily => topDailyMeta?.hasMore ?? false;
  int get currentTopDailyPage => topDailyMeta?.currentPage ?? 1;

  // Helper methods for filters
  bool get hasActiveFilters =>
      selectedGenre != null ||
      selectedFormat != null ||
      selectedCountry != null ||
      sortBy != null;

  Map<String, String?> get activeFilters => {
        'genre': selectedGenre,
        'format': selectedFormat,
        'country': selectedCountry,
        'sort': sortBy,
      };
}
