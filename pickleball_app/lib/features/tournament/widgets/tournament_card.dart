import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/enums.dart';

class TournamentCard extends StatelessWidget {
  final TournamentModel tournament;
  final VoidCallback? onTap;

  const TournamentCard({super.key, required this.tournament, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Stack(
              children: [
                if (tournament.bannerUrl != null)
                  CachedNetworkImage(
                    imageUrl: tournament.bannerUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: AppColors.primary.withOpacity(0.2),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => _buildDefaultBanner(),
                  )
                else
                  _buildDefaultBanner(),

                // Status badge
                Positioned(top: 12, right: 12, child: _buildStatusBadge()),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Format
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tournament.name,
                          style: AppTextStyles.heading3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFormatChip(),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  if (tournament.description != null)
                    Text(
                      tournament.description!,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),

                  // Info row
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.calendar_today,
                        _formatDate(tournament.startDate),
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.people,
                        '${tournament.currentParticipants}/${tournament.maxParticipants}',
                      ),
                      const Spacer(),
                      if (tournament.entryFee > 0)
                        Text(
                          '${tournament.entryFee.toStringAsFixed(0)}đ',
                          style: AppTextStyles.heading3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),

                  // Register deadline warning
                  if (tournament.status == TournamentStatus.upcoming &&
                      tournament.registrationDeadline != null) ...[
                    const SizedBox(height: 12),
                    _buildDeadlineWarning(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBanner() {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.emoji_events, size: 48, color: Colors.white),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (tournament.status) {
      case TournamentStatus.upcoming:
        bgColor = AppColors.info;
        textColor = Colors.white;
        label = 'Sắp diễn ra';
        break;
      case TournamentStatus.open:
        bgColor = AppColors.success;
        textColor = Colors.white;
        label = 'Mở đăng ký';
        break;
      case TournamentStatus.registering:
        bgColor = AppColors.success;
        textColor = Colors.white;
        label = 'Đang mở đăng ký';
        break;
      case TournamentStatus.drawCompleted:
        bgColor = AppColors.warning;
        textColor = Colors.white;
        label = 'Đã bốc thăm';
        break;
      case TournamentStatus.ongoing:
        bgColor = AppColors.success;
        textColor = Colors.white;
        label = 'Đang diễn ra';
        break;
      case TournamentStatus.completed:
        bgColor = Colors.grey;
        textColor = Colors.white;
        label = 'Đã kết thúc';
        break;
      case TournamentStatus.cancelled:
        bgColor = AppColors.error;
        textColor = Colors.white;
        label = 'Đã hủy';
        break;
      case TournamentStatus.finished:
        bgColor = Colors.grey;
        textColor = Colors.white;
        label = 'Đã kết thúc';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFormatChip() {
    String formatName;
    switch (tournament.format) {
      case TournamentFormat.singleElimination:
        formatName = 'Loại trực tiếp';
        break;
      case TournamentFormat.doubleElimination:
        formatName = 'Loại kép';
        break;
      case TournamentFormat.roundRobin:
        formatName = 'Vòng tròn';
        break;
      case TournamentFormat.swiss:
        formatName = 'Thụy Sĩ';
        break;
      case TournamentFormat.knockout:
        formatName = 'Loại trực tiếp';
        break;
      case TournamentFormat.hybrid:
        formatName = 'Kết hợp';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        formatName,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDeadlineWarning() {
    final deadline = tournament.registrationDeadline!;
    final daysLeft = deadline.difference(DateTime.now()).inDays;

    if (daysLeft < 0) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: AppColors.error),
            SizedBox(width: 8),
            Text(
              'Đã hết hạn đăng ký',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    Color color = daysLeft <= 3 ? AppColors.warning : AppColors.info;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            'Còn $daysLeft ngày để đăng ký',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
