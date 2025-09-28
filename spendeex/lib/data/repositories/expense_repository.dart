import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spendeex/data/models/expense_model.dart';
import 'package:spendeex/data/models/expense_participants_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createExpense(ExpenseModel expense) async {
    try {
      await _firestore.collection('expenses').add(expense.toMap());
    } catch (e) {
      debugPrint("Error creating expense: $e");
      rethrow;
    }
  }

  Future<void> createComplexExpense(ComplexExpenseModel expense) async {
    try {
      await _firestore.collection('complex_expenses').add(expense.toMap());
    } catch (e) {
      debugPrint("Error creating complex expense: $e");
      rethrow;
    }
  }

  Future<String> createExpenseWithParticipants(
    ExpenseModel expense,
    Map<String, double> splitAmounts,
  ) async {
    try {
      final expenseRef = await _firestore
          .collection('expenses')
          .add(expense.toMap());
      final expenseId = expenseRef.id;

      final batch = _firestore.batch();
      for (final entry in splitAmounts.entries) {
        final participantDoc =
            _firestore.collection('expense_participants').doc();
        final participant = ExpenseParticipantsModel(
          id: participantDoc.id,
          expenseId: expenseId,
          userId: entry.key,
          share: entry.value,
          settled: entry.key == expense.paidBy,
        );
        batch.set(participantDoc, participant.toMap());
      }

      await batch.commit();
      return expenseId;
    } catch (e) {
      debugPrint("Error creating expense with participants: $e");
      rethrow;
    }
  }

  Future<List<ExpenseParticipantsModel>> getExpenseParticipants(
    String expenseId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('expense_participants')
              .where('expenseId', isEqualTo: expenseId)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ExpenseParticipantsModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching expense participants for $expenseId: $e");
      return [];
    }
  }

  Future<List<ExpenseParticipantsModel>> getGroupExpenseParticipants(
    String groupId,
  ) async {
    try {
      final expensesSnapshot =
          await _firestore
              .collection('expenses')
              .where('groupId', isEqualTo: groupId)
              .get();

      final expenseIds = expensesSnapshot.docs.map((doc) => doc.id).toList();

      if (expenseIds.isEmpty) return [];

      final List<ExpenseParticipantsModel> allParticipants = [];

      for (int i = 0; i < expenseIds.length; i += 10) {
        final batch = expenseIds.skip(i).take(10).toList();
        final participantsSnapshot =
            await _firestore
                .collection('expense_participants')
                .where('expenseId', whereIn: batch)
                .get();

        final batchParticipants =
            participantsSnapshot.docs.map((doc) {
              final data = doc.data();
              return ExpenseParticipantsModel.fromMap(data, doc.id);
            }).toList();

        allParticipants.addAll(batchParticipants);
      }

      return allParticipants;
    } catch (e) {
      debugPrint(
        "Error fetching group expense participants for group $groupId: $e",
      );
      return [];
    }
  }

  Future<void> updateParticipantSettlement(
    String participantId,
    bool settled,
  ) async {
    try {
      await _firestore
          .collection('expense_participants')
          .doc(participantId)
          .update({'settled': settled});
    } catch (e) {
      debugPrint("Error updating participant settlement: $e");
      rethrow;
    }
  }

  Future<List<ExpenseModel>> getExpensesByGroup(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('expenses')
          .where('groupId', isEqualTo: groupId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ExpenseModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching expenses for group $groupId: $e");
      return [];
    }
  }

  Future<List<ComplexExpenseModel>> getComplexExpensesByGroup(
    String groupId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('complex_expenses')
              .where('groupId', isEqualTo: groupId)
              .orderBy('createdAt', descending: true)
              .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ComplexExpenseModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching complex expenses for group $groupId: $e");
      return [];
    }
  }

  Future<List<ExpenseModel>> getExpensesByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('expenses')
          .where('participants', arrayContains: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ExpenseModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching expenses for user $userId: $e");
      return [];
    }
  }

  Future<void> updateExpense(String expenseId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).update(updates);
    } catch (e) {
      debugPrint("Error updating expense $expenseId: $e");
      rethrow;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _firestore.collection('expenses').doc(expenseId).delete();
    } catch (e) {
      debugPrint("Error deleting expense $expenseId: $e");
      rethrow;
    }
  }

  Future<ExpenseModel?> getExpenseById(String expenseId) async {
    try {
      final doc = await _firestore.collection('expenses').doc(expenseId).get();
      if (doc.exists) {
        return ExpenseModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching expense $expenseId: $e");
      return null;
    }
  }
}