class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value)? toJsonT) => {
    'success': success,
    'message': message,
    'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
    'errors': errors,
  };
}

class PaginatedResponse<T> {
  final List<T> items;
  final int totalCount;
  final int pageIndex;
  final int pageSize;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;

  const PaginatedResponse({
    required this.items,
    required this.totalCount,
    required this.pageIndex,
    required this.pageSize,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount:
          json['totalCount'] as int? ?? json['total_count'] as int? ?? 0,
      pageIndex: json['pageIndex'] as int? ?? json['page_index'] as int? ?? 0,
      pageSize: json['pageSize'] as int? ?? json['page_size'] as int? ?? 10,
      totalPages:
          json['totalPages'] as int? ?? json['total_pages'] as int? ?? 0,
      hasPreviousPage:
          json['hasPreviousPage'] as bool? ??
          json['has_previous_page'] as bool? ??
          false,
      hasNextPage:
          json['hasNextPage'] as bool? ??
          json['has_next_page'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) => {
    'items': items.map((e) => toJsonT(e)).toList(),
    'totalCount': totalCount,
    'pageIndex': pageIndex,
    'pageSize': pageSize,
    'totalPages': totalPages,
    'hasPreviousPage': hasPreviousPage,
    'hasNextPage': hasNextPage,
  };
}
