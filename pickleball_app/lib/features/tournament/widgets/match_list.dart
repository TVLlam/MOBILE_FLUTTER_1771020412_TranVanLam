import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/enums.dart';

class MatchList extends StatelessWidget {
  final List<MatchModel> matches;

  const MatchList({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    // Group matches by round
    final groupedMatches = <String, List<MatchModel>>{};
    for (final match in matches) {
      final key = 'Vòng ${match.round}';
      groupedMatches.putIfAbsent(key, () => []);
      groupedMatches[key]!.add(match);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedMatches.length,
      itemBuilder: (context, index) {
        final round = groupedMatches.keys.elementAt(index);
        final roundMatches = groupedMatches[round]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Round header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(round, style: AppTextStyles.heading3),
            ),

            // Matches
            ...roundMatches.map((match) => _buildMatchCard(match)),

            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          // Status and time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(match.status),
              if (match.scheduledTime != null)
                Text(
                  _formatDateTime(match.scheduledTime!),
                  style: AppTextStyles.caption,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Players and score
          Row(
            children: [
              // Player 1
              Expanded(
                child: _buildPlayerSection(
                  match.player1Name ?? 'TBD',
                  match.score1,
                  match.status == MatchStatus.completed &&
                      match.score1 != null &&
                      match.score2 != null &&
                      match.score1! > match.score2!,
                ),
              ),

              // VS / Score
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    match.status == MatchStatus.completed ||
                        match.status == MatchStatus.inProgress
                    ? Column(
                        children: [
                          Text(
                            '${match.score1 ?? 0} - ${match.score2 ?? 0}',
                            style: AppTextStyles.heading2,
                          ),
                          if (match.status == MatchStatus.inProgress)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      )
                    : const Text(
                        'VS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
              ),

              // Player 2
              Expanded(
                child: _buildPlayerSection(
                  match.player2Name ?? 'TBD',
                  match.score2,
                  match.status == MatchStatus.completed &&
                      match.score1 != null &&
                      match.score2 != null &&
                      match.score2! > match.score1!,
                  isRight: true,
                ),
              ),
            ],
          ),

          // Court info
          if (match.courtName != null) ...[
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sports_tennis,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(match.courtName!, style: AppTextStyles.caption),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerSection(
    String name,
    int? score,
    bool isWinner, {
    bool isRight = false,
  }) {
    return Column(
      crossAxisAlignment: isRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: isWinner
              ? AppColors.success.withOpacity(0.2)
              : AppColors.primary.withOpacity(0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWinner ? AppColors.success : AppColors.primary,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isWinner && !isRight)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.emoji_events, size: 14, color: Colors.amber),
              ),
            Flexible(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                  color: isWinner ? AppColors.success : AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: isRight ? TextAlign.right : TextAlign.left,
              ),
            ),
            if (isWinner && isRight)
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.emoji_events, size: 14, color: Colors.amber),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(MatchStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case MatchStatus.scheduled:
        bgColor = AppColors.info.withOpacity(0.2);
        textColor = AppColors.info;
        label = 'Chưa bắt đầu';
        break;
      case MatchStatus.inProgress:
        bgColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        label = 'Đang diễn ra';
        break;
      case MatchStatus.completed:
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey[700]!;
        label = 'Đã kết thúc';
        break;
      case MatchStatus.finished:
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey[700]!;
        label = 'Đã kết thúc';
        break;
      case MatchStatus.cancelled:
        bgColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        label = 'Đã hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
