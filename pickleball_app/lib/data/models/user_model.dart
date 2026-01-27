import 'enums.dart';
import 'member_model.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? role;
  final MemberModel? member;
  final DateTime? createdAt;
  final String? address;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    this.role,
    this.member,
    this.createdAt,
    this.address,
  });

  // Alias for phoneNumber
  String? get phone => phoneNumber;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      fullName:
          json['fullName'] as String? ?? json['full_name'] as String? ?? '',
      phoneNumber:
          json['phoneNumber'] as String? ??
          json['phone_number'] as String? ??
          json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar_url'] as String?,
      role: json['role'] as String?,
      member: json['member'] != null
          ? MemberModel.fromJson(json['member'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'avatarUrl': avatarUrl,
    'role': role,
    'member': member?.toJson(),
    'createdAt': createdAt?.toIso8601String(),
    'address': address,
  };

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? role,
    MemberModel? member,
    DateTime? createdAt,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      member: member ?? this.member,
      createdAt: createdAt ?? this.createdAt,
      address: address ?? this.address,
    );
  }
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final UserModel user;
  final DateTime? expiresAt;

  const LoginResponse({
    required this.accessToken,
    this.refreshToken,
    required this.user,
    this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken:
          json['accessToken'] as String? ??
          json['access_token'] as String? ??
          json['token'] as String? ??
          '',
      refreshToken:
          json['refreshToken'] as String? ?? json['refresh_token'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? json),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
    );
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
  };
}

class UpdateProfileRequest {
  final String? fullName;
  final String? phoneNumber;
  final String? avatarBase64;
  final String? bio;
  final String? address;

  const UpdateProfileRequest({
    this.fullName,
    this.phoneNumber,
    this.avatarBase64,
    this.bio,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (fullName != null) data['fullName'] = fullName;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (avatarBase64 != null) data['avatarBase64'] = avatarBase64;
    if (bio != null) data['bio'] = bio;
    if (address != null) data['address'] = address;
    return data;
  }
}
