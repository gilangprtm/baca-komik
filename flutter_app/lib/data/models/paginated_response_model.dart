import 'pagination_model.dart';

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  PaginatedResponse({
    required this.data,
    required this.meta,
  });

  // Helper method to create empty response
  static PaginatedResponse<T> empty<T>(int page, int limit) {
    return PaginatedResponse<T>(
      data: <T>[],
      meta: PaginationMeta.empty(page, limit),
    );
  }
}
