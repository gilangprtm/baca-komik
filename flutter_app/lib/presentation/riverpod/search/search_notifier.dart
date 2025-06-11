import 'package:flutter/material.dart';
import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/network/service/shinigami_services.dart';
import 'search_state.dart';

class SearchNotifier extends BaseStateNotifier<SearchState> {
  final ShinigamiMangaService _mangaService = ShinigamiMangaService();

  // Controllers
  late final TextEditingController searchController;
  late final ScrollController scrollController;

  SearchNotifier(super.initialState, super.ref);

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers
    searchController = TextEditingController();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);

    // Load initial data
    loadTopDailyManga();
    loadAllManga();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  /// Handle scroll events for pagination (Search results)
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (state.canLoadMoreSearch) {
        loadMoreSearchResults();
      }
    }
  }

  /// Load top daily manga (GET /manga/top?filter=daily)
  Future<void> loadTopDailyManga({int page = 1}) async {
    runAsync('loadTopDailyManga', () async {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(
          topDailyStatus: SearchStatus.loading,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(isLoadingMoreTopDaily: true);
      }

      try {
        final response = await _mangaService.getTopManga(
          filter: 'daily',
          page: page,
          pageSize: 20,
        );

        if (page == 1) {
          // First page - replace results
          state = state.copyWith(
            topDailyStatus: SearchStatus.success,
            topDailyManga: response.data,
            topDailyMeta: response.meta,
            isLoadingMoreTopDaily: false,
            errorMessage: null,
          );
        } else {
          // Pagination - append results
          final combinedResults = [
            ...state.topDailyManga,
            ...response.data,
          ];

          state = state.copyWith(
            topDailyManga: combinedResults,
            topDailyMeta: response.meta,
            isLoadingMoreTopDaily: false,
            errorMessage: null,
          );
        }
      } catch (e, stackTrace) {
        logger.e('Error loading top daily manga',
            error: e, stackTrace: stackTrace);

        if (page == 1) {
          state = state.copyWith(
            topDailyStatus: SearchStatus.error,
            errorMessage: 'Failed to load top daily manga: ${e.toString()}',
          );
        } else {
          state = state.copyWith(
            isLoadingMoreTopDaily: false,
            errorMessage:
                'Failed to load more top daily manga: ${e.toString()}',
          );
        }
      }
    });
  }

  /// Load more top daily manga for pagination
  Future<void> loadMoreTopDailyManga() async {
    if (!state.canLoadMoreTopDaily) return;

    final nextPage = state.currentTopDailyPage + 1;
    await loadTopDailyManga(page: nextPage);
  }

  /// Search manga (GET /manga/list with search query)
  Future<void> searchManga({int page = 1}) async {
    if (state.query.isEmpty) {
      // Clear search results if query is empty
      state = state.copyWith(
        searchResults: const [],
        searchMeta: null,
        searchStatus: SearchStatus.initial,
      );
      return;
    }

    runAsync('searchManga', () async {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(searchStatus: SearchStatus.loading);
      } else {
        state = state.copyWith(isLoadingMoreSearch: true);
      }

      try {
        final response = await _mangaService.searchManga(
          query: state.query,
          page: page,
          pageSize: 20,
          genre: state.selectedGenre,
          format: state.selectedFormat,
          country: state.selectedCountry,
        );

        if (page == 1) {
          // First page - replace results
          state = state.copyWith(
            searchStatus: SearchStatus.success,
            searchResults: response.data,
            searchMeta: response.meta,
            isLoadingMoreSearch: false,
            hasMoreSearch: response.meta.hasMore,
            errorMessage: null,
          );
        } else {
          // Pagination - append results
          final combinedResults = [
            ...state.searchResults,
            ...response.data,
          ];

          state = state.copyWith(
            searchResults: combinedResults,
            searchMeta: response.meta,
            isLoadingMoreSearch: false,
            hasMoreSearch: response.meta.hasMore,
            errorMessage: null,
          );
        }
      } catch (e, stackTrace) {
        logger.e('Error searching manga', error: e, stackTrace: stackTrace);

        if (page == 1) {
          state = state.copyWith(
            searchStatus: SearchStatus.error,
            errorMessage: 'Failed to search manga: ${e.toString()}',
          );
        } else {
          state = state.copyWith(
            isLoadingMoreSearch: false,
            errorMessage: 'Failed to load more results: ${e.toString()}',
          );
        }
      }
    });
  }

  /// Load more search results for pagination
  Future<void> loadMoreSearchResults() async {
    if (!state.canLoadMoreSearch) return;

    final nextPage = state.currentSearchPage + 1;
    await searchManga(page: nextPage);
  }

  /// Load all manga (GET /manga/list without search query)
  Future<void> loadAllManga({int page = 1}) async {
    runAsync('loadAllManga', () async {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(searchStatus: SearchStatus.loading);
      } else {
        state = state.copyWith(isLoadingMoreSearch: true);
      }

      try {
        final response = await _mangaService.getMangaList(
          page: page,
          pageSize: 20,
          genre: state.selectedGenre,
          format: state.selectedFormat,
          country: state.selectedCountry,
          sort: state.sortBy ?? 'rating',
        );

        if (page == 1) {
          // First page - replace results
          state = state.copyWith(
            searchStatus: SearchStatus.success,
            searchResults: response.data,
            searchMeta: response.meta,
            isLoadingMoreSearch: false,
            hasMoreSearch: response.meta.hasMore,
            errorMessage: null,
          );
        } else {
          // Pagination - append results
          final combinedResults = [
            ...state.searchResults,
            ...response.data,
          ];

          state = state.copyWith(
            searchResults: combinedResults,
            searchMeta: response.meta,
            isLoadingMoreSearch: false,
            hasMoreSearch: response.meta.hasMore,
            errorMessage: null,
          );
        }
      } catch (e, stackTrace) {
        logger.e('Error loading all manga', error: e, stackTrace: stackTrace);

        if (page == 1) {
          state = state.copyWith(
            searchStatus: SearchStatus.error,
            errorMessage: 'Failed to load manga: ${e.toString()}',
          );
        } else {
          state = state.copyWith(
            isLoadingMoreSearch: false,
            errorMessage: 'Failed to load more manga: ${e.toString()}',
          );
        }
      }
    });
  }

  /// Load more all manga for pagination
  Future<void> loadMoreAllManga() async {
    if (!state.canLoadMoreSearch) return;

    final nextPage = state.currentSearchPage + 1;
    await loadAllManga(page: nextPage);
  }

  /// Update search query (called on text change, but doesn't trigger search)
  void updateSearchQuery(String query) {
    // Only update the query in state, don't trigger search
    state = state.copyWith(query: query.trim());
  }

  /// Search comics (called when user submits/finishes typing)
  void searchComics(String query) {
    // Update query and trigger search
    state = state.copyWith(query: query.trim());

    // Trigger search
    searchManga();
  }

  /// Clear search query
  void clearSearch() {
    searchController.clear();
    state = state.copyWith(
      query: '',
      searchResults: const [],
      searchMeta: null,
      searchStatus: SearchStatus.initial,
    );
  }

  /// Apply filters
  void applyFilters({
    String? country,
    String? genre,
    String? format,
    String? sort,
  }) {
    state = state.copyWith(
      selectedCountry: country,
      selectedGenre: genre,
      selectedFormat: format,
      sortBy: sort,
    );

    // Re-trigger search with new filters if there's a query
    if (state.query.isNotEmpty) {
      searchManga();
    }
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(
      selectedCountry: null,
      selectedGenre: null,
      selectedFormat: null,
      sortBy: null,
    );

    // Re-trigger search without filters if there's a query
    if (state.query.isNotEmpty) {
      searchManga();
    }
  }

  /// Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      loadTopDailyManga(),
      if (state.query.isNotEmpty) searchManga() else loadAllManga(),
    ]);
  }
}
