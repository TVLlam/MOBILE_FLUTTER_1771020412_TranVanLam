import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

// Notifications State
class NotificationsState {
  final List<NotificationModel> notifications;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final int unreadCount;
  final String? error;

  const NotificationsState({
    this.notifications = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.unreadCount = 0,
    this.error,
  });

  NotificationsState copyWith({
    List<NotificationModel>? notifications,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    int? unreadCount,
    String? error,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationService _notificationService;

  NotificationsNotifier(this._notificationService)
    : super(const NotificationsState());

  Future<void> loadNotifications({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final page = refresh ? 1 : state.currentPage;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final notifications = await _notificationService.getNotifications(
        page: page,
      );

      state = state.copyWith(
        notifications: refresh
            ? notifications
            : [...state.notifications, ...notifications],
        isLoading: false,
        hasMore: notifications.length >= 20,
        currentPage: page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      // TODO: Backend chưa có endpoint /notifications/unread-count
      // final count = await _notificationService.getUnreadCount();
      // state = state.copyWith(unreadCount: count);
      state = state.copyWith(unreadCount: 0);
    } catch (_) {}
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      final notifications = state.notifications.map((n) {
        if (n.id == notificationId) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      state = state.copyWith(
        notifications: notifications,
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      final notifications = state.notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(notifications: notifications, unreadCount: 0);
    } catch (_) {}
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      final wasUnread =
          state.notifications
              .firstWhere((n) => n.id == notificationId)
              .isRead ==
          false;

      state = state.copyWith(
        notifications: state.notifications
            .where((n) => n.id != notificationId)
            .toList(),
        unreadCount: wasUnread && state.unreadCount > 0
            ? state.unreadCount - 1
            : state.unreadCount,
      );
    } catch (_) {}
  }

  void addNotification(NotificationModel notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
      unreadCount: state.unreadCount + 1,
    );
  }

  void reset() {
    state = const NotificationsState();
  }
}

// Notifications Provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
      return NotificationsNotifier(ref.read(notificationServiceProvider));
    });

// Unread Count Provider
final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationsProvider).unreadCount;
});

// News State
class NewsState {
  final List<NewsModel> news;
  final bool isLoading;
  final String? error;

  const NewsState({this.news = const [], this.isLoading = false, this.error});

  NewsState copyWith({List<NewsModel>? news, bool? isLoading, String? error}) {
    return NewsState(
      news: news ?? this.news,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NewsNotifier extends StateNotifier<NewsState> {
  final NotificationService _notificationService;

  NewsNotifier(this._notificationService) : super(const NewsState());

  Future<void> loadNews() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final news = await _notificationService.getNews();
      state = state.copyWith(news: news, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// News Provider
final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier(ref.read(notificationServiceProvider));
});

// Pinned News Provider
final pinnedNewsProvider = Provider<List<NewsModel>>((ref) {
  final news = ref.watch(newsProvider).news;
  final pinnedNews = news.where((n) => n.isPinned).toList();

  // Return demo data if no pinned news
  if (pinnedNews.isEmpty) {
    return [
      NewsModel(
        id: 'demo-1',
        title: '🎉 Khai mạc giải đấu mùa xuân 2026',
        content:
            'CLB Pickleball hân hạnh công bố giải đấu lớn nhất năm sẽ diễn ra vào tháng 3/2026. Đăng ký ngay để không bỏ lỡ!',
        imageUrl: null,
        isPinned: true,
        viewCount: 0,
        createdDate: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NewsModel(
        id: 'demo-2',
        title: '🏆 Chúc mừng các VĐV đạt rank DUPR mới',
        content:
            '10 thành viên vừa đạt mốc rank DUPR mới trong tháng này. Chúc mừng các bạn và tiếp tục cố gắng!',
        imageUrl: null,
        isPinned: true,
        viewCount: 0,
        createdDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NewsModel(
        id: 'demo-3',
        title: '⚡ Khuyến mãi đặt sân cuối tuần',
        content:
            'Giảm 20% cho tất cả các booking vào thứ 7 và chủ nhật. Áp dụng từ ngày 25/1 đến 31/1/2026.',
        imageUrl: null,
        isPinned: true,
        viewCount: 0,
        createdDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  return pinnedNews;
});

// Alias for unread count
final unreadCountProvider = unreadNotificationCountProvider;
