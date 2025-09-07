import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PaymentsModel extends Equatable {
  final String id;
  final String expenseId;
  final String fromUser;
  final String toUser;
  final double amount;
  final String method;
  final String status;
  final DateTime timestamp;

  const PaymentsModel({
    required this.id,
    required this.expenseId,
    required this.fromUser,
    required this.toUser,
    required this.amount,
    required this.method,
    this.status = 'pending',
    required this.timestamp,
  });

  factory PaymentsModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PaymentsModel(
      id: documentId,
      expenseId: map['expenseId'] ?? '',
      fromUser: map['fromUser'] ?? '',
      toUser: map['toUser'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      method: map['method'] ?? '',
      status: map['status'] ?? 'pending',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'fromUser': fromUser,
      'toUser': toUser,
      'amount': amount,
      'method': method,
      'status': status,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [
        id,
        expenseId,
        fromUser,
        toUser,
        amount,
        method,
        status,
        timestamp,
      ];

  PaymentsModel copyWith({
    String? id,
    String? expenseId,
    String? fromUser,
    String? toUser,
    double? amount,
    String? method,
    String? status,
    DateTime? timestamp,
  }) {
    return PaymentsModel(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      fromUser: fromUser ?? this.fromUser,
      toUser: toUser ?? this.toUser,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Helper methods for common status checks
  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';

  // Helper method to format payment method display
  String get formattedMethod {
    switch (method.toLowerCase()) {
      case 'upi':
        return 'UPI';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'cash':
        return 'Cash';
      case 'credit_card':
        return 'Credit Card';
      case 'debit_card':
        return 'Debit Card';
      case 'wallet':
        return 'Digital Wallet';
      default:
        return method;
    }
  }
}