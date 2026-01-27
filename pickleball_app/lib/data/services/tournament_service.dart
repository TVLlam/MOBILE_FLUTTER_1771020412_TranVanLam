import '../../core/constants/app_config.dart';
import '../../core/network/dio_client.dart';
import '../../core/network/api_exception.dart';
import '../models/models.dart';

class TournamentService {
  final DioClient _dio = DioClient();

  /// Lấy danh sách giải đấu
  Future<List<TournamentModel>> getTournaments({
    int page = 1,
    int pageSize = 20,
    TournamentStatus? status,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'pageSize': pageSize,
        if (status != null) 'status': _capitalizeFirst(status.name),
      };

      final response = await _dio.get(
        ApiEndpoints.tournaments,
        queryParameters: queryParams,
      );

      // Backend returns array directly, not wrapped in {items: [...]}
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['items'] ?? []);
      print('DEBUG: Tournaments response data type: ${data.runtimeType}');
      print('DEBUG: Tournaments count: ${data.length}');

      final tournaments = <TournamentModel>[];
      for (var i = 0; i < data.length; i++) {
        try {
          final tournament = TournamentModel.fromJson(data[i]);
          tournaments.add(tournament);
          print(
            'DEBUG: Successfully parsed tournament ${i + 1}: ${tournament.name}',
          );
        } catch (e) {
          print('ERROR: Failed to parse tournament ${i + 1}: $e');
          print('ERROR: Tournament data: ${data[i]}');
        }
      }

      return tournaments;
    } catch (e) {
      print('ERROR: getTournaments failed: $e');
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy chi tiết giải đấu
  Future<TournamentModel> getTournamentDetail(int id) async {
    try {
      final response = await _dio.get(ApiEndpoints.tournamentDetail(id));
      return TournamentModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Tham gia giải đấu
  Future<TournamentParticipantModel> joinTournament(
    int tournamentId, {
    String? teamName,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.joinTournament(tournamentId),
        data: {if (teamName != null) 'teamName': teamName},
      );
      return TournamentParticipantModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Alias cho joinTournament - đăng ký giải đấu
  Future<TournamentParticipantModel> registerTournament(
    int tournamentId, {
    String? teamName,
  }) async {
    return joinTournament(tournamentId, teamName: teamName);
  }

  /// Hủy đăng ký giải đấu (hoàn lại 50% phí)
  Future<Map<String, dynamic>> cancelRegistration(int tournamentId) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.tournaments}/$tournamentId/cancel',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy bảng xếp hạng giải đấu
  Future<List<TournamentStanding>> getTournamentStandings(
    int tournamentId,
  ) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.tournamentStandings(tournamentId),
      );
      final List<dynamic> data = response.data;
      return data.map((e) => TournamentStanding.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy bracket giải đấu
  Future<List<BracketMatch>> getTournamentBracket(int tournamentId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.tournamentBracket(tournamentId),
      );
      final List<dynamic> data = response.data;
      return data.map((e) => BracketMatch.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy danh sách trận đấu của giải
  Future<List<MatchModel>> getTournamentMatches(int tournamentId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.tournamentMatches(tournamentId),
      );
      final List<dynamic> data = response.data;
      return data.map((e) => MatchModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Lấy danh sách người tham gia giải đấu
  Future<List<TournamentParticipantModel>> getTournamentParticipants(
    int tournamentId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.tournamentDetail(tournamentId)}/participants',
      );
      final List<dynamic> data = response.data;
      return data.map((e) => TournamentParticipantModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// [Admin] Tạo giải đấu
  Future<TournamentModel> createTournament(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiEndpoints.tournaments, data: data);
      return TournamentModel.fromJson(response.data);
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// [Admin] Tạo lịch thi đấu tự động
  Future<List<MatchModel>> generateSchedule(int tournamentId) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.generateSchedule(tournamentId),
      );
      final List<dynamic> data = response.data;
      return data.map((e) => MatchModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Helper to capitalize first letter
  String _capitalizeFirst(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}
