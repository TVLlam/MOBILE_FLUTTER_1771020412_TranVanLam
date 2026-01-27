import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth State
enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final SignalRService _signalRService;

  AuthNotifier(this._authService, this._signalRService)
    : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        state = state.copyWith(status: AuthStatus.authenticated, user: user);
        // Connect SignalR
        await _signalRService.connect();
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final loginResponse = await _authService.login(email, password);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: loginResponse.user,
      );
      // Connect SignalR
      await _signalRService.connect();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register(RegisterRequest request) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final loginResponse = await _authService.register(request);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: loginResponse.user,
      );
      // Connect SignalR
      await _signalRService.connect();
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    await _signalRService.disconnect();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> refreshUser() async {
    try {
      final user = await _authService.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<bool> updateProfile(UpdateProfileRequest request) async {
    try {
      final user = await _authService.updateProfile(request);
      state = state.copyWith(user: user);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void updateWalletBalance(double newBalance) {
    if (state.user?.member != null) {
      state = state.copyWith(
        user: state.user!.copyWith(
          member: state.user!.member!.copyWith(walletBalance: newBalance),
        ),
      );
    }
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider), SignalRService());
});

// Current User Provider
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

// Is Logged In Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).status == AuthStatus.authenticated;
});

// Is Admin Provider
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role?.toLowerCase() == 'admin';
});

// Is VIP Provider
final isVIPProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  final tier = user?.member?.tier;
  return tier == MemberTier.gold ||
      tier == MemberTier.platinum ||
      tier == MemberTier.diamond;
});

// Wallet Balance Provider
final walletBalanceProvider = Provider<double>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.member?.walletBalance ?? 0;
});
