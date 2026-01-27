import '../../core/constants/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/models.dart';

class MemberService {
  final DioClient _dio = DioClient();

  /// Lấy danh sách thành viên
  Future<List<MemberModel>> getMembers({
    int page = 1,
    int pageSize = 20,
    String? search,
    MemberTier? tier,
    bool? isActive,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'pageSize': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (tier != null) 'tier': tier.index,
        if (isActive != null) 'isActive': isActive,
      };

      final response = await _dio.get(
        ApiEndpoints.members,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['items'] ?? []);
      return data.map((e) => MemberModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy thông tin profile thành viên
  Future<MemberModel> getMemberProfile(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.memberProfile(id));
      return MemberModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Cập nhật thông tin thành viên
  Future<MemberModel> updateMember(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '${ApiEndpoints.members}/$id',
        data: data,
      );
      return MemberModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Cập nhật avatar
  Future<String> updateAvatar(int memberId, String imagePath) async {
    try {
      final response = await _dio.uploadFile(
        '${ApiEndpoints.members}/$memberId/avatar',
        imagePath,
        'avatar.jpg',
      );
      return response.data['avatarUrl'];
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy lịch sử rank của thành viên
  Future<List<Map<String, dynamic>>> getRankHistory(int memberId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.members}/$memberId/rank-history',
      );
      return List<Map<String, dynamic>>.from(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy lịch sử trận đấu của thành viên
  Future<List<MatchModel>> getMemberMatches(int memberId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.members}/$memberId/matches',
      );
      final List<dynamic> data = response.data;
      return data.map((e) => MatchModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
