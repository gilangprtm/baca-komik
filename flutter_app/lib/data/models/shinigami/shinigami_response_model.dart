/// Base response model for Shinigami API
class ShinigamiResponse<T> {
  final int retcode;
  final String message;
  final ShinigamiMeta meta;
  final T data;

  ShinigamiResponse({
    required this.retcode,
    required this.message,
    required this.meta,
    required this.data,
  });

  factory ShinigamiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return ShinigamiResponse<T>(
      retcode: json['retcode'] ?? 0,
      message: json['message'] ?? '',
      meta: ShinigamiMeta.fromJson(json['meta'] ?? {}),
      data: fromJsonT(json['data']),
    );
  }

  bool get isSuccess => retcode == 0;
}

/// Meta information for Shinigami API responses
class ShinigamiMeta {
  final String requestId;
  final int timestamp;
  final String processTime;
  final int? page;
  final int? pageSize;
  final int? totalPage;
  final int? totalRecord;

  ShinigamiMeta({
    required this.requestId,
    required this.timestamp,
    required this.processTime,
    this.page,
    this.pageSize,
    this.totalPage,
    this.totalRecord,
  });

  factory ShinigamiMeta.fromJson(Map<String, dynamic> json) {
    return ShinigamiMeta(
      requestId: json['request_id'] ?? '',
      timestamp: json['timestamp'] ?? 0,
      processTime: json['process_time'] ?? '0ms',
      page: json['page'],
      pageSize: json['page_size'],
      totalPage: json['total_page'],
      totalRecord: json['total_record'],
    );
  }

  // Helper getters for pagination
  bool get hasPagination => page != null && pageSize != null;
  bool get hasMore => page != null && totalPage != null && page! < totalPage!;
  int get currentPage => page ?? 1;
  int get perPage => pageSize ?? 12;
  int get total => totalRecord ?? 0;
  int get lastPage => totalPage ?? 1;
}

/// Paginated list response for Shinigami API
class ShinigamiListResponse<T> {
  final List<T> data;
  final ShinigamiMeta meta;
  final Map<String, dynamic>? facet;

  ShinigamiListResponse({
    required this.data,
    required this.meta,
    this.facet,
  });

  factory ShinigamiListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return ShinigamiListResponse<T>(
      data: (json['data'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      meta: ShinigamiMeta.fromJson(json['meta'] ?? {}),
      facet: json['facet'] as Map<String, dynamic>?,
    );
  }

  // Helper method to create empty response
  static ShinigamiListResponse<T> empty<T>() {
    return ShinigamiListResponse<T>(
      data: <T>[],
      meta: ShinigamiMeta(
        requestId: '',
        timestamp: 0,
        processTime: '0ms',
        page: 1,
        pageSize: 12,
        totalPage: 0,
        totalRecord: 0,
      ),
    );
  }
}
