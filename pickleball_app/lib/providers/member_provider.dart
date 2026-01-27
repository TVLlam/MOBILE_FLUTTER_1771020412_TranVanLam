import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/models.dart';
import '../data/services/services.dart';

// Member Service Provider
final memberServiceProvider = Provider<MemberService>((ref) => MemberService());

// Members List State
class MembersState {
  final List<MemberModel> members;
  final MemberModel? selectedMember;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;
  final MemberTier? filterTier;
  final String? error;

  const MembersState({
    this.members = const [],
    this.selectedMember,
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.searchQuery,
    this.filterTier,
    this.error,
  });

  MembersState copyWith({
    List<MemberModel>? members,
    MemberModel? selectedMember,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
    MemberTier? filterTier,
    String? error,
    bool clearSelectedMember = false,
  }) {
    return MembersState(
      members: members ?? this.members,
      selectedMember: clearSelectedMember
          ? null
          : (selectedMember ?? this.selectedMember),
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      filterTier: filterTier ?? this.filterTier,
      error: error,
    );
  }
}

class MembersNotifier extends StateNotifier<MembersState> {
  final MemberService _memberService;

  MembersNotifier(this._memberService) : super(const MembersState());

  Future<void> loadMembers({bool refresh = false}) async {
    if (state.isLoading) return;
    if (!refresh && !state.hasMore) return;

    final page = refresh ? 1 : state.currentPage;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final members = await _memberService.getMembers(
        page: page,
        search: state.searchQuery,
        tier: state.filterTier,
      );

      state = state.copyWith(
        members: refresh ? members : [...state.members, ...members],
        isLoading: false,
        hasMore: members.length >= 20,
        currentPage: page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
    loadMembers(refresh: true);
  }

  void setFilterTier(MemberTier? tier) {
    state = state.copyWith(filterTier: tier);
    loadMembers(refresh: true);
  }

  Future<void> loadMemberDetail(int memberId) async {
    try {
      final member = await _memberService.getMemberProfile(memberId);
      state = state.copyWith(selectedMember: member, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearSelectedMember() {
    state = state.copyWith(clearSelectedMember: true);
  }

  void reset() {
    state = const MembersState();
  }
}

// Members Provider
final membersProvider = StateNotifierProvider<MembersNotifier, MembersState>((
  ref,
) {
  return MembersNotifier(ref.read(memberServiceProvider));
});

// Member Profile Provider
final memberProfileProvider = FutureProvider.family<MemberModel, int>((
  ref,
  memberId,
) async {
  final memberService = ref.read(memberServiceProvider);
  return memberService.getMemberProfile(memberId);
});

// Member Rank History Provider
final memberRankHistoryProvider =
    FutureProvider.family<List<Map<String, dynamic>>, int>((
      ref,
      memberId,
    ) async {
      final memberService = ref.read(memberServiceProvider);
      return memberService.getRankHistory(memberId);
    });

// Member Matches Provider
final memberMatchesProvider = FutureProvider.family<List<MatchModel>, int>((
  ref,
  memberId,
) async {
  final memberService = ref.read(memberServiceProvider);
  return memberService.getMemberMatches(memberId);
});
