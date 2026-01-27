import 'dart:async';
import 'package:logger/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_config.dart';

typedef NotificationCallback = void Function(Map<String, dynamic> data);
typedef CalendarUpdateCallback = void Function(Map<String, dynamic> data);
typedef MatchScoreCallback = void Function(Map<String, dynamic> data);

/// SignalR Service for real-time communication
/// This is a simplified implementation that can be extended with actual SignalR
/// when the signalr_netcore package is properly configured
class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  final Logger _logger = Logger();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  // Callbacks
  final List<NotificationCallback> _notificationCallbacks = [];
  final List<CalendarUpdateCallback> _calendarUpdateCallbacks = [];
  final List<MatchScoreCallback> _matchScoreCallbacks = [];

  // Stream controllers for real-time updates
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _calendarController =
      StreamController<Map<String, dynamic>>.broadcast();
  final StreamController<Map<String, dynamic>> _matchScoreController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;
  Stream<Map<String, dynamic>> get calendarStream => _calendarController.stream;
  Stream<Map<String, dynamic>> get matchScoreStream =>
      _matchScoreController.stream;

  /// Kết nối SignalR Hub
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final token = await _storage.read(key: StorageKeys.accessToken);
      if (token == null) {
        _logger.w('No token found, cannot connect to SignalR');
        return;
      }

      // TODO: Implement actual SignalR connection when package is available
      // For now, we'll simulate a connected state
      _isConnected = true;
      _logger.i('SignalR Service initialized (mock mode)');
    } catch (e) {
      _logger.e('SignalR Connection Error', error: e);
      _isConnected = false;
    }
  }

  /// Ngắt kết nối
  Future<void> disconnect() async {
    _isConnected = false;
    _logger.i('SignalR Disconnected');
  }

  /// Đăng ký callback nhận thông báo
  void onNotification(NotificationCallback callback) {
    _notificationCallbacks.add(callback);
  }

  /// Hủy đăng ký callback thông báo
  void offNotification(NotificationCallback callback) {
    _notificationCallbacks.remove(callback);
  }

  /// Đăng ký callback cập nhật lịch
  void onCalendarUpdate(CalendarUpdateCallback callback) {
    _calendarUpdateCallbacks.add(callback);
  }

  /// Hủy đăng ký callback lịch
  void offCalendarUpdate(CalendarUpdateCallback callback) {
    _calendarUpdateCallbacks.remove(callback);
  }

  /// Đăng ký callback cập nhật tỉ số
  void onMatchScoreUpdate(MatchScoreCallback callback) {
    _matchScoreCallbacks.add(callback);
  }

  /// Hủy đăng ký callback tỉ số
  void offMatchScoreUpdate(MatchScoreCallback callback) {
    _matchScoreCallbacks.remove(callback);
  }

  /// Simulate receiving a notification (for testing)
  void simulateNotification(Map<String, dynamic> data) {
    _notificationController.add(data);
    for (var callback in _notificationCallbacks) {
      callback(data);
    }
  }

  /// Simulate calendar update (for testing)
  void simulateCalendarUpdate(Map<String, dynamic> data) {
    _calendarController.add(data);
    for (var callback in _calendarUpdateCallbacks) {
      callback(data);
    }
  }

  /// Simulate match score update (for testing)
  void simulateMatchScoreUpdate(Map<String, dynamic> data) {
    _matchScoreController.add(data);
    for (var callback in _matchScoreCallbacks) {
      callback(data);
    }
  }

  /// Join a group (for tournaments, matches)
  Future<void> joinGroup(String groupName) async {
    _logger.d('Joined group: $groupName');
  }

  /// Leave a group
  Future<void> leaveGroup(String groupName) async {
    _logger.d('Left group: $groupName');
  }

  /// Dispose resources
  void dispose() {
    _notificationController.close();
    _calendarController.close();
    _matchScoreController.close();
    _notificationCallbacks.clear();
    _calendarUpdateCallbacks.clear();
    _matchScoreCallbacks.clear();
  }
}
