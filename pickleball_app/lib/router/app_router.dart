import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../data/models/booking_model.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/dashboard/screens/main_screen.dart';
import '../features/dashboard/screens/home_screen.dart';
import '../features/booking/screens/booking_screen.dart';
import '../features/booking/screens/create_booking_screen.dart';
import '../features/tournament/screens/tournaments_screen.dart';
import '../features/tournament/screens/tournament_detail_screen.dart';
import '../features/wallet/screens/wallet_screen.dart';
import '../features/wallet/screens/deposit_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/edit_profile_screen.dart';
import '../features/members/screens/members_screen.dart';
import '../features/members/screens/member_detail_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/news/screens/news_detail_screen.dart';

// Router Provider
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoading =
          authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;

      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      // Still loading, stay on splash
      if (isLoading && state.matchedLocation == '/splash') {
        return null;
      }

      // Not logged in, redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Logged in but on auth route, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main Shell
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Booking
          GoRoute(
            path: '/booking',
            name: 'booking',
            builder: (context, state) => const BookingScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'create-booking',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return CreateBookingScreen(
                    selectedDate: extra?['selectedDate'] ?? DateTime.now(),
                    courtId: extra?['courtId'] ?? 1,
                    slots: (extra?['slots'] as List<TimeSlotModel>?) ?? [],
                  );
                },
              ),
            ],
          ),

          // Tournament
          GoRoute(
            path: '/tournaments',
            name: 'tournaments',
            builder: (context, state) => const TournamentsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'tournament-detail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return TournamentDetailScreen(tournamentId: id);
                },
              ),
            ],
          ),

          // Wallet
          GoRoute(
            path: '/wallet',
            name: 'wallet',
            builder: (context, state) => const WalletScreen(),
            routes: [
              GoRoute(
                path: 'deposit',
                name: 'deposit',
                builder: (context, state) => const DepositScreen(),
              ),
            ],
          ),

          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                builder: (context, state) => const EditProfileScreen(),
              ),
            ],
          ),

          // Members
          GoRoute(
            path: '/members',
            name: 'members',
            builder: (context, state) => const MembersScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'member-detail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return MemberDetailScreen(memberId: id);
                },
              ),
            ],
          ),

          // Notifications
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),

          // News Detail
          GoRoute(
            path: '/news-detail',
            name: 'news-detail',
            builder: (context, state) {
              final id = state.extra as int;
              return NewsDetailScreen(newsId: id);
            },
          ),

          // Admin
          GoRoute(
            path: '/admin',
            name: 'admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Không tìm thấy trang: ${state.uri.path}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    ),
  );
});
