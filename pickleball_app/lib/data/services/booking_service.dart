import '../../core/constants/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/models.dart';

class BookingService {
  final DioClient _dio = DioClient();

  /// Lấy danh sách sân
  Future<List<CourtModel>> getCourts() async {
    try {
      final response = await _dio.get(ApiEndpoints.courts);
      final List<dynamic> data = response.data;
      return data.map((e) => CourtModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy lịch đặt sân theo khoảng thời gian
  Future<List<BookingCalendarItem>> getCalendar(
    DateTime from,
    DateTime to,
  ) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.bookingCalendar,
        queryParameters: {
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
        },
      );
      final List<dynamic> data = response.data;
      return data.map((e) => BookingCalendarItem.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Đặt sân đơn lẻ
  Future<BookingModel> createBooking(CreateBookingRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.bookings,
        data: request.toJson(),
      );
      return BookingModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Đặt sân định kỳ (VIP)
  Future<List<BookingModel>> createRecurringBooking(
    CreateRecurringBookingRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.recurringBooking,
        data: request.toJson(),
      );
      final List<dynamic> data = response.data;
      return data.map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Hủy đặt sân
  Future<void> cancelBooking(int bookingId) async {
    try {
      await _dio.post(ApiEndpoints.cancelBooking(bookingId));
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy danh sách đặt sân của tôi
  Future<List<BookingModel>> getMyBookings({
    int page = 1,
    int pageSize = 20,
    BookingStatus? status,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'pageSize': pageSize,
        if (status != null) 'status': status.index,
      };

      final response = await _dio.get(
        ApiEndpoints.myBookings,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['items'] ?? []);
      return data.map((e) => BookingModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy chi tiết booking
  Future<BookingModel> getBookingDetail(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.bookings}/$id');
      return BookingModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy các slot trống trong ngày cho một sân
  Future<List<TimeSlot>> getAvailableSlots(int courtId, DateTime date) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.courts}/$courtId/slots',
        queryParameters: {'date': date.toIso8601String().split('T')[0]},
      );
      final List<dynamic> data = response.data;
      return data.map((e) => TimeSlot.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
