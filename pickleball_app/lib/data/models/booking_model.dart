import 'enums.dart';
import 'court_model.dart';

class BookingModel {
  final String id;
  final String courtId;
  final String userId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final double totalPrice;
  final BookingStatus status;
  final String? note;
  final CourtModel? court;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String? cancelReason;

  const BookingModel({
    required this.id,
    required this.courtId,
    required this.userId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    this.status = BookingStatus.pending,
    this.note,
    this.court,
    required this.createdAt,
    this.cancelledAt,
    this.cancelReason,
  });

  // Getter alias for 'date' field
  DateTime get bookingDate => date;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      courtId:
          json['courtId']?.toString() ?? json['court_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      startTime:
          json['startTime'] as String? ?? json['start_time'] as String? ?? '',
      endTime: json['endTime'] as String? ?? json['end_time'] as String? ?? '',
      totalPrice: (json['totalPrice'] ?? json['total_price'] ?? 0).toDouble(),
      status: _parseBookingStatus(json['status']),
      note: json['note'] as String?,
      court: json['court'] != null
          ? CourtModel.fromJson(json['court'] as Map<String, dynamic>)
          : null,
      createdAt:
          DateTime.tryParse(
            json['createdAt']?.toString() ??
                json['created_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'].toString())
          : json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'].toString())
          : null,
      cancelReason:
          json['cancelReason'] as String? ?? json['cancel_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'courtId': courtId,
    'userId': userId,
    'date': date.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'totalPrice': totalPrice,
    'status': status.name,
    'note': note,
    'court': court?.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'cancelledAt': cancelledAt?.toIso8601String(),
    'cancelReason': cancelReason,
  };

  static BookingStatus _parseBookingStatus(dynamic value) {
    if (value == null) return BookingStatus.pending;
    if (value is BookingStatus) return value;
    final str = value.toString().toLowerCase();
    return BookingStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => BookingStatus.pending,
    );
  }
}

class TimeSlotModel {
  final String id;
  final String startTime;
  final String endTime;
  final bool isAvailable;
  final double price;
  final String? courtId;

  const TimeSlotModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    required this.price,
    this.courtId,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id:
          json['id']?.toString() ??
          '${json['startTime'] ?? json['start_time']}-${json['endTime'] ?? json['end_time']}',
      startTime:
          json['startTime'] as String? ?? json['start_time'] as String? ?? '',
      endTime: json['endTime'] as String? ?? json['end_time'] as String? ?? '',
      isAvailable:
          json['isAvailable'] as bool? ?? json['is_available'] as bool? ?? true,
      price: (json['price'] ?? 0).toDouble(),
      courtId: json['courtId']?.toString() ?? json['court_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime,
    'endTime': endTime,
    'isAvailable': isAvailable,
    'price': price,
    'courtId': courtId,
  };
}

// Alias for backward compatibility
typedef TimeSlot = TimeSlotModel;

class BookingCalendarItem {
  final String id;
  final String courtId;
  final String? courtName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final BookingStatus status;
  final String? userName;

  const BookingCalendarItem({
    required this.id,
    required this.courtId,
    this.courtName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.userName,
  });

  factory BookingCalendarItem.fromJson(Map<String, dynamic> json) {
    return BookingCalendarItem(
      id: json['id']?.toString() ?? '',
      courtId:
          json['courtId']?.toString() ?? json['court_id']?.toString() ?? '',
      courtName: json['courtName'] as String? ?? json['court_name'] as String?,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      startTime:
          json['startTime'] as String? ?? json['start_time'] as String? ?? '',
      endTime: json['endTime'] as String? ?? json['end_time'] as String? ?? '',
      status: BookingModel._parseBookingStatus(json['status']),
      userName: json['userName'] as String? ?? json['user_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'courtId': courtId,
    'courtName': courtName,
    'date': date.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'status': status.name,
    'userName': userName,
  };
}

class CreateBookingRequest {
  final int courtId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String? note;

  const CreateBookingRequest({
    required this.courtId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.note,
  });

  Map<String, dynamic> toJson() {
    // Ensure time format is HH:mm:ss for .NET TimeSpan
    String formatTimeSpan(String time) {
      if (time.split(':').length == 2) {
        return '$time:00'; // Add seconds if missing
      }
      return time;
    }

    return {
      'courtId': courtId,
      'bookingDate': date.toIso8601String(),
      'startTime': formatTimeSpan(startTime),
      'endTime': formatTimeSpan(endTime),
      'notes': note,
    };
  }
}

class CreateRecurringBookingRequest {
  final String courtId;
  final DateTime startDate;
  final DateTime endDate;
  final List<int> weekdays; // 1=Mon, 7=Sun
  final String startTime;
  final String endTime;
  final String? note;

  const CreateRecurringBookingRequest({
    required this.courtId,
    required this.startDate,
    required this.endDate,
    required this.weekdays,
    required this.startTime,
    required this.endTime,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'courtId': courtId,
    'startDate': startDate.toIso8601String().split('T')[0],
    'endDate': endDate.toIso8601String().split('T')[0],
    'weekdays': weekdays,
    'startTime': startTime,
    'endTime': endTime,
    'note': note,
  };
}
