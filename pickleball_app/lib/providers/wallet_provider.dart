import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

// Wallet Service Provider
final walletServiceProvider = Provider<WalletService>((ref) => WalletService());

// Wallet Transactions State
class WalletTransactionsState {
  final List<WalletTransactionModel> transactions;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const WalletTransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  WalletTransactionsState copyWith({
    List<WalletTransactionModel>? transactions,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return WalletTransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

class WalletTransactionsNotifier
    extends StateNotifier<WalletTransactionsState> {
  final WalletService _walletService;

  WalletTransactionsNotifier(this._walletService)
    : super(const WalletTransactionsState());

  Future<void> loadTransactions({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final page = refresh ? 1 : state.currentPage;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final transactions = await _walletService.getTransactions(page: page);

      state = state.copyWith(
        transactions: refresh
            ? transactions
            : [...state.transactions, ...transactions],
        isLoading: false,
        hasMore: transactions.length >= 20,
        currentPage: page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> requestDeposit(double amount, String? proofImageBase64) async {
    try {
      await _walletService.requestDeposit(
        DepositRequest(amount: amount, proofImageBase64: proofImageBase64),
      );
      await loadTransactions(refresh: true);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void reset() {
    state = const WalletTransactionsState();
  }
}

// Wallet Transactions Provider
final walletTransactionsProvider =
    StateNotifierProvider<WalletTransactionsNotifier, WalletTransactionsState>((
      ref,
    ) {
      return WalletTransactionsNotifier(ref.read(walletServiceProvider));
    });

// Wallet Summary Provider
final walletSummaryProvider = FutureProvider<WalletSummary>((ref) async {
  final walletService = ref.read(walletServiceProvider);
  return walletService.getWalletSummary();
});

// Pending Deposits Provider (Admin)
final pendingDepositsProvider = FutureProvider<List<WalletTransactionModel>>((
  ref,
) async {
  final walletService = ref.read(walletServiceProvider);
  return walletService.getPendingDeposits();
});
