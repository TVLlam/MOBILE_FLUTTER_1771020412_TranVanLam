import 'enums.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String userId;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.type = NotificationType.info,
    this.isRead = false,
    required this.userId,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? json['content'] as String? ?? '',
      type: _parseNotificationType(json['type']),
      isRead: json['isRead'] as bool? ?? json['is_read'] as bool? ?? false,
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      referenceId:
          json['referenceId']?.toString() ?? json['reference_id']?.toString(),
      referenceType:
          json['referenceType'] as String? ?? json['reference_type'] as String?,
      createdAt:
          DateTime.tryParse(
            json['createdAt']?.toString() ??
                json['created_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'type': type.name,
    'isRead': isRead,
    'userId': userId,
    'referenceId': referenceId,
    'referenceType': referenceType,
    'createdAt': createdAt.toIso8601String(),
  };

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    bool? isRead,
    String? userId,
    String? referenceId,
    String? referenceType,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      userId: userId ?? this.userId,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static NotificationType _parseNotificationType(dynamic value) {
    if (value == null) return NotificationType.info;
    if (value is NotificationType) return value;
    final str = value.toString().toLowerCase();
    return NotificationType.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => NotificationType.info,
    );
  }
}

class NewsModel {
  final String id;
  final String title;
  final String content;
  final String? imageUrl;
  final String? authorName;
  final bool isPinned;
  final int viewCount;
  final DateTime createdDate;
  final DateTime? updatedAt;

  const NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    this.authorName,
    this.isPinned = false,
    this.viewCount = 0,
    required this.createdDate,
    this.updatedAt,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? json['image_url'] as String?,
      authorName:
          json['authorName'] as String? ?? json['author_name'] as String?,
      isPinned:
          json['isPinned'] as bool? ?? json['is_pinned'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? json['view_count'] as int? ?? 0,
      createdDate:
          DateTime.tryParse(
            json['createdDate']?.toString() ??
                json['created_date']?.toString() ??
                json['createdAt']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'imageUrl': imageUrl,
    'authorName': authorName,
    'isPinned': isPinned,
    'viewCount': viewCount,
    'createdDate': createdDate.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
