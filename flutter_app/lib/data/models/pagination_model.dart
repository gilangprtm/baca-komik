class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;

  PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasMore,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      hasMore: json['has_more'] ?? false,
    );
  }

  // For empty results
  factory PaginationMeta.empty(int page, int limit) {
    return PaginationMeta(
      page: page,
      limit: limit,
      total: 0,
      totalPages: 0,
      hasMore: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'total_pages': totalPages,
      'has_more': hasMore,
    };
  }

  // Getter untuk backward compatibility
  int get currentPage => page;
  int get lastPage => totalPages;
  int get perPage => limit;
}
