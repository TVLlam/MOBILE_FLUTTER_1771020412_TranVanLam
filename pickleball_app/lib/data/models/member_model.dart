import 'enums.dart';

class MemberModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final MemberTier tier;
  final double walletBalance;
  final int totalMatches;
  final int wins;
  final int losses;
  final int? skillLevel;
  final int rankLevel;
  final int points;
  final DateTime? joinDate;
  final bool isActive;
  final String? bio;
  final String? address;

  const MemberModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.tier = MemberTier.bronze,
    this.walletBalance = 0,
    this.totalMatches = 0,
    this.wins = 0,
    this.losses = 0,
    this.skillLevel,
    this.rankLevel = 0,
    this.points = 0,
    this.joinDate,
    this.isActive = true,
    this.bio,
    this.address,
  });

  double get winRate {
    if (totalMatches == 0) return 0;
    return (wins / totalMatches) * 100;
  }

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id']?.toString() ?? '',
      fullName:
          json['fullName'] as String? ?? json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber:
          json['phoneNumber'] as String? ?? json['phone_number'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      tier: _parseMemberTier(json['tier'] ?? json['memberTier']),
      walletBalance: (json['walletBalance'] ?? json['wallet_balance'] ?? 0)
          .toDouble(),
      totalMatches:
          json['totalMatches'] as int? ?? json['total_matches'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      skillLevel: json['skillLevel'] as int? ?? json['skill_level'] as int?,
      rankLevel: json['rankLevel'] as int? ?? json['rank_level'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      joinDate: json['joinDate'] != null
          ? DateTime.tryParse(json['joinDate'].toString())
          : json['join_date'] != null
          ? DateTime.tryParse(json['join_date'].toString())
          : null,
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      bio: json['bio'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'avatarUrl': avatarUrl,
    'tier': tier.name,
    'walletBalance': walletBalance,
    'totalMatches': totalMatches,
    'wins': wins,
    'losses': losses,
    'skillLevel': skillLevel,
    'rankLevel': rankLevel,
    'points': points,
    'joinDate': joinDate?.toIso8601String(),
    'isActive': isActive,
    'bio': bio,
    'address': address,
  };

  MemberModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    MemberTier? tier,
    double? walletBalance,
    int? totalMatches,
    int? wins,
    int? losses,
    int? skillLevel,
    int? rankLevel,
    int? points,
    DateTime? joinDate,
    bool? isActive,
    String? bio,
    String? address,
  }) {
    return MemberModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tier: tier ?? this.tier,
      walletBalance: walletBalance ?? this.walletBalance,
      totalMatches: totalMatches ?? this.totalMatches,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      skillLevel: skillLevel ?? this.skillLevel,
      rankLevel: rankLevel ?? this.rankLevel,
      points: points ?? this.points,
      joinDate: joinDate ?? this.joinDate,
      isActive: isActive ?? this.isActive,
      bio: bio ?? this.bio,
      address: address ?? this.address,
    );
  }

  static MemberTier _parseMemberTier(dynamic value) {
    if (value == null) return MemberTier.bronze;
    if (value is MemberTier) return value;
    final str = value.toString().toLowerCase();
    return MemberTier.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => MemberTier.bronze,
    );
  }
}
