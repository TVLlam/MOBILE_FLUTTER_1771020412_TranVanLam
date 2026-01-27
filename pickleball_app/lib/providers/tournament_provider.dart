import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

// Tournament Service Provider
final tournamentServiceProvider = Provider<TournamentService>(
  (ref) => TournamentService(),
);

// Match Service Provider
final matchServiceProvider = Provider<MatchService>((ref) => MatchService());

// =============================================================================
// TOURNAMENTS STATE & NOTIFIER
// =============================================================================

class TournamentsState {
  final List<TournamentModel> tournaments;
  final TournamentModel? selectedTournament;
  final List<StandingModel> standings;
  final List<MatchModel> matches;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final TournamentStatus? filterStatus;

  const TournamentsState({
    this.tournaments = const [],
    this.selectedTournament,
    this.standings = const [],
    this.matches = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
    this.filterStatus,
  });

  TournamentsState copyWith({
    List<TournamentModel>? tournaments,
    TournamentModel? selectedTournament,
    List<StandingModel>? standings,
    List<MatchModel>? matches,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
    TournamentStatus? filterStatus,
  }) {
    return TournamentsState(
      tournaments: tournaments ?? this.tournaments,
      selectedTournament: selectedTournament ?? this.selectedTournament,
      standings: standings ?? this.standings,
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

class TournamentsNotifier extends StateNotifier<TournamentsState> {
  final TournamentService _tournamentService;

  TournamentsNotifier(this._tournamentService)
    : super(const TournamentsState());

  Future<void> loadTournaments({
    bool refresh = false,
    bool force = false,
  }) async {
    print('DEBUG: loadTournaments called with refresh=$refresh, force=$force');
    print(
      'DEBUG: Current state - isLoading: ${state.isLoading}, tournaments count: ${state.tournaments.length}',
    );

    if (!force && state.isLoading) {
      print('DEBUG: Already loading, returning early');
      return;
    }
    if (!force && !refresh && !state.hasMore) {
      print('DEBUG: No more data, returning early');
      return;
    }

    final page = refresh ? 1 : state.currentPage;
    print('DEBUG: Setting isLoading=true, page=$page');
    state = state.copyWith(isLoading: true, error: null);

    try {
      print('DEBUG: Calling getTournaments API...');
      final tournaments = await _tournamentService.getTournaments(
        page: page,
        status: state.filterStatus,
      );

      print('DEBUG: Received ${tournaments.length} tournaments from API');
      state = state.copyWith(
        tournaments: refresh
            ? tournaments
            : [...state.tournaments, ...tournaments],
        isLoading: false,
        hasMore: tournaments.length >= 20,
        currentPage: page + 1,
      );
      print('DEBUG: State updated successfully');
    } catch (e) {
      print('ERROR: loadTournaments exception: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadTournamentDetail(int tournamentId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tournament = await _tournamentService.getTournamentDetail(
        tournamentId,
      );
      state = state.copyWith(selectedTournament: tournament, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadStandings(int tournamentId) async {
    try {
      final standings = await _tournamentService.getTournamentStandings(
        tournamentId,
      );
      state = state.copyWith(standings: standings);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadMatches(int tournamentId) async {
    try {
      final matches = await _tournamentService.getTournamentMatches(
        tournamentId,
      );
      state = state.copyWith(matches: matches);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> registerTournament(int tournamentId) async {
    try {
      await _tournamentService.registerTournament(tournamentId);

      // Update selectedTournament to reflect registration status
      if (state.selectedTournament?.id == tournamentId.toString()) {
        // Create a copy of the tournament model with isRegistered = true
        final updatedTournament = TournamentModel(
          id: state.selectedTournament!.id,
          name: state.selectedTournament!.name,
          description: state.selectedTournament!.description,
          startDate: state.selectedTournament!.startDate,
          endDate: state.selectedTournament!.endDate,
          registrationDeadline: state.selectedTournament!.registrationDeadline,
          format: state.selectedTournament!.format,
          status: state.selectedTournament!.status,
          entryFee: state.selectedTournament!.entryFee,
          prizePool: state.selectedTournament!.prizePool,
          maxParticipants: state.selectedTournament!.maxParticipants,
          currentParticipants:
              state.selectedTournament!.currentParticipants + 1,
          location: state.selectedTournament!.location,
          imageUrl: state.selectedTournament!.imageUrl,
          rules: state.selectedTournament!.rules,
          prizes: state.selectedTournament!.prizes,
          createdAt: state.selectedTournament!.createdAt,
          isRegistered: true,
        );
        // Create completely new state to ensure Riverpod detects change
        state = TournamentsState(
          tournaments: state.tournaments,
          selectedTournament: updatedTournament,
          standings: state.standings,
          matches: state.matches,
          isLoading: false,
          hasMore: state.hasMore,
          currentPage: state.currentPage,
          error: null,
          filterStatus: state.filterStatus,
        );
      }

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<Map<String, dynamic>?> cancelRegistration(int tournamentId) async {
    try {
      final result = await _tournamentService.cancelRegistration(tournamentId);

      // Update selectedTournament to reflect cancellation
      if (state.selectedTournament?.id == tournamentId.toString()) {
        final updatedTournament = TournamentModel(
          id: state.selectedTournament!.id,
          name: state.selectedTournament!.name,
          description: state.selectedTournament!.description,
          startDate: state.selectedTournament!.startDate,
          endDate: state.selectedTournament!.endDate,
          registrationDeadline: state.selectedTournament!.registrationDeadline,
          format: state.selectedTournament!.format,
          status: state.selectedTournament!.status,
          entryFee: state.selectedTournament!.entryFee,
          prizePool: state.selectedTournament!.prizePool,
          maxParticipants: state.selectedTournament!.maxParticipants,
          currentParticipants:
              state.selectedTournament!.currentParticipants - 1,
          location: state.selectedTournament!.location,
          imageUrl: state.selectedTournament!.imageUrl,
          rules: state.selectedTournament!.rules,
          prizes: state.selectedTournament!.prizes,
          createdAt: state.selectedTournament!.createdAt,
          isRegistered: false,
        );
        // Create completely new state to ensure Riverpod detects change
        state = TournamentsState(
          tournaments: state.tournaments,
          selectedTournament: updatedTournament,
          standings: state.standings,
          matches: state.matches,
          isLoading: false,
          hasMore: state.hasMore,
          currentPage: state.currentPage,
          error: null,
          filterStatus: state.filterStatus,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  void setFilter(TournamentStatus? status) {
    state = state.copyWith(filterStatus: status);
    loadTournaments(refresh: true);
  }

  void reset() {
    state = const TournamentsState();
  }
}

// Alias for backward compatibility
typedef TournamentState = TournamentsState;

// =============================================================================
// PROVIDERS
// =============================================================================

// Tournaments Provider
final tournamentsProvider =
    StateNotifierProvider<TournamentsNotifier, TournamentsState>((ref) {
      return TournamentsNotifier(ref.read(tournamentServiceProvider));
    });

// Tournament Detail Provider
final tournamentDetailProvider = FutureProvider.family<TournamentModel, int>((
  ref,
  id,
) async {
  final tournamentService = ref.read(tournamentServiceProvider);
  return tournamentService.getTournamentDetail(id);
});

// Tournament Standings Provider
final tournamentStandingsProvider =
    FutureProvider.family<List<StandingModel>, int>((ref, tournamentId) async {
      final tournamentService = ref.read(tournamentServiceProvider);
      return tournamentService.getTournamentStandings(tournamentId);
    });

// Tournament Bracket Provider
final tournamentBracketProvider =
    FutureProvider.family<List<BracketMatch>, int>((ref, tournamentId) async {
      final tournamentService = ref.read(tournamentServiceProvider);
      return tournamentService.getTournamentBracket(tournamentId);
    });

// Tournament Matches Provider
final tournamentMatchesProvider = FutureProvider.family<List<MatchModel>, int>((
  ref,
  tournamentId,
) async {
  final tournamentService = ref.read(tournamentServiceProvider);
  return tournamentService.getTournamentMatches(tournamentId);
});

// Tournament Participants Provider
final tournamentParticipantsProvider =
    FutureProvider.family<List<TournamentParticipantModel>, int>((
      ref,
      tournamentId,
    ) async {
      final tournamentService = ref.read(tournamentServiceProvider);
      return tournamentService.getTournamentParticipants(tournamentId);
    });

// Upcoming Matches Provider
final upcomingMatchesProvider = FutureProvider<List<MatchModel>>((ref) async {
  final matchService = ref.read(matchServiceProvider);
  try {
    return await matchService.getUpcomingMatches();
  } catch (e) {
    // Return demo data if API fails
    return [
      MatchModel(
        id: '1',
        tournamentId: '1',
        tournamentName: 'Giải đấu mùa xuân 2026',
        team1Name: 'Team Alpha',
        team2Name: 'Team Beta',
        scheduledTime: DateTime.now().add(const Duration(days: 2)),
        courtId: '1',
        courtName: 'Sân 1',
        round: 1,
        status: MatchStatus.scheduled,
        player1Score: null,
        player2Score: null,
      ),
      MatchModel(
        id: '2',
        tournamentId: '1',
        tournamentName: 'Giải đấu mùa xuân 2026',
        team1Name: 'Team Gamma',
        team2Name: 'Team Delta',
        scheduledTime: DateTime.now().add(const Duration(days: 5)),
        courtId: '2',
        courtName: 'Sân 2',
        round: 2,
        status: MatchStatus.scheduled,
        player1Score: null,
        player2Score: null,
      ),
      MatchModel(
        id: '3',
        tournamentId: '2',
        tournamentName: 'Giải nội bộ tháng 1',
        team1Name: 'Team Epsilon',
        team2Name: 'Team Zeta',
        scheduledTime: DateTime.now().add(const Duration(days: 7)),
        courtId: '3',
        courtName: 'Sân 3',
        round: 3,
        status: MatchStatus.scheduled,
        player1Score: null,
        player2Score: null,
      ),
    ];
  }
});

// Match Detail Provider
final matchDetailProvider = FutureProvider.family<MatchModel, int>((
  ref,
  id,
) async {
  final matchService = ref.read(matchServiceProvider);
  return matchService.getMatchDetail(id);
});
