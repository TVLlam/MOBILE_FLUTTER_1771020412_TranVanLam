import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/enums.dart';
import '../../../providers/providers.dart';
import '../widgets/tournament_card.dart';

class TournamentsScreen extends ConsumerStatefulWidget {
  const TournamentsScreen({super.key});

  @override
  ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends ConsumerState<TournamentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TournamentStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Load tournaments after build completes to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTournaments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTournaments() async {
    print('DEBUG TournamentsScreen: _loadTournaments called');
    try {
      final notifier = ref.read(tournamentsProvider.notifier);
      print('DEBUG TournamentsScreen: Got notifier: $notifier');
      await notifier.loadTournaments(force: true);
      print('DEBUG TournamentsScreen: loadTournaments completed');
    } catch (e) {
      print('ERROR TournamentsScreen: Failed to load tournaments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giải đấu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Sắp diễn ra'),
            Tab(text: 'Đang diễn ra'),
            Tab(text: 'Đã kết thúc'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTournamentList(TournamentStatus.upcoming),
          _buildTournamentList(TournamentStatus.ongoing),
          _buildTournamentList(TournamentStatus.completed),
        ],
      ),
    );
  }

  Widget _buildTournamentList(TournamentStatus status) {
    final tournamentsState = ref.watch(tournamentsProvider);

    if (tournamentsState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredTournaments = tournamentsState.tournaments
        .where((t) => t.status == status)
        .toList();

    if (filteredTournaments.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: _loadTournaments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredTournaments.length,
        itemBuilder: (context, index) {
          final tournament = filteredTournaments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TournamentCard(
              tournament: tournament,
              onTap: () => context.push('/tournaments/${tournament.id}'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(TournamentStatus status) {
    String message;
    IconData icon;

    switch (status) {
      case TournamentStatus.upcoming:
        message = 'Chưa có giải đấu sắp diễn ra';
        icon = Icons.event_available;
        break;
      case TournamentStatus.ongoing:
        message = 'Không có giải đấu đang diễn ra';
        icon = Icons.sports_tennis;
        break;
      case TournamentStatus.completed:
        message = 'Chưa có giải đấu nào kết thúc';
        icon = Icons.emoji_events;
        break;
      default:
        message = 'Không có giải đấu';
        icon = Icons.sports;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lọc giải đấu', style: AppTextStyles.heading2),
            const SizedBox(height: 24),

            const Text('Thể thức', style: AppTextStyles.bodyLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TournamentFormat.values.map((format) {
                return FilterChip(
                  label: Text(_getFormatName(format)),
                  selected: false,
                  onSelected: (selected) {
                    // TODO: Apply filter
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Apply filters
                  Navigator.pop(context);
                },
                child: const Text('ÁP DỤNG'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFormatName(TournamentFormat format) {
    switch (format) {
      case TournamentFormat.singleElimination:
        return 'Loại trực tiếp';
      case TournamentFormat.doubleElimination:
        return 'Loại kép';
      case TournamentFormat.roundRobin:
        return 'Vòng tròn';
      case TournamentFormat.swiss:
        return 'Hệ Thụy Sĩ';
      case TournamentFormat.knockout:
        return 'Loại trực tiếp';
      case TournamentFormat.hybrid:
        return 'Kết hợp';
    }
  }
}
