import 'package:flutter/foundation.dart';
import '../../../data/models/comic_model.dart';
import '../../../data/models/discover_comics_response_model.dart';
import '../../../data/models/pagination_model.dart';

enum SearchStatus { initial, loading, success, error }

@immutable
class SearchState {
  // Search query
  final String query;

  // All Comics tab state (GET /comics)
  final SearchStatus allComicsStatus;
  final List<Comic> allComics;
  final PaginationMeta? allComicsMeta;
  final bool isLoadingMoreAllComics;
  final bool hasMoreAllComics;

  // Discover tab state (GET /comics/discover)
  final SearchStatus discoverStatus;
  final List<PopularComic> popularComics;
  final List<RecommendedComic> recommendedComics;

  // Common state
  final String? errorMessage;

  // Filter state
  final String? selectedCountry;
  final String? selectedGenre;

  const SearchState({
    this.query = '',
    this.allComicsStatus = SearchStatus.initial,
    this.allComics = const [],
    this.allComicsMeta,
    this.isLoadingMoreAllComics = false,
    this.hasMoreAllComics = true,
    this.discoverStatus = SearchStatus.initial,
    this.popularComics = const [],
    this.recommendedComics = const [],
    this.errorMessage,
    this.selectedCountry,
    this.selectedGenre,
  });

  SearchState copyWith({
    String? query,
    SearchStatus? allComicsStatus,
    List<Comic>? allComics,
    PaginationMeta? allComicsMeta,
    bool? isLoadingMoreAllComics,
    bool? hasMoreAllComics,
    SearchStatus? discoverStatus,
    List<PopularComic>? popularComics,
    List<RecommendedComic>? recommendedComics,
    String? errorMessage,
    String? selectedCountry,
    String? selectedGenre,
  }) {
    return SearchState(
      query: query ?? this.query,
      allComicsStatus: allComicsStatus ?? this.allComicsStatus,
      allComics: allComics ?? this.allComics,
      allComicsMeta: allComicsMeta ?? this.allComicsMeta,
      isLoadingMoreAllComics:
          isLoadingMoreAllComics ?? this.isLoadingMoreAllComics,
      hasMoreAllComics: hasMoreAllComics ?? this.hasMoreAllComics,
      discoverStatus: discoverStatus ?? this.discoverStatus,
      popularComics: popularComics ?? this.popularComics,
      recommendedComics: recommendedComics ?? this.recommendedComics,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedGenre: selectedGenre ?? this.selectedGenre,
    );
  }

  // Helper methods for All Comics tab
  bool get isSearching => query.isNotEmpty;
  bool get canLoadMoreAllComics => hasMoreAllComics && !isLoadingMoreAllComics;
  int get currentAllComicsPage => allComicsMeta?.page ?? 0;
  int get totalAllComics => allComicsMeta?.total ?? 0;
  bool get hasAllComics => allComics.isNotEmpty;

  // Helper methods for Discover tab
  bool get hasDiscoverContent =>
      popularComics.isNotEmpty || recommendedComics.isNotEmpty;
}
