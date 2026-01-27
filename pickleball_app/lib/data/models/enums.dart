// Enums cho hệ thống quản lý CLB Pickleball

/// Hạng thành viên
enum MemberTier {
  bronze, // Đồng
  silver, // Bạc
  gold, // Vàng
  platinum, // Bạch kim
  diamond, // Kim Cương
}

extension MemberTierExtension on MemberTier {
  String get displayName {
    switch (this) {
      case MemberTier.bronze:
        return 'Đồng';
      case MemberTier.silver:
        return 'Bạc';
      case MemberTier.gold:
        return 'Vàng';
      case MemberTier.platinum:
        return 'Bạch kim';
      case MemberTier.diamond:
        return 'Kim Cương';
    }
  }

  String get icon {
    switch (this) {
      case MemberTier.bronze:
        return '🥉';
      case MemberTier.silver:
        return '🥈';
      case MemberTier.gold:
        return '🥇';
      case MemberTier.platinum:
        return '💠';
      case MemberTier.diamond:
        return '💎';
    }
  }
}

/// Loại giao dịch ví
enum TransactionType {
  deposit, // Nạp tiền
  withdraw, // Rút tiền
  payment, // Thanh toán (đặt sân, phí giải đấu)
  refund, // Hoàn tiền
  reward, // Thưởng giải
  other, // Khác
}

extension TransactionTypeExtension on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.deposit:
        return 'Nạp tiền';
      case TransactionType.withdraw:
        return 'Rút tiền';
      case TransactionType.payment:
        return 'Thanh toán';
      case TransactionType.refund:
        return 'Hoàn tiền';
      case TransactionType.reward:
        return 'Thưởng giải';
      case TransactionType.other:
        return 'Khác';
    }
  }
}

/// Trạng thái giao dịch
enum TransactionStatus {
  pending, // Chờ duyệt
  completed, // Hoàn thành
  rejected, // Từ chối
  failed, // Thất bại
}

extension TransactionStatusExtension on TransactionStatus {
  String get displayName {
    switch (this) {
      case TransactionStatus.pending:
        return 'Chờ duyệt';
      case TransactionStatus.completed:
        return 'Hoàn thành';
      case TransactionStatus.rejected:
        return 'Từ chối';
      case TransactionStatus.failed:
        return 'Thất bại';
    }
  }
}

/// Trạng thái đặt sân
enum BookingStatus {
  pending, // Chờ xác nhận
  pendingPayment, // Chờ thanh toán
  confirmed, // Đã xác nhận
  cancelled, // Đã hủy
  completed, // Hoàn thành
  holding, // Đang giữ chỗ
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Chờ xác nhận';
      case BookingStatus.pendingPayment:
        return 'Chờ thanh toán';
      case BookingStatus.confirmed:
        return 'Đã xác nhận';
      case BookingStatus.cancelled:
        return 'Đã hủy';
      case BookingStatus.completed:
        return 'Hoàn thành';
      case BookingStatus.holding:
        return 'Đang giữ';
    }
  }
}

/// Thể thức giải đấu
enum TournamentFormat {
  singleElimination, // Loại trực tiếp đơn
  doubleElimination, // Loại trực tiếp kép
  roundRobin, // Vòng tròn
  swiss, // Hệ thống Thụy Sĩ
  knockout, // Loại trực tiếp
  hybrid, // Kết hợp
}

extension TournamentFormatExtension on TournamentFormat {
  String get displayName {
    switch (this) {
      case TournamentFormat.singleElimination:
        return 'Loại trực tiếp đơn';
      case TournamentFormat.doubleElimination:
        return 'Loại trực tiếp kép';
      case TournamentFormat.roundRobin:
        return 'Vòng tròn';
      case TournamentFormat.swiss:
        return 'Hệ Thụy Sĩ';
      case TournamentFormat.knockout:
        return 'Loại trực tiếp';
      case TournamentFormat.hybrid:
        return 'Kết hợp';
    }
  }
}

/// Trạng thái giải đấu
enum TournamentStatus {
  upcoming, // Sắp diễn ra
  open, // Mở đăng ký
  registering, // Đang đăng ký
  drawCompleted, // Đã bốc thăm
  ongoing, // Đang diễn ra
  completed, // Hoàn thành
  cancelled, // Đã hủy
  finished, // Kết thúc
}

extension TournamentStatusExtension on TournamentStatus {
  String get displayName {
    switch (this) {
      case TournamentStatus.upcoming:
        return 'Sắp diễn ra';
      case TournamentStatus.open:
        return 'Mở đăng ký';
      case TournamentStatus.registering:
        return 'Đang mở đăng ký';
      case TournamentStatus.drawCompleted:
        return 'Đã bốc thăm';
      case TournamentStatus.ongoing:
        return 'Đang diễn ra';
      case TournamentStatus.completed:
        return 'Hoàn thành';
      case TournamentStatus.cancelled:
        return 'Đã hủy';
      case TournamentStatus.finished:
        return 'Đã kết thúc';
    }
  }
}

/// Trạng thái trận đấu
enum MatchStatus {
  scheduled, // Đã lên lịch
  inProgress, // Đang diễn ra
  completed, // Hoàn thành
  cancelled, // Đã hủy
  finished, // Kết thúc
}

extension MatchStatusExtension on MatchStatus {
  String get displayName {
    switch (this) {
      case MatchStatus.scheduled:
        return 'Đã lên lịch';
      case MatchStatus.inProgress:
        return 'Đang đấu';
      case MatchStatus.completed:
        return 'Hoàn thành';
      case MatchStatus.cancelled:
        return 'Đã hủy';
      case MatchStatus.finished:
        return 'Kết thúc';
    }
  }
}

/// Đội thắng
enum WinningSide { team1, team2, draw }

/// Loại thông báo
enum NotificationType {
  info,
  success,
  warning,
  error,
  booking,
  tournament,
  wallet,
  match,
  system,
  promotion,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.info:
        return 'Thông tin';
      case NotificationType.success:
        return 'Thành công';
      case NotificationType.warning:
        return 'Cảnh báo';
      case NotificationType.error:
        return 'Lỗi';
      case NotificationType.booking:
        return 'Đặt sân';
      case NotificationType.tournament:
        return 'Giải đấu';
      case NotificationType.wallet:
        return 'Ví tiền';
      case NotificationType.match:
        return 'Trận đấu';
      case NotificationType.system:
        return 'Hệ thống';
      case NotificationType.promotion:
        return 'Khuyến mãi';
    }
  }
}

/// Role người dùng
enum UserRole {
  member, // Thành viên
  admin, // Quản trị viên
  treasurer, // Thủ quỹ
  referee, // Trọng tài
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.member:
        return 'Thành viên';
      case UserRole.admin:
        return 'Quản trị viên';
      case UserRole.treasurer:
        return 'Thủ quỹ';
      case UserRole.referee:
        return 'Trọng tài';
    }
  }
}
