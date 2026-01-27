import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/models.dart';

class AuthService {
  final DioClient _dio = DioClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Đăng nhập
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Lưu token
      await _storage.write(
        key: StorageKeys.accessToken,
        value: loginResponse.accessToken,
      );
      await _storage.write(
        key: StorageKeys.userId,
        value: loginResponse.user.id,
      );
      if (loginResponse.refreshToken != null) {
        await _storage.write(
          key: StorageKeys.refreshToken,
          value: loginResponse.refreshToken,
        );
      }

      return loginResponse;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Đăng ký
  Future<LoginResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      // Lưu token
      await _storage.write(
        key: StorageKeys.accessToken,
        value: loginResponse.accessToken,
      );
      await _storage.write(
        key: StorageKeys.userId,
        value: loginResponse.user.id,
      );
      if (loginResponse.refreshToken != null) {
        await _storage.write(
          key: StorageKeys.refreshToken,
          value: loginResponse.refreshToken,
        );
      }

      return loginResponse;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy thông tin user hiện tại
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Cập nhật profile
  Future<UserModel> updateProfile(UpdateProfileRequest request) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.updateProfile,
        data: request.toJson(),
      );
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore errors on logout
    } finally {
      await _storage.deleteAll();
    }
  }

  /// Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: StorageKeys.accessToken);
    return token != null;
  }

  /// Lấy token
  Future<String?> getToken() async {
    return await _storage.read(key: StorageKeys.accessToken);
  }

  /// Đổi mật khẩu
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _dio.post(
        ApiEndpoints.changePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
