import '../../core/constants/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/models.dart';

class NotificationService {
  final DioClient _dio = DioClient();

  /// Lấy danh sách thông báo
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? isRead,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'pageSize': pageSize,
        if (isRead != null) 'isRead': isRead,
      };

      final response = await _dio.get(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['items'] ?? []);
      return data.map((e) => NotificationModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy số lượng thông báo chưa đọc
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get(ApiEndpoints.unreadCount);
      return response.data['count'] ?? 0;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Đánh dấu đã đọc
  Future<void> markAsRead(dynamic notificationId) async {
    try {
      await _dio.put(ApiEndpoints.markAsRead(notificationId));
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Đánh dấu tất cả đã đọc
  Future<void> markAllAsRead() async {
    try {
      await _dio.put(ApiEndpoints.markAllAsRead);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Xóa thông báo
  Future<void> deleteNotification(dynamic notificationId) async {
    try {
      await _dio.delete('${ApiEndpoints.notifications}/$notificationId');
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy tin tức
  Future<List<NewsModel>> getNews({int page = 1, int pageSize = 20}) async {
    try {
      final queryParams = {'page': page, 'pageSize': pageSize};

      final response = await _dio.get(
        ApiEndpoints.news,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['items'] ?? []);
      return data.map((e) => NewsModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy tin tức ghim
  Future<List<NewsModel>> getPinnedNews() async {
    try {
      final response = await _dio.get(
        ApiEndpoints.news,
        queryParameters: {'isPinned': true},
      );
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['items'] ?? []);
      return data.map((e) => NewsModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy chi tiết tin tức
  Future<NewsModel> getNewsDetail(dynamic id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.news}/$id');
      return NewsModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
