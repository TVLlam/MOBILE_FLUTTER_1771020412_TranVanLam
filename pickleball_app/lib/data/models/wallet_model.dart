import 'enums.dart';

class WalletTransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final TransactionStatus status;
  final String? description;
  final String? referenceId;
  final String? referenceType;
  final String? proofImageUrl;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? processedBy;
  final String? rejectReason;

  const WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.status = TransactionStatus.pending,
    this.description,
    this.referenceId,
    this.referenceType,
    this.proofImageUrl,
    required this.createdAt,
    this.processedAt,
    this.processedBy,
    this.rejectReason,
  });

  // Getter for isIncome
  bool get isIncome {
    return type == TransactionType.deposit ||
        type == TransactionType.refund ||
        type == TransactionType.reward;
  }

  // Getter alias for createdAt
  DateTime get createdDate => createdAt;

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      type: _parseTransactionType(json['type']),
      amount: (json['amount'] ?? 0).toDouble(),
      status: _parseTransactionStatus(json['status']),
      description: json['description'] as String?,
      referenceId:
          json['referenceId']?.toString() ?? json['reference_id']?.toString(),
      referenceType:
          json['referenceType'] as String? ?? json['reference_type'] as String?,
      proofImageUrl:
          json['proofImageUrl'] as String? ??
          json['proof_image_url'] as String?,
      createdAt:
          DateTime.tryParse(
            json['createdAt']?.toString() ??
                json['created_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      processedAt: json['processedAt'] != null
          ? DateTime.tryParse(json['processedAt'].toString())
          : json['processed_at'] != null
          ? DateTime.tryParse(json['processed_at'].toString())
          : null,
      processedBy:
          json['processedBy'] as String? ?? json['processed_by'] as String?,
      rejectReason:
          json['rejectReason'] as String? ?? json['reject_reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'type': type.name,
    'amount': amount,
    'status': status.name,
    'description': description,
    'referenceId': referenceId,
    'referenceType': referenceType,
    'proofImageUrl': proofImageUrl,
    'createdAt': createdAt.toIso8601String(),
    'processedAt': processedAt?.toIso8601String(),
    'processedBy': processedBy,
    'rejectReason': rejectReason,
  };

  static TransactionType _parseTransactionType(dynamic value) {
    if (value == null) return TransactionType.other;
    if (value is TransactionType) return value;
    final str = value.toString().toLowerCase();
    return TransactionType.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => TransactionType.other,
    );
  }

  static TransactionStatus _parseTransactionStatus(dynamic value) {
    if (value == null) return TransactionStatus.pending;
    if (value is TransactionStatus) return value;
    final str = value.toString().toLowerCase();
    return TransactionStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == str,
      orElse: () => TransactionStatus.pending,
    );
  }
}

// Alias for backward compatibility
typedef WalletTransaction = WalletTransactionModel;

class WalletSummary {
  final double balance;
  final double totalDeposit;
  final double totalWithdraw;
  final double totalSpent;
  final int pendingTransactions;

  const WalletSummary({
    required this.balance,
    this.totalDeposit = 0,
    this.totalWithdraw = 0,
    this.totalSpent = 0,
    this.pendingTransactions = 0,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      balance: (json['balance'] ?? 0).toDouble(),
      totalDeposit: (json['totalDeposit'] ?? json['total_deposit'] ?? 0)
          .toDouble(),
      totalWithdraw: (json['totalWithdraw'] ?? json['total_withdraw'] ?? 0)
          .toDouble(),
      totalSpent: (json['totalSpent'] ?? json['total_spent'] ?? 0).toDouble(),
      pendingTransactions:
          json['pendingTransactions'] as int? ??
          json['pending_transactions'] as int? ??
          0,
    );
  }

  Map<String, dynamic> toJson() => {
    'balance': balance,
    'totalDeposit': totalDeposit,
    'totalWithdraw': totalWithdraw,
    'totalSpent': totalSpent,
    'pendingTransactions': pendingTransactions,
  };
}

class DepositRequest {
  final double amount;
  final String? proofImageBase64;
  final String? note;

  const DepositRequest({
    required this.amount,
    this.proofImageBase64,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'proofImageBase64': proofImageBase64,
    'note': note,
  };
}

class WithdrawRequest {
  final double amount;
  final String? bankAccount;
  final String? bankName;
  final String? accountHolder;
  final String? note;

  const WithdrawRequest({
    required this.amount,
    this.bankAccount,
    this.bankName,
    this.accountHolder,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'bankAccount': bankAccount,
    'bankName': bankName,
    'accountHolder': accountHolder,
    'note': note,
  };
}
