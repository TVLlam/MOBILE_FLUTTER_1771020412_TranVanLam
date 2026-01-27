class ApiConfig {
  // API Base URL - Port from API server (check console output)
  static const String baseUrl =
      'http://localhost:5159'; // Updated to match running API server

  // API Endpoints
  static const String authEndpoint = '/api/auth';
  static const String courtsEndpoint = '/api/courts';
  static const String bookingsEndpoint = '/api/bookings';
  static const String walletEndpoint = '/api/wallet';
  static const String tournamentsEndpoint = '/api/tournaments';

  // Full URLs
  static String get registerUrl => '$baseUrl$authEndpoint/register';
  static String get loginUrl => '$baseUrl$authEndpoint/login';

  static String get courtsUrl => '$baseUrl$courtsEndpoint';
  static String courtUrl(int id) => '$baseUrl$courtsEndpoint/$id';

  static String get bookingsUrl => '$baseUrl$bookingsEndpoint';
  static String bookingUrl(int id) => '$baseUrl$bookingsEndpoint/$id';
  static String bookingStatusUrl(int id) =>
      '$baseUrl$bookingsEndpoint/$id/status';

  static String get walletBalanceUrl => '$baseUrl$walletEndpoint/balance';
  static String get walletTransactionsUrl =>
      '$baseUrl$walletEndpoint/transactions';
  static String get walletDepositUrl => '$baseUrl$walletEndpoint/deposit';
  static String get walletWithdrawUrl => '$baseUrl$walletEndpoint/withdraw';

  static String get tournamentsUrl => '$baseUrl$tournamentsEndpoint';
  static String tournamentUrl(int id) => '$baseUrl$tournamentsEndpoint/$id';

  // Headers
  static Map<String, String> headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
