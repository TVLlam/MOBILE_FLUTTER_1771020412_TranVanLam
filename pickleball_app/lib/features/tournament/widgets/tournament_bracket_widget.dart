import 'package:flutter/material.dart';
import 'package:pickleball_app/core/theme/app_theme.dart';
import 'package:pickleball_app/data/models/tournament_model.dart';
import 'package:pickleball_app/data/models/enums.dart';

class TournamentBracketWidget extends StatelessWidget {
  final List<MatchModel> matches;
  final String tournamentFormat;

  const TournamentBracketWidget({
    super.key,
    required this.matches,
    this.tournamentFormat = 'Knockout',
  });

  @override
  Widget build(BuildContext context) {
    if (tournamentFormat == 'RoundRobin') {
      return _buildRoundRobinView();
    } else {
      return _buildKnockoutBracket();
    }
  }

  Widget _buildRoundRobinView() {
    // Group matches by round
    final grouped = <int, List<MatchModel>>{};
    for (final match in matches) {
      grouped.putIfAbsent(match.round, () => []).add(match);
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final round = grouped.keys.elementAt(index);
        final roundMatches = grouped[round]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Bảng ${String.fromCharCode(65 + round - 1)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...roundMatches.map((match) => _buildMatchCard(match)).toList(),
            const Divider(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildKnockoutBracket() {
    // Group by round
    final rounds = <int, List<MatchModel>>{};
    for (final match in matches) {
      rounds.putIfAbsent(match.round, () => []).add(match);
    }

    final sortedRounds = rounds.keys.toList()..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sortedRounds.map((round) {
              final roundMatches = rounds[round]!;
              return _buildRoundColumn(
                round,
                roundMatches,
                sortedRounds.length,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildRoundColumn(
    int round,
    List<MatchModel> matches,
    int totalRounds,
  ) {
    final roundName = _getRoundName(round, totalRounds);

    return Column(
      children: [
        Container(
          width: 250,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            roundName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ...matches.asMap().entries.map((entry) {
          final index = entry.key;
          final match = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : _calculateSpacing(round),
              bottom: 16,
            ),
            child: Row(
              children: [
                _buildBracketMatch(match),
                if (round < totalRounds) _buildConnector(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  double _calculateSpacing(int round) {
    // Increase spacing for later rounds
    return 20.0 * (1 << (round - 1));
  }

  Widget _buildConnector() {
    return Container(
      width: 40,
      height: 2,
      color: AppColors.primary.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String _getRoundName(int round, int totalRounds) {
    if (round == totalRounds) {
      return 'Chung kết';
    } else if (round == totalRounds - 1) {
      return 'Bán kết';
    } else if (round == totalRounds - 2) {
      return 'Tứ kết';
    } else {
      return 'Vòng ${round}';
    }
  }

  Widget _buildBracketMatch(MatchModel match) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: match.status == MatchStatus.finished
              ? AppColors.success.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Match header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(10),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sports_tennis,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Trận ${match.matchNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                _buildMatchStatus(match.status),
              ],
            ),
          ),

          // Team 1
          _buildTeamRow(
            match.team1Name ?? match.player1Name ?? 'TBD',
            match.player1Score,
            match.status == MatchStatus.finished &&
                match.player1Score != null &&
                match.player2Score != null &&
                match.player1Score! > match.player2Score!,
          ),

          const Divider(height: 1),

          // Team 2
          _buildTeamRow(
            match.team2Name ?? match.player2Name ?? 'TBD',
            match.player2Score,
            match.status == MatchStatus.finished &&
                match.player1Score != null &&
                match.player2Score != null &&
                match.player2Score! > match.player1Score!,
          ),

          // Match info
          if (match.scheduledTime != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${match.scheduledTime!.day}/${match.scheduledTime!.month} - ${match.scheduledTime!.hour}:${match.scheduledTime!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamRow(String teamName, int? score, bool isWinner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isWinner ? AppColors.success.withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          if (isWinner)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
          Expanded(
            child: Text(
              teamName,
              style: TextStyle(
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: score != null
                  ? (isWinner ? AppColors.success : Colors.grey[300])
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              score?.toString() ?? '-',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: score != null && isWinner
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStatus(MatchStatus status) {
    Color color;
    String text;

    switch (status) {
      case MatchStatus.scheduled:
        color = AppColors.warning;
        text = 'Chưa đá';
        break;
      case MatchStatus.inProgress:
        color = AppColors.info;
        text = 'Đang đá';
        break;
      case MatchStatus.finished:
        color = AppColors.success;
        text = 'Hoàn thành';
        break;
      case MatchStatus.completed:
        color = AppColors.success;
        text = 'Hoàn thành';
        break;
      case MatchStatus.cancelled:
        color = AppColors.error;
        text = 'Hủy';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Trận ${match.matchNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildMatchStatus(match.status),
              ],
            ),
            const SizedBox(height: 12),
            _buildTeamRow(
              match.team1Name ?? match.player1Name ?? 'TBD',
              match.player1Score,
              match.status == MatchStatus.finished &&
                  match.player1Score != null &&
                  match.player2Score != null &&
                  match.player1Score! > match.player2Score!,
            ),
            const Divider(),
            _buildTeamRow(
              match.team2Name ?? match.player2Name ?? 'TBD',
              match.player2Score,
              match.status == MatchStatus.finished &&
                  match.player1Score != null &&
                  match.player2Score != null &&
                  match.player2Score! > match.player1Score!,
            ),
            if (match.scheduledTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${match.scheduledTime!.day}/${match.scheduledTime!.month} - ${match.scheduledTime!.hour}:${match.scheduledTime!.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
