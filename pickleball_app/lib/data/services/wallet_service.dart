import '../../core/constants/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/models.dart';

class WalletService {
  final DioClient _dio = DioClient();

  /// Lấy danh sách giao dịch
  Future<List<WalletTransactionModel>> getTransactions({
    int page = 1,
    int pageSize = 20,
    TransactionType? type,
    TransactionStatus? status,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'pageSize': pageSize,
        if (type != null) 'type': type.index,
        if (status != null) 'status': status.index,
      };

      final response = await _dio.get(
        ApiEndpoints.walletTransactions,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['items'] ?? []);
      return data.map((e) => WalletTransactionModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy thông tin tổng quan ví
  Future<WalletSummary> getWalletSummary() async {
    try {
      final response = await _dio.get(ApiEndpoints.walletSummary);
      return WalletSummary.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Gửi yêu cầu nạp tiền
  Future<WalletTransactionModel> requestDeposit(DepositRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.walletDeposit,
        data: request.toJson(),
      );
      return WalletTransactionModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// [Admin] Duyệt nạp tiền
  Future<WalletTransactionModel> approveDeposit(
    int transactionId,
    bool approved, {
    String? note,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.approveDeposit(transactionId),
        data: {'approved': approved, 'note': note},
      );
      return WalletTransactionModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// [Admin] Lấy danh sách yêu cầu nạp tiền đang chờ duyệt
  Future<List<WalletTransactionModel>> getPendingDeposits() async {
    try {
      final response = await _dio.get(ApiEndpoints.pendingDeposits);
      final List<dynamic> data = response.data;
      return data.map((e) => WalletTransactionModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
