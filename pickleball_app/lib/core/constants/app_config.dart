import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Cấu hình ứng dụng
class AppConfig {
  // API Base URL - Auto-detect platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5159/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5159/api';
    } else {
      return 'http://localhost:5159/api';
    }
  }

  // SignalR Hub URL - Auto-detect platform
  static String get signalRUrl {
    if (kIsWeb) {
      return 'http://localhost:5159/pcmhub';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5159/pcmhub';
    } else {
      return 'http://localhost:5159/pcmhub';
    }
  }

  // App Info
  static const String appName = 'Vợt Thủ Phố Núi';
  static const String appVersion = '1.0.0';

  // Booking Config
  static const int bookingHoldMinutes = 5;
  static const int minBookingHours = 1;
  static const int maxBookingHours = 4;

  // Time Slots
  static const int startHour = 6; // 6:00 AM
  static const int endHour = 22; // 10:00 PM

  // Pagination
  static const int defaultPageSize = 20;

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 30);

  // Token Refresh
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
}

/// Storage Keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String theme = 'app_theme';
  static const String language = 'app_language';
  static const String biometricEnabled = 'biometric_enabled';
}

/// API Endpoints
class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/profile';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/change-password';

  // Members
  static const String members = '/members';
  static String memberProfile(int id) => '/members/$id/profile';

  // Wallet
  static const String walletDeposit = '/wallet/deposit';
  static const String walletTransactions = '/wallet/transactions';
  static const String walletSummary = '/wallet/summary';
  static String approveDeposit(int id) => '/admin/wallet/approve/$id';
  static const String pendingDeposits = '/admin/wallet/pending';

  // Courts
  static const String courts = '/courts';

  // Bookings
  static const String bookings = '/bookings';
  static const String bookingCalendar = '/bookings/calendar';
  static const String recurringBooking = '/bookings/recurring';
  static String cancelBooking(int id) => '/bookings/cancel/$id';
  static const String myBookings =
      '/bookings'; // Backend returns current user's bookings

  // Tournaments
  static const String tournaments = '/tournaments';
  static String tournamentDetail(int id) => '/tournaments/$id';
  static String joinTournament(int id) => '/tournaments/$id/join';
  static String generateSchedule(int id) =>
      '/tournaments/$id/generate-schedule';
  static String tournamentStandings(int id) => '/tournaments/$id/standings';
  static String tournamentBracket(int id) => '/tournaments/$id/bracket';
  static String tournamentMatches(int id) => '/tournaments/$id/matches';

  // Matches
  static const String matches = '/matches';
  static String matchResult(int id) => '/matches/$id/result';
  static const String upcomingMatches = '/matches/upcoming';

  // Notifications
  static const String notifications = '/notifications';
  static String markAsRead(dynamic id) => '/notifications/$id/read';
  static const String markAllAsRead = '/notifications/read-all';
  static const String unreadCount = '/notifications/unread-count';

  // News
  static const String news = '/news';

  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStats = '/admin/stats';
}
