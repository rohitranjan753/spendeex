import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:spendeex/data/models/notifications_model.dart';

class NotificationsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new notification
  Future<String> createNotification(NotificationsModel notification) async {
    try {
      final docRef = await _firestore.collection('notifications').add(notification.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint("Error creating notification: $e");
      rethrow;
    }
  }

  /// Get notifications for a specific user
  Future<List<NotificationsModel>> getNotificationsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        return NotificationsModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching notifications for user $userId: $e");
      return [];
    }
  }

  /// Get unread notifications for a specific user
  Future<List<NotificationsModel>> getUnreadNotificationsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return NotificationsModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching unread notifications for user $userId: $e");
      return [];
    }
  }

  /// Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
      rethrow;
    }
  }

  /// Mark all notifications as read for a user
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error marking all notifications as read: $e");
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      debugPrint("Error deleting notification: $e");
      rethrow;
    }
  }

  /// Send payment request notification
  Future<void> sendPaymentRequestNotification({
    required String toUserId,
    required String fromUserName,
    required double amount,
    required String reason,
  }) async {
    try {
      final notification = NotificationsModel(
        id: '',
        userId: toUserId,
        type: 'payment_request',
        message: '$fromUserName has requested ₹${amount.toStringAsFixed(2)} for $reason',
        read: false,
        timestamp: DateTime.now(),
      );

      await createNotification(notification);
    } catch (e) {
      debugPrint("Error sending payment request notification: $e");
      rethrow;
    }
  }

  /// Send reminder notification for outstanding debt
  Future<void> sendDebtReminderNotification({
    required String toUserId,
    required String fromUserName,
    required double amount,
    String? expenseName,
  }) async {
    try {
      final message = expenseName != null 
          ? '$fromUserName reminded you about ₹${amount.toStringAsFixed(2)} owed for "$expenseName"'
          : '$fromUserName reminded you about ₹${amount.toStringAsFixed(2)} you owe them';

      final notification = NotificationsModel(
        id: '',
        userId: toUserId,
        type: 'reminder',
        message: message,
        read: false,
        timestamp: DateTime.now(),
      );

      await createNotification(notification);
    } catch (e) {
      debugPrint("Error sending debt reminder notification: $e");
      rethrow;
    }
  }
}