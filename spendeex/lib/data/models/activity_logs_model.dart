import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ActivityLogsModel extends Equatable {
  final String id;
  final String userId;
  final String? groupId;
  final String action;
  final String details;
  final DateTime timestamp;

  const ActivityLogsModel({
    required this.id,
    required this.userId,
    this.groupId,
    required this.action,
    required this.details,
    required this.timestamp,
  });

  factory ActivityLogsModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ActivityLogsModel(
      id: documentId,
      userId: map['userId'] ?? '',
      groupId: map['groupId'],
      action: map['action'] ?? '',
      details: map['details'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'groupId': groupId,
      'action': action,
      'details': details,
      'timestamp': timestamp,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        groupId,
        action,
        details,
        timestamp,
      ];

  ActivityLogsModel copyWith({
    String? id,
    String? userId,
    String? groupId,
    String? action,
    String? details,
    DateTime? timestamp,
  }) {
    return ActivityLogsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      action: action ?? this.action,
      details: details ?? this.details,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Helper methods for common action types
  bool get isExpenseAction => action.contains('expense');
  bool get isPaymentAction => action.contains('payment');
  bool get isGroupAction => action.contains('group');
  bool get isUserAction => action.contains('user');

  // Helper method to format action display
  String get formattedAction {
    switch (action.toLowerCase()) {
      case 'create_expense':
        return 'Created Expense';
      case 'update_expense':
        return 'Updated Expense';
      case 'delete_expense':
        return 'Deleted Expense';
      case 'make_payment':
        return 'Made Payment';
      case 'receive_payment':
        return 'Received Payment';
      case 'create_group':
        return 'Created Group';
      case 'join_group':
        return 'Joined Group';
      case 'leave_group':
        return 'Left Group';
      case 'add_member':
        return 'Added Member';
      case 'remove_member':
        return 'Removed Member';
      case 'settle_balance':
        return 'Settled Balance';
      case 'login':
        return 'Logged In';
      case 'logout':
        return 'Logged Out';
      default:
        return action.replaceAll('_', ' ').split(' ')
            .map((word) => word.isNotEmpty 
                ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' 
                : '')
            .join(' ');
    }
  }

  // Helper method to check if activity is group-related
  bool get isGroupRelated => groupId != null;

  // Helper method to get activity icon based on action
  String get actionIcon {
    switch (action.toLowerCase()) {
      case 'create_expense':
      case 'update_expense':
        return '💰';
      case 'delete_expense':
        return '🗑️';
      case 'make_payment':
      case 'receive_payment':
        return '💳';
      case 'create_group':
        return '👥';
      case 'join_group':
        return '✅';
      case 'leave_group':
        return '👋';
      case 'add_member':
        return '➕';
      case 'remove_member':
        return '➖';
      case 'settle_balance':
        return '✔️';
      case 'login':
        return '🔓';
      case 'logout':
        return '🔒';
      default:
        return '📝';
    }
  }
}