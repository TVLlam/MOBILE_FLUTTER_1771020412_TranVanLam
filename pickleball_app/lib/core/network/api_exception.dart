class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({required this.message, this.statusCode, this.errors});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';

  factory ApiException.fromDioError(dynamic error) {
    String message = 'Đã xảy ra lỗi không xác định';
    int? statusCode;
    dynamic errors;

    if (error.response != null) {
      statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? data['title'] ?? message;
        errors = data['errors'];
      } else if (data is String) {
        message = data;
      }

      // Specific error messages based on status code
      switch (statusCode) {
        case 400:
          message = message.isNotEmpty ? message : 'Yêu cầu không hợp lệ';
          break;
        case 401:
          message = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại';
          break;
        case 403:
          message = 'Bạn không có quyền thực hiện thao tác này';
          break;
        case 404:
          message = 'Không tìm thấy dữ liệu yêu cầu';
          break;
        case 409:
          message = message.isNotEmpty ? message : 'Dữ liệu đã tồn tại';
          break;
        case 422:
          message = message.isNotEmpty ? message : 'Dữ liệu không hợp lệ';
          break;
        case 500:
          message = 'Lỗi máy chủ. Vui lòng thử lại sau';
          break;
        case 502:
        case 503:
        case 504:
          message = 'Máy chủ đang bảo trì. Vui lòng thử lại sau';
          break;
      }
    } else if (error.type != null) {
      switch (error.type.toString()) {
        case 'DioExceptionType.connectionTimeout':
        case 'DioExceptionType.sendTimeout':
        case 'DioExceptionType.receiveTimeout':
          message = 'Kết nối quá chậm. Vui lòng kiểm tra mạng';
          break;
        case 'DioExceptionType.connectionError':
          message = 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra mạng';
          break;
        case 'DioExceptionType.cancel':
          message = 'Yêu cầu đã bị hủy';
          break;
        default:
          message = 'Đã xảy ra lỗi kết nối';
      }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }
}

class ValidationException implements Exception {
  final Map<String, List<String>> errors;

  ValidationException(this.errors);

  @override
  String toString() {
    final messages = errors.values.expand((e) => e).toList();
    return messages.join('\n');
  }

  String? getFirstError(String field) {
    return errors[field]?.firstOrNull;
  }
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = 'Không có kết nối mạng']);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException([this.message = 'Phiên đăng nhập đã hết hạn']);

  @override
  String toString() => message;
}

class NotFoundException implements Exception {
  final String message;

  NotFoundException([this.message = 'Không tìm thấy dữ liệu']);

  @override
  String toString() => message;
}

class InsufficientBalanceException implements Exception {
  final String message;
  final double required;
  final double available;

  InsufficientBalanceException({
    this.message = 'Số dư ví không đủ',
    required this.required,
    required this.available,
  });

  @override
  String toString() => '$message (Cần: $required, Hiện có: $available)';
}

class BookingConflictException implements Exception {
  final String message;

  BookingConflictException([this.message = 'Khung giờ đã được đặt']);

  @override
  String toString() => message;
}
