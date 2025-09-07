import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NotificationsModel extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String message;
  final bool read;
  final DateTime timestamp;

  const NotificationsModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    this.read = false,
    required this.timestamp,
  });

  factory NotificationsModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NotificationsModel(
      id: documentId,
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      message: map['message'] ?? '',
      read: map['read'] ?? false,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type,
      'message': message,
      'read': read,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        message,
        read,
        timestamp,
      ];

  NotificationsModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? message,
    bool? read,
    DateTime? timestamp,
  }) {
    return NotificationsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      message: message ?? this.message,
      read: read ?? this.read,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Helper methods for common notification types
  bool get isExpenseNotification => type == 'expense';
  bool get isPaymentNotification => type == 'payment';
  bool get isGroupNotification => type == 'group';
  bool get isReminderNotification => type == 'reminder';
  bool get isUnread => !read;

  // Helper method to mark as read
  NotificationsModel markAsRead() {
    return copyWith(read: true);
  }

  // Helper method to format notification type display
  String get formattedType {
    switch (type.toLowerCase()) {
      case 'expense':
        return 'Expense';
      case 'payment':
        return 'Payment';
      case 'group':
        return 'Group';
      case 'reminder':
        return 'Reminder';
      case 'settlement':
        return 'Settlement';
      case 'invite':
        return 'Invitation';
      default:
        return type;
    }
  }
}