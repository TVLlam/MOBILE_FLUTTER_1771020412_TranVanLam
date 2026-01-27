import 'enums.dart';

class TournamentModel {
  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? registrationDeadline;
  final TournamentFormat format;
  final TournamentStatus status;
  final double entryFee;
  final double? prizePool;
  final int maxParticipants;
  final int currentParticipants;
  final String? location;
  final String? imageUrl;
  final String? rules;
  final List<String>? prizes;
  final DateTime createdAt;
  final bool isRegistered;

  // Getter alias for imageUrl
  String? get bannerUrl => imageUrl;

  // Getter alias for currentParticipants
  int get participants => currentParticipants;

  const TournamentModel({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    this.registrationDeadline,
    this.format = TournamentFormat.singleElimination,
    this.status = TournamentStatus.upcoming,
    this.entryFee = 0,
    this.prizePool,
    this.maxParticipants = 32,
    this.currentParticipants = 0,
    this.location,
    this.imageUrl,
    this.rules,
    this.prizes,
    required this.createdAt,
    this.isRegistered = false,
  });

  bool get canRegister {
    if (status != TournamentStatus.upcoming &&
        status != TournamentStatus.registering) {
      return false;
    }
    if (currentParticipants >= maxParticipants) return false;
    if (registrationDeadline != null &&
        DateTime.now().isAfter(registrationDeadline!)) {
      return false;
    }
    return !isRegistered;
  }

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      startDate:
          DateTime.tryParse(
            json['startDate']?.toString() ??
                json['start_date']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(
            json['endDate']?.toString() ?? json['end_date']?.toString() ?? '',
          ) ??
          DateTime.now(),
      registrationDeadline: json['registrationDeadline'] != null
          ? DateTime.tryParse(json['registrationDeadline'].toString())
          : json['registration_deadline'] != null
          ? DateTime.tryParse(json['registration_deadline'].toString())
          : null,
      format: _parseTournamentFormat(json['format']),
      status: _parseTournamentStatus(json['status']),
      entryFee: (json['entryFee'] ?? json['entry_fee'] ?? 0).toDouble(),
      prizePool: json['prizePool'] != null
          ? (json['prizePool']).toDouble()
          : json['prize_pool'] != null
          ? (json['prize_pool']).toDouble()
          : null,
      maxParticipants:
          json['maxParticipants'] as int? ??
          json['max_participants'] as int? ??
          32,
      currentParticipants:
          json['currentParticipants'] as int? ??
          json['current_participants'] as int? ??
          0,
      location: json['location'] as String?,
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      rules: json['rules'] as String?,
      prizes: (json['prizes'] as List<dynamic>?)?.cast<String>(),
      createdAt:
          DateTime.tryParse(
            json['createdAt']?.toString() ??
                json['created_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      isRegistered:
          json['isRegistered'] as bool? ??
          json['is_registered'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'registrationDeadline': registrationDeadline?.toIso8601String(),
    'format': format.name,
    'status': status.name,
    'entryFee': entryFee,
    'prizePool': prizePool,
    'maxParticipants': maxParticipants,
    'currentParticipants': currentParticipants,
    'location': location,
    'imageUrl': imageUrl,
    'rules': rules,
    'prizes': prizes,
    'createdAt': createdAt.toIso8601String(),
    'isRegistered': isRegistered,
  };

  static TournamentFormat _parseTournamentFormat(dynamic value) {
    if (value == null) return TournamentFormat.singleElimination;
    if (value is TournamentFormat) return value;
    final str = value.toString().toLowerCase();

    // Map backend play types (Singles/Doubles/Mixed) to tournament format
    // Since backend doesn't have actual tournament format, default to single elimination
    if (str == 'singles' || str == 'doubles' || str == 'mixed') {
      return TournamentFormat.singleElimination;
    }

    return TournamentFormat.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => TournamentFormat.singleElimination,
    );
  }

  static TournamentStatus _parseTournamentStatus(dynamic value) {
    if (value == null) return TournamentStatus.upcoming;
    if (value is TournamentStatus) return value;
    final str = value.toString().toLowerCase();
    return TournamentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => TournamentStatus.upcoming,
    );
  }
}

class MatchModel {
  final String id;
  final String tournamentId;
  final String? tournamentName;
  final int round;
  final int matchNumber;
  final String? player1Id;
  final String? player2Id;
  final String? player1Name;
  final String? player2Name;
  final String? team1Name;
  final String? team2Name;
  final int? player1Score;
  final int? player2Score;
  final MatchStatus status;
  final String? winnerId;
  final DateTime? scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? courtId;
  final String? courtName;
  final TournamentModel? tournament;
  final String? scoreDisplay;
  final DateTime? date;

  const MatchModel({
    required this.id,
    required this.tournamentId,
    this.tournamentName,
    this.round = 1,
    this.matchNumber = 1,
    this.player1Id,
    this.player2Id,
    this.player1Name,
    this.player2Name,
    this.team1Name,
    this.team2Name,
    this.player1Score,
    this.player2Score,
    this.status = MatchStatus.scheduled,
    this.winnerId,
    this.scheduledTime,
    this.startTime,
    this.endTime,
    this.courtId,
    this.courtName,
    this.tournament,
    this.scoreDisplay,
    this.date,
  });

  // Getter aliases for scores
  int? get score1 => player1Score;
  int? get score2 => player2Score;

  String get displayScore {
    if (scoreDisplay != null) return scoreDisplay!;
    if (player1Score == null || player2Score == null) return 'vs';
    return '$player1Score - $player2Score';
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id']?.toString() ?? '',
      tournamentId:
          json['tournamentId']?.toString() ??
          json['tournament_id']?.toString() ??
          '',
      tournamentName:
          json['tournamentName'] as String? ??
          json['tournament_name'] as String?,
      round: json['round'] as int? ?? 1,
      matchNumber:
          json['matchNumber'] as int? ?? json['match_number'] as int? ?? 1,
      player1Id:
          json['player1Id']?.toString() ?? json['player1_id']?.toString(),
      player2Id:
          json['player2Id']?.toString() ?? json['player2_id']?.toString(),
      player1Name:
          json['player1Name'] as String? ?? json['player1_name'] as String?,
      player2Name:
          json['player2Name'] as String? ?? json['player2_name'] as String?,
      team1Name:
          json['team1Name'] as String? ??
          json['team1_name'] as String? ??
          json['player1Name'] as String?,
      team2Name:
          json['team2Name'] as String? ??
          json['team2_name'] as String? ??
          json['player2Name'] as String?,
      player1Score:
          json['player1Score'] as int? ?? json['player1_score'] as int?,
      player2Score:
          json['player2Score'] as int? ?? json['player2_score'] as int?,
      status: _parseMatchStatus(json['status']),
      winnerId: json['winnerId']?.toString() ?? json['winner_id']?.toString(),
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.tryParse(json['scheduledTime'].toString())
          : json['scheduled_time'] != null
          ? DateTime.tryParse(json['scheduled_time'].toString())
          : null,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString())
          : json['start_time'] != null
          ? DateTime.tryParse(json['start_time'].toString())
          : null,
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'].toString())
          : json['end_time'] != null
          ? DateTime.tryParse(json['end_time'].toString())
          : null,
      courtId: json['courtId']?.toString() ?? json['court_id']?.toString(),
      courtName: json['courtName'] as String? ?? json['court_name'] as String?,
      tournament: json['tournament'] != null
          ? TournamentModel.fromJson(json['tournament'] as Map<String, dynamic>)
          : null,
      scoreDisplay:
          json['scoreDisplay'] as String? ?? json['score_display'] as String?,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'].toString())
          : json['scheduledTime'] != null
          ? DateTime.tryParse(json['scheduledTime'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tournamentId': tournamentId,
    'tournamentName': tournamentName,
    'round': round,
    'matchNumber': matchNumber,
    'player1Id': player1Id,
    'player2Id': player2Id,
    'player1Name': player1Name,
    'player2Name': player2Name,
    'team1Name': team1Name,
    'team2Name': team2Name,
    'player1Score': player1Score,
    'player2Score': player2Score,
    'status': status.name,
    'winnerId': winnerId,
    'scheduledTime': scheduledTime?.toIso8601String(),
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'courtId': courtId,
    'courtName': courtName,
    'tournament': tournament?.toJson(),
    'scoreDisplay': scoreDisplay,
    'date': date?.toIso8601String(),
  };

  static MatchStatus _parseMatchStatus(dynamic value) {
    if (value == null) return MatchStatus.scheduled;
    if (value is MatchStatus) return value;
    final str = value.toString().toLowerCase();
    return MatchStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => MatchStatus.scheduled,
    );
  }
}

// Alias for backward compatibility
typedef BracketMatch = MatchModel;

class StandingModel {
  final int rank;
  final String participantId;
  final String participantName;
  final String? avatarUrl;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int pointsFor;
  final int pointsAgainst;
  final int? totalPoints;

  const StandingModel({
    required this.rank,
    required this.participantId,
    required this.participantName,
    this.avatarUrl,
    this.matchesPlayed = 0,
    this.wins = 0,
    this.losses = 0,
    this.pointsFor = 0,
    this.pointsAgainst = 0,
    this.totalPoints,
  });

  // Getter aliases
  String get playerName => participantName;
  int get played => matchesPlayed;
  int get won => wins;
  int get lost => losses;
  int get points => totalPoints ?? 0;

  int get pointDifference => pointsFor - pointsAgainst;

  factory StandingModel.fromJson(Map<String, dynamic> json) {
    return StandingModel(
      rank: json['rank'] as int? ?? 0,
      participantId:
          json['participantId']?.toString() ??
          json['participant_id']?.toString() ??
          '',
      participantName:
          json['participantName'] as String? ??
          json['participant_name'] as String? ??
          '',
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      matchesPlayed:
          json['matchesPlayed'] as int? ?? json['matches_played'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      pointsFor: json['pointsFor'] as int? ?? json['points_for'] as int? ?? 0,
      pointsAgainst:
          json['pointsAgainst'] as int? ?? json['points_against'] as int? ?? 0,
      totalPoints: json['totalPoints'] as int? ?? json['total_points'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'rank': rank,
    'participantId': participantId,
    'participantName': participantName,
    'avatarUrl': avatarUrl,
    'matchesPlayed': matchesPlayed,
    'wins': wins,
    'losses': losses,
    'pointsFor': pointsFor,
    'pointsAgainst': pointsAgainst,
    'totalPoints': totalPoints,
  };
}

// Alias for backward compatibility
typedef TournamentStanding = StandingModel;

class TournamentParticipantModel {
  final String id;
  final String tournamentId;
  final String userId;
  final String? userName;
  final String? avatarUrl;
  final DateTime registeredAt;
  final bool isPaid;
  final int? seed;

  const TournamentParticipantModel({
    required this.id,
    required this.tournamentId,
    required this.userId,
    this.userName,
    this.avatarUrl,
    required this.registeredAt,
    this.isPaid = false,
    this.seed,
  });

  factory TournamentParticipantModel.fromJson(Map<String, dynamic> json) {
    return TournamentParticipantModel(
      id: json['id']?.toString() ?? '',
      tournamentId:
          json['tournamentId']?.toString() ??
          json['tournament_id']?.toString() ??
          '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      userName: json['userName'] as String? ?? json['user_name'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      registeredAt:
          DateTime.tryParse(
            json['registeredAt']?.toString() ??
                json['registered_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      isPaid: json['isPaid'] as bool? ?? json['is_paid'] as bool? ?? false,
      seed: json['seed'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tournamentId': tournamentId,
    'userId': userId,
    'userName': userName,
    'avatarUrl': avatarUrl,
    'registeredAt': registeredAt.toIso8601String(),
    'isPaid': isPaid,
    'seed': seed,
  };
}

class UpdateMatchResultRequest {
  final int player1Score;
  final int player2Score;
  final String? winnerId;
  final List<String>? setScores;

  const UpdateMatchResultRequest({
    required this.player1Score,
    required this.player2Score,
    this.winnerId,
    this.setScores,
  });

  Map<String, dynamic> toJson() => {
    'player1Score': player1Score,
    'player2Score': player2Score,
    'winnerId': winnerId,
    'setScores': setScores,
  };
}
