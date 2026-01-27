import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../providers/providers.dart';
import '../../../data/models/models.dart';
import '../widgets/stat_card.dart';
import '../widgets/upcoming_match_card.dart';
import '../widgets/news_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final upcomingMatches = ref.watch(upcomingMatchesProvider);
    final pinnedNews = ref.watch(pinnedNewsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(upcomingMatchesProvider);
        ref.invalidate(pinnedNewsProvider);
        await ref.read(authProvider.notifier).refreshUser();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            _buildWelcomeBanner(user),
            const SizedBox(height: 24),

            // Quick stats
            _buildQuickStats(user),
            const SizedBox(height: 24),

            // Upcoming matches
            _buildSectionTitle('Trận đấu sắp tới'),
            const SizedBox(height: 12),
            upcomingMatches.when(
              data: (matches) => matches.isEmpty
                  ? _buildEmptyState('Chưa có trận đấu nào')
                  : Column(
                      children: matches
                          .take(3)
                          .map((match) => UpcomingMatchCard(match: match))
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _buildEmptyState('Không thể tải dữ liệu'),
            ),
            const SizedBox(height: 24),

            // News
            _buildSectionTitle('Tin tức & Thông báo'),
            const SizedBox(height: 12),
            pinnedNews.isEmpty
                ? _buildEmptyState('Chưa có tin tức nào')
                : Column(
                    children: pinnedNews
                        .take(3)
                        .map((n) => NewsCard(news: n))
                        .toList(),
                  ),
            const SizedBox(height: 24),

            // Quick actions
            _buildSectionTitle('Thao tác nhanh'),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Rank chart
            if (user?.member != null) ...[
              _buildSectionTitle('Biểu đồ Rank DUPR'),
              const SizedBox(height: 12),
              _buildRankChart(user!.member!),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào, ${user?.fullName ?? 'Bạn'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (user?.member != null) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${user!.member!.tier.icon} ${user.member!.tier.displayName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'DUPR: ${user.member!.rankLevel.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.sports_tennis,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(UserModel? user) {
    final balance = user?.member?.walletBalance ?? 0;
    final rank = user?.member?.rankLevel ?? 0;

    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Số dư ví',
            value: CurrencyFormatter.formatCompact(balance),
            icon: Icons.account_balance_wallet,
            color: AppColors.primary,
            onTap: () => context.push('/wallet'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            title: 'Rank DUPR',
            value: rank.toStringAsFixed(2),
            icon: Icons.trending_up,
            color: AppColors.secondary,
            onTap: () => context.push('/profile'),
          ),
        ),
      ],
    );
  }

  Widget _buildRankChart(MemberModel member) {
    // Demo data for rank history
    final spots = [
      FlSpot(0, member.rankLevel - 0.3),
      FlSpot(1, member.rankLevel.toDouble() - 0.1),
      FlSpot(2, member.rankLevel.toDouble() + 0.2),
      FlSpot(3, member.rankLevel.toDouble() - 0.05),
      FlSpot(4, member.rankLevel.toDouble() + 0.1),
      FlSpot(5, member.rankLevel.toDouble()),
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _QuickActionButton(
          icon: Icons.calendar_today,
          label: 'Đặt sân',
          color: AppColors.primary,
          onTap: () => context.push('/booking'),
        ),
        _QuickActionButton(
          icon: Icons.emoji_events,
          label: 'Giải đấu',
          color: AppColors.secondary,
          onTap: () => context.push('/tournaments'),
        ),
        _QuickActionButton(
          icon: Icons.add_circle,
          label: 'Nạp tiền',
          color: AppColors.success,
          onTap: () => context.push('/wallet/deposit'),
        ),
        _QuickActionButton(
          icon: Icons.people,
          label: 'Thành viên',
          color: AppColors.info,
          onTap: () => context.push('/members'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.heading3);
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: AppColors.textHint),
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
