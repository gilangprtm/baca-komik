import 'comic_model.dart';
import 'pagination_model.dart';

class ComicsResponse {
  final List<Comic> data;
  final PaginationMeta meta;

  ComicsResponse({
    required this.data,
    required this.meta,
  });

  factory ComicsResponse.fromJson(Map<String, dynamic> json) {
    // Process the data list
    final List<Comic> comics = (json['data'] as List<dynamic>)
        .map((comic) => comic is Comic
            ? comic
            : Comic.fromJson(comic as Map<String, dynamic>))
        .toList();

    return ComicsResponse(
      data: comics,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  // For empty responses or error handling
  factory ComicsResponse.empty(int page, int limit) {
    return ComicsResponse(
      data: <Comic>[],
      meta: PaginationMeta.empty(page, limit),
    );
  }
}
