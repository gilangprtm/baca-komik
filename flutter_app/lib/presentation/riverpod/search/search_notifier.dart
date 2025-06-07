import 'package:flutter/material.dart';
import '../../../core/base/base_state_notifier.dart';
import '../../../data/datasource/network/service/comic_service.dart';
import '../../../data/datasource/network/service/optimized_comic_service.dart';
import 'search_state.dart';

class SearchNotifier extends BaseStateNotifier<SearchState> {
  final ComicService _comicService = ComicService();
  final OptimizedComicService _optimizedComicService = OptimizedComicService();

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

    // Load initial data for both tabs
    loadAllComics();
    loadDiscoverContent();
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

  /// Handle scroll events for pagination (All Comics tab)
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (state.canLoadMoreAllComics) {
        loadMoreAllComics();
      }
    }
  }

  /// Load all comics (GET /comics)
  Future<void> loadAllComics({int page = 1}) async {
    runAsync('loadAllComics', () async {
      // Set loading state
      if (page == 1) {
        state = state.copyWith(allComicsStatus: SearchStatus.loading);
      } else {
        state = state.copyWith(isLoadingMoreAllComics: true);
      }

      try {
        final comicsResponse = await _comicService.getComics(
          page: page,
          limit: 20,
          search: state.query.isNotEmpty ? state.query : null,
          genre: state.selectedGenre,
          status: state.selectedCountry,
        );

        if (page == 1) {
          // First page - replace results
          state = state.copyWith(
            allComicsStatus: SearchStatus.success,
            allComics: comicsResponse.data,
            allComicsMeta: comicsResponse.meta,
            isLoadingMoreAllComics: false,
            hasMoreAllComics: comicsResponse.meta.hasMore,
            errorMessage: null,
          );
        } else {
          // Pagination - append results
          final combinedResults = [
            ...state.allComics,
            ...comicsResponse.data,
          ];

          state = state.copyWith(
            allComics: combinedResults,
            allComicsMeta: comicsResponse.meta,
            isLoadingMoreAllComics: false,
            hasMoreAllComics: comicsResponse.meta.hasMore,
            errorMessage: null,
          );
        }
      } catch (e, stackTrace) {
        logger.e('Error loading all comics', error: e, stackTrace: stackTrace);

        if (page == 1) {
          state = state.copyWith(
            allComicsStatus: SearchStatus.error,
            errorMessage: 'Failed to load comics: ${e.toString()}',
          );
        } else {
          state = state.copyWith(
            isLoadingMoreAllComics: false,
            errorMessage: 'Failed to load more comics: ${e.toString()}',
          );
        }
      }
    });
  }

  /// Load more all comics for pagination
  Future<void> loadMoreAllComics() async {
    if (!state.canLoadMoreAllComics) return;

    final nextPage = state.currentAllComicsPage + 1;
    await loadAllComics(page: nextPage);
  }

  /// Load discover content (popular and recommended comics)
  Future<void> loadDiscoverContent() async {
    runAsync('loadDiscoverContent', () async {
      state = state.copyWith(discoverStatus: SearchStatus.loading);

      try {
        final discoverResponse = await _optimizedComicService.getDiscoverComics(
          limit: 20,
        );

        state = state.copyWith(
          discoverStatus: SearchStatus.success,
          popularComics: discoverResponse.popular,
          recommendedComics: discoverResponse.recommended,
          errorMessage: null,
        );
      } catch (e, stackTrace) {
        logger.e('Error loading discover content',
            error: e, stackTrace: stackTrace);
        state = state.copyWith(
          discoverStatus: SearchStatus.error,
          errorMessage: 'Failed to load discover content: ${e.toString()}',
        );
      }
    });
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

    // If query is empty, load all comics without search
    if (query.trim().isEmpty) {
      loadAllComics();
      return;
    }

    // Trigger search immediately
    loadAllComics();
  }

  /// Clear search query
  void clearSearch() {
    searchController.clear();
    state = state.copyWith(query: '');
    // Reload all comics without search
    loadAllComics();
  }

  /// Apply filters
  void applyFilters({String? country, String? genre}) {
    state = state.copyWith(
      selectedCountry: country,
      selectedGenre: genre,
    );

    // Reload all comics with new filters
    loadAllComics();
  }

  /// Clear filters
  void clearFilters() {
    state = state.copyWith(
      selectedCountry: null,
      selectedGenre: null,
    );

    // Reload all comics without filters
    loadAllComics();
  }
}
