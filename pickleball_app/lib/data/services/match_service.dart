import '../../core/constants/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/models.dart';

class MatchService {
  final DioClient _dio = DioClient();

  /// Lấy danh sách trận đấu
  Future<List<MatchModel>> getMatches({
    int page = 1,
    int pageSize = 20,
    MatchStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'pageSize': pageSize,
        if (status != null) 'status': status.index,
        if (fromDate != null) 'fromDate': fromDate.toIso8601String(),
        if (toDate != null) 'toDate': toDate.toIso8601String(),
      };

      final response = await _dio.get(
        ApiEndpoints.matches,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['items'] ?? []);
      return data.map((e) => MatchModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy trận đấu sắp tới
  Future<List<MatchModel>> getUpcomingMatches({int limit = 10}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.upcomingMatches,
        queryParameters: {'limit': limit},
      );
      final List<dynamic> data = response.data;
      return data.map((e) => MatchModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy chi tiết trận đấu
  Future<MatchModel> getMatchDetail(int id) async {
    try {
      final response = await _dio.get('${ApiEndpoints.matches}/$id');
      return MatchModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// [Referee/Admin] Cập nhật kết quả trận đấu
  Future<MatchModel> updateMatchResult(
    int matchId,
    UpdateMatchResultRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.matchResult(matchId),
        data: request.toJson(),
      );
      return MatchModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
