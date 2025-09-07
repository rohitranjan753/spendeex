import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spendeex/data/models/expense_model.dart';

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

  Future<List<ExpenseModel>> getExpensesByGroup(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('expenses')
          .where('groupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: true)
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