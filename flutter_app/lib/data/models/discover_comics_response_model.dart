import 'comic_model.dart';
import 'pagination_model.dart';

/// Model untuk response dari endpoint /comics/discover
class DiscoverComicsResponse {
  final List<PopularComic> popular;
  final List<RecommendedComic> recommended;
  final SearchResults searchResults;

  DiscoverComicsResponse({
    required this.popular,
    required this.recommended,
    required this.searchResults,
  });

  factory DiscoverComicsResponse.fromJson(Map<String, dynamic> json) {
    return DiscoverComicsResponse(
      popular: (json['popular'] as List<dynamic>)
          .map((comic) => PopularComic.fromJson(comic as Map<String, dynamic>))
          .toList(),
      recommended: (json['recommended'] as List<dynamic>)
          .map((comic) =>
              RecommendedComic.fromJson(comic as Map<String, dynamic>))
          .toList(),
      searchResults: SearchResults.fromJson(
          json['search_results'] as Map<String, dynamic>),
    );
  }

  // For empty responses or error handling
  factory DiscoverComicsResponse.empty() {
    return DiscoverComicsResponse(
      popular: <PopularComic>[],
      recommended: <RecommendedComic>[],
      searchResults: SearchResults.empty(),
    );
  }
}

/// Model untuk komik populer
class PopularComic {
  final String id;
  final String title;
  final String? coverImageUrl;
  final String? countryId;
  final int viewCount;

  PopularComic({
    required this.id,
    required this.title,
    this.coverImageUrl,
    this.countryId,
    required this.viewCount,
  });

  factory PopularComic.fromJson(Map<String, dynamic> json) {
    return PopularComic(
      id: json['id'],
      title: json['title'],
      coverImageUrl: json['cover_image_url'],
      countryId: json['country_id'],
      viewCount: json['view_count'] ?? 0,
    );
  }
}

/// Model untuk komik rekomendasi
class RecommendedComic {
  final String id;
  final String title;
  final String? coverImageUrl;
  final String? countryId;

  RecommendedComic({
    required this.id,
    required this.title,
    this.coverImageUrl,
    this.countryId,
  });

  factory RecommendedComic.fromJson(Map<String, dynamic> json) {
    return RecommendedComic(
      id: json['id'],
      title: json['title'],
      coverImageUrl: json['cover_image_url'],
      countryId: json['country_id'],
    );
  }
}

/// Model untuk hasil pencarian
class SearchResults {
  final List<Comic> data;
  final PaginationMeta meta;

  SearchResults({
    required this.data,
    required this.meta,
  });

  factory SearchResults.fromJson(Map<String, dynamic> json) {
    return SearchResults(
      data: (json['data'] as List<dynamic>)
          .map((comic) => Comic.fromJson(comic as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  factory SearchResults.empty() {
    return SearchResults(
      data: <Comic>[],
      meta: PaginationMeta.empty(1, 10),
    );
  }
}
