import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/enums.dart';
import '../../../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isVIP = ref.watch(isVIPProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(authProvider.notifier).refreshUser(),
        child: CustomScrollView(
          slivers: [
            // Profile header
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProfileHeader(context, user, isVIP),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    // TODO: Settings screen
                  },
                ),
              ],
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Stats card
                  _buildStatsCard(user),
                  const SizedBox(height: 24),

                  // Menu items
                  _buildMenuSection(context, ref),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user, bool isVIP) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                    backgroundImage: user.avatarUrl != null
                        ? CachedNetworkImageProvider(user.avatarUrl!)
                        : null,
                    backgroundColor: Colors.white,
                    child: user.avatarUrl == null
                        ? Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
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
                if (isVIP)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.star,
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
              user.fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),

            // Email
            Text(
              user.email,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),

            // Tier badge
            if (user.member != null) _buildTierBadge(user.member!.tier),
          ],
        ),
      ),
    );
  }

  Widget _buildTierBadge(MemberTier tier) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (tier) {
      case MemberTier.bronze:
        bgColor = Colors.brown[300]!;
        textColor = Colors.white;
        label = 'Đồng';
        icon = Icons.workspace_premium;
        break;
      case MemberTier.silver:
        bgColor = Colors.grey[400]!;
        textColor = Colors.white;
        label = 'Bạc';
        icon = Icons.workspace_premium;
        break;
      case MemberTier.gold:
        bgColor = Colors.amber;
        textColor = Colors.white;
        label = 'Vàng';
        icon = Icons.workspace_premium;
        break;
      case MemberTier.platinum:
        bgColor = Colors.blueGrey;
        textColor = Colors.white;
        label = 'Bạch Kim';
        icon = Icons.diamond;
        break;
      case MemberTier.diamond:
        bgColor = Colors.cyan[700]!;
        textColor = Colors.white;
        label = 'Kim Cương';
        icon = Icons.diamond;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            'Hạng $label',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(user) {
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
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Trận đấu',
                  '${user.member?.totalMatches ?? 0}',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildStatItem('Thắng', '${user.member?.wins ?? 0}'),
              ),
              Container(width: 1, height: 40, color: Colors.grey[200]),
              Expanded(
                child: _buildStatItem('Điểm', '${user.member?.points ?? 0}'),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Số dư ví', style: AppTextStyles.bodyMedium),
              Text(
                CurrencyFormatter.format(user.member?.walletBalance ?? 0),
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tài khoản', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.person_outline,
          title: 'Chỉnh sửa thông tin',
          onTap: () => context.push('/profile/edit'),
        ),
        _buildMenuItem(
          icon: Icons.lock_outline,
          title: 'Đổi mật khẩu',
          onTap: () {
            // TODO: Change password
          },
        ),
        _buildMenuItem(
          icon: Icons.credit_card_outlined,
          title: 'Ví của tôi',
          onTap: () => context.push('/wallet'),
        ),
        _buildMenuItem(
          icon: Icons.history,
          title: 'Lịch sử đặt sân',
          onTap: () => context.push('/booking'),
        ),

        const SizedBox(height: 24),
        const Text('Hệ thống', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.group_outlined,
          title: 'Danh sách thành viên',
          onTap: () => context.push('/members'),
        ),
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Cài đặt thông báo',
          onTap: () {
            // TODO: Notification settings
          },
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          title: 'Trợ giúp & Hỗ trợ',
          onTap: () {
            // TODO: Help screen
          },
        ),
        _buildMenuItem(
          icon: Icons.info_outline,
          title: 'Về ứng dụng',
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'VPT Phố Núi',
              applicationVersion: '1.0.0',
              applicationIcon: const FlutterLogo(size: 64),
              children: [
                const Text('Ứng dụng quản lý CLB Pickleball'),
                const Text('VỢT THỦ PHỐ NÚI'),
              ],
            );
          },
        ),

        const SizedBox(height: 24),
        _buildMenuItem(
          icon: Icons.logout,
          title: 'Đăng xuất',
          titleColor: AppColors.error,
          showArrow: false,
          onTap: () => _showLogoutDialog(context, ref),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: titleColor ?? AppColors.textPrimary),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: showArrow
            ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('ĐĂNG XUẤT'),
          ),
        ],
      ),
    );
  }
}
