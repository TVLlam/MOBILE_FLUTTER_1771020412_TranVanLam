import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/enums.dart';
import '../../../providers/providers.dart';
import '../widgets/standings_table.dart';
import '../widgets/match_list.dart';

class TournamentDetailScreen extends ConsumerStatefulWidget {
  final int tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  ConsumerState<TournamentDetailScreen> createState() =>
      _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends ConsumerState<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await ref
        .read(tournamentsProvider.notifier)
        .loadTournamentDetail(widget.tournamentId);
    await ref
        .read(tournamentsProvider.notifier)
        .loadMatches(widget.tournamentId);
    await ref
        .read(tournamentsProvider.notifier)
        .loadStandings(widget.tournamentId);
  }

  @override
  Widget build(BuildContext context) {
    final tournamentsState = ref.watch(tournamentsProvider);
    final tournament = tournamentsState.selectedTournament;

    if (tournamentsState.isLoading && tournament == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (tournament == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy giải đấu')),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(tournament),
        ],
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Thông tin'),
                Tab(text: 'Bảng đấu'),
                Tab(text: 'Trận đấu'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildInfoTab(tournament),
                  _buildStandingsTab(tournamentsState),
                  _buildMatchesTab(tournamentsState),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(tournament),
    );
  }

  Widget _buildSliverAppBar(TournamentModel tournament) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          tournament.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
          ),
        ),
        background: tournament.bannerUrl != null
            ? CachedNetworkImage(
                imageUrl: tournament.bannerUrl!,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
              )
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // TODO: Share tournament
          },
        ),
      ],
    );
  }

  Widget _buildInfoTab(TournamentModel tournament) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            _buildStatusCard(tournament),
            const SizedBox(height: 16),

            // Details card
            _buildDetailsCard(tournament),
            const SizedBox(height: 16),

            // Description
            if (tournament.description != null) ...[
              const Text('Mô tả', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(tournament.description!, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
            ],

            // Rules
            if (tournament.rules != null) ...[
              const Text('Thể lệ', style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(tournament.rules!, style: AppTextStyles.bodyMedium),
              ),
              const SizedBox(height: 16),
            ],

            // Prizes
            if (tournament.prizes != null && tournament.prizes!.isNotEmpty) ...[
              const Text('Giải thưởng', style: AppTextStyles.heading3),
              const SizedBox(height: 12),
              ...tournament.prizes!
                  .map(
                    (prize) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(prize)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(TournamentModel tournament) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(tournament.status),
            _getStatusColor(tournament.status).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusText(tournament.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${tournament.currentParticipants}/${tournament.maxParticipants} người tham gia',
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(TournamentModel tournament) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.sports_tennis,
            'Thể thức',
            _getFormatName(tournament.format),
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.calendar_today,
            'Thời gian',
            '${_formatDate(tournament.startDate)} - ${_formatDate(tournament.endDate)}',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.location_on,
            'Địa điểm',
            tournament.location ?? 'CLB VPT Phố Núi',
          ),
          const Divider(height: 24),
          _buildDetailRow(
            Icons.monetization_on,
            'Phí tham gia',
            tournament.entryFee > 0
                ? '${tournament.entryFee.toStringAsFixed(0)}đ'
                : 'Miễn phí',
          ),
          if (tournament.registrationDeadline != null) ...[
            const Divider(height: 24),
            _buildDetailRow(
              Icons.timer,
              'Hạn đăng ký',
              _formatDate(tournament.registrationDeadline!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption),
            Text(value, style: AppTextStyles.bodyLarge),
          ],
        ),
      ],
    );
  }

  Widget _buildPrizesSection(Map<String, dynamic> prizes) {
    return Column(
      children: [
        _buildPrizeCard(1, 'Vô địch', prizes['first'] ?? 0, Colors.amber),
        const SizedBox(height: 8),
        _buildPrizeCard(2, 'Á quân', prizes['second'] ?? 0, Colors.grey[400]!),
        const SizedBox(height: 8),
        _buildPrizeCard(
          3,
          'Hạng ba',
          prizes['third'] ?? 0,
          Colors.orange[700]!,
        ),
      ],
    );
  }

  Widget _buildPrizeCard(int rank, String title, dynamic prize, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: AppTextStyles.bodyLarge)),
          Text(
            prize is int || prize is double
                ? '${prize.toStringAsFixed(0)}đ'
                : prize.toString(),
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingsTab(TournamentState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.standings.isEmpty) {
      return const Center(child: Text('Chưa có bảng xếp hạng'));
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(tournamentsProvider.notifier)
          .loadStandings(widget.tournamentId),
      child: StandingsTable(standings: state.standings),
    );
  }

  Widget _buildMatchesTab(TournamentState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.matches.isEmpty) {
      return const Center(child: Text('Chưa có trận đấu nào'));
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(tournamentsProvider.notifier)
          .loadMatches(widget.tournamentId),
      child: MatchList(matches: state.matches),
    );
  }

  Widget _buildBottomBar(TournamentModel tournament) {
    final user = ref.watch(currentUserProvider);
    final isRegistered = tournament.isRegistered;

    if (tournament.status != TournamentStatus.upcoming) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: isRegistered ? null : _registerTournament,
          style: ElevatedButton.styleFrom(
            backgroundColor: isRegistered ? Colors.grey : AppColors.primary,
          ),
          child: Text(isRegistered ? 'ĐÃ ĐĂNG KÝ' : 'ĐĂNG KÝ THAM GIA'),
        ),
      ),
    );
  }

  Future<void> _registerTournament() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng ký'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng ký tham gia giải đấu này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ĐĂNG KÝ'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(tournamentsProvider.notifier)
          .registerTournament(widget.tournamentId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Color _getStatusColor(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.upcoming:
        return AppColors.info;
      case TournamentStatus.open:
        return AppColors.success;
      case TournamentStatus.registering:
        return AppColors.success;
      case TournamentStatus.drawCompleted:
        return AppColors.warning;
      case TournamentStatus.ongoing:
        return AppColors.success;
      case TournamentStatus.completed:
        return Colors.grey;
      case TournamentStatus.cancelled:
        return AppColors.error;
      case TournamentStatus.finished:
        return Colors.grey;
    }
  }

  String _getStatusText(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.upcoming:
        return 'Sắp diễn ra';
      case TournamentStatus.open:
        return 'Mở đăng ký';
      case TournamentStatus.registering:
        return 'Đang mở đăng ký';
      case TournamentStatus.drawCompleted:
        return 'Đã bốc thăm';
      case TournamentStatus.ongoing:
        return 'Đang diễn ra';
      case TournamentStatus.completed:
        return 'Đã kết thúc';
      case TournamentStatus.cancelled:
        return 'Đã hủy';
      case TournamentStatus.finished:
        return 'Đã kết thúc';
    }
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
