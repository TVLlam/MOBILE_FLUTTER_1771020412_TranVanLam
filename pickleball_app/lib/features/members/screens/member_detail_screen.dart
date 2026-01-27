import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/enums.dart';
import '../../../providers/providers.dart';

class MemberDetailScreen extends ConsumerStatefulWidget {
  final int memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  ConsumerState<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends ConsumerState<MemberDetailScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(membersProvider.notifier).loadMemberDetail(widget.memberId);
  }

  @override
  Widget build(BuildContext context) {
    final membersState = ref.watch(membersProvider);
    final member = membersState.selectedMember;

    if (membersState.isLoading && member == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (member == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Không tìm thấy thành viên')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader(member)),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats card
                _buildStatsCard(member),
                const SizedBox(height: 24),

                // Contact info
                _buildContactSection(member),
                const SizedBox(height: 24),

                // Recent matches
                _buildRecentMatchesSection(member),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(member) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Avatar
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: member.avatarUrl != null
                        ? CachedNetworkImageProvider(member.avatarUrl!)
                        : null,
                    backgroundColor: Colors.white,
                    child: member.avatarUrl == null
                        ? Text(
                            member.fullName.isNotEmpty
                                ? member.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTierColor(member.tier),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.workspace_premium,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              member.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Tier badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getTierColor(member.tier),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Hạng ${_getTierName(member.tier)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(member) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thống kê', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Trận đấu',
                  '${member.totalMatches ?? 0}',
                  Icons.sports_tennis,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Thắng',
                  '${member.wins ?? 0}',
                  Icons.emoji_events,
                  color: AppColors.success,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Điểm',
                  '${member.points ?? 0}',
                  Icons.stars,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildWinRateBar(member)],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color ?? AppColors.primary),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(
            color: color ?? AppColors.primary,
          ),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildWinRateBar(member) {
    final totalMatches = member.totalMatches ?? 0;
    final wins = member.wins ?? 0;
    final winRate = totalMatches > 0 ? (wins / totalMatches * 100) : 0.0;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tỷ lệ thắng', style: AppTextStyles.bodyMedium),
              Text(
                '${winRate.toStringAsFixed(1)}%',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: winRate / 100,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(member) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thông tin liên hệ', style: AppTextStyles.heading3),
          const SizedBox(height: 16),
          _buildContactRow(Icons.email_outlined, 'Email', member.email),
          if (member.phone != null)
            _buildContactRow(Icons.phone_outlined, 'Điện thoại', member.phone!),
          if (member.address != null)
            _buildContactRow(
              Icons.location_on_outlined,
              'Địa chỉ',
              member.address!,
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentMatchesSection(member) {
    // TODO: Load member's recent matches from API
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trận đấu gần đây', style: AppTextStyles.heading3),
              TextButton(
                onPressed: () {
                  // TODO: Show all matches
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.sports_tennis, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Text(
                    'Chưa có trận đấu nào',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(MemberTier tier) {
    switch (tier) {
      case MemberTier.bronze:
        return Colors.brown;
      case MemberTier.silver:
        return Colors.grey;
      case MemberTier.gold:
        return Colors.amber[700]!;
      case MemberTier.platinum:
        return Colors.blueGrey;
      case MemberTier.diamond:
        return Colors.cyan[700]!;
    }
  }

  String _getTierName(MemberTier tier) {
    switch (tier) {
      case MemberTier.bronze:
        return 'Đồng';
      case MemberTier.silver:
        return 'Bạc';
      case MemberTier.gold:
        return 'Vàng';
      case MemberTier.platinum:
        return 'Bạch Kim';
      case MemberTier.diamond:
        return 'Kim Cương';
    }
  }
}
