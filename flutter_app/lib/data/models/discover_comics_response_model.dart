import 'home_comic_model.dart';
import 'pagination_model.dart';

class DiscoverComicsResponse {
  final List<HomeComic> data;
  final PaginationMeta meta;

  DiscoverComicsResponse({
    required this.data,
    required this.meta,
  });

  factory DiscoverComicsResponse.fromJson(Map<String, dynamic> json) {
    List<HomeComic> comics = (json['data'] as List<dynamic>)
        .map((comic) => comic is HomeComic
            ? comic
            : HomeComic.fromJson(comic as Map<String, dynamic>))
        .toList();

    return DiscoverComicsResponse(
      data: comics,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  // For empty responses or error handling
  factory DiscoverComicsResponse.empty(int page, int limit) {
    return DiscoverComicsResponse(
      data: <HomeComic>[],
      meta: PaginationMeta.empty(page, limit),
    );
  }
}
