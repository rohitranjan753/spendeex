import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:spendeex/data/models/payments_model.dart';

class PaymentsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new payment record
  Future<String> createPayment(PaymentsModel payment) async {
    try {
      final docRef = await _firestore.collection('payments').add(payment.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint("Error creating payment: $e");
      rethrow;
    }
  }

  // Get payments for a specific expense
  Future<List<PaymentsModel>> getPaymentsByExpense(String expenseId) async {
    try {
      final querySnapshot = await _firestore
          .collection('payments')
          .where('expenseId', isEqualTo: expenseId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return PaymentsModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching payments for expense $expenseId: $e");
      return [];
    }
  }

  // Get payments involving a specific user (both sent and received)
  Future<List<PaymentsModel>> getPaymentsByUser(String userId) async {
    try {
      // Get payments where user is the sender
      final sentPayments = await _firestore
          .collection('payments')
          .where('fromUser', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      // Get payments where user is the receiver
      final receivedPayments = await _firestore
          .collection('payments')
          .where('toUser', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      final allPayments = <PaymentsModel>[];
      
      // Add sent payments
      allPayments.addAll(sentPayments.docs.map((doc) {
        return PaymentsModel.fromMap(doc.data(), doc.id);
      }));

      // Add received payments
      allPayments.addAll(receivedPayments.docs.map((doc) {
        return PaymentsModel.fromMap(doc.data(), doc.id);
      }));

      // Sort by timestamp
      allPayments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allPayments;
    } catch (e) {
      debugPrint("Error fetching payments for user $userId: $e");
      return [];
    }
  }

  // Get pending payments for a user
  Future<List<PaymentsModel>> getPendingPaymentsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('payments')
          .where('fromUser', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return PaymentsModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching pending payments for user $userId: $e");
      return [];
    }
  }

  // Update payment status
  Future<void> updatePaymentStatus(String paymentId, String status) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'status': status,
      });
    } catch (e) {
      debugPrint("Error updating payment status: $e");
      rethrow;
    }
  }

  // Get payment by ID
  Future<PaymentsModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();
      if (doc.exists) {
        return PaymentsModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching payment $paymentId: $e");
      return null;
    }
  }

  // Delete payment
  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore.collection('payments').doc(paymentId).delete();
    } catch (e) {
      debugPrint("Error deleting payment $paymentId: $e");
      rethrow;
    }
  }

  // Get payments between two users
  Future<List<PaymentsModel>> getPaymentsBetweenUsers(
    String user1Id, 
    String user2Id
  ) async {
    try {
      // Get payments from user1 to user2
      final payments1to2 = await _firestore
          .collection('payments')
          .where('fromUser', isEqualTo: user1Id)
          .where('toUser', isEqualTo: user2Id)
          .get();

      // Get payments from user2 to user1
      final payments2to1 = await _firestore
          .collection('payments')
          .where('fromUser', isEqualTo: user2Id)
          .where('toUser', isEqualTo: user1Id)
          .get();

      final allPayments = <PaymentsModel>[];
      
      allPayments.addAll(payments1to2.docs.map((doc) {
        return PaymentsModel.fromMap(doc.data(), doc.id);
      }));

      allPayments.addAll(payments2to1.docs.map((doc) {
        return PaymentsModel.fromMap(doc.data(), doc.id);
      }));

      // Sort by timestamp
      allPayments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allPayments;
    } catch (e) {
      debugPrint("Error fetching payments between users: $e");
      return [];
    }
  }

  // Calculate net balance between two users
  Future<double> calculateNetBalance(String fromUserId, String toUserId) async {
    try {
      final payments = await getPaymentsBetweenUsers(fromUserId, toUserId);
      
      double netBalance = 0.0;
      
      for (final payment in payments) {
        if (payment.status == 'completed') {
          if (payment.fromUser == fromUserId) {
            netBalance += payment.amount; // fromUser paid toUser
          } else {
            netBalance -= payment.amount; // toUser paid fromUser
          }
        }
      }
      
      return netBalance;
    } catch (e) {
      debugPrint("Error calculating net balance: $e");
      return 0.0;
    }
  }

  // Get recent payments (last 30 days)
  Future<List<PaymentsModel>> getRecentPayments({int days = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final querySnapshot = await _firestore
          .collection('payments')
          .where('timestamp', isGreaterThan: cutoffDate)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        return PaymentsModel.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching recent payments: $e");
      return [];
    }
  }
}