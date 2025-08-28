import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spendeex/data/models/group_model.dart';

class GroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> groupExists(String title) async {
    final existing = await _firestore
        .collection('groups')
        .where('title', isEqualTo: title)
        .get();
    return existing.docs.isNotEmpty;
  }

  Future<void> createGroup(Map<String, dynamic> groupData) async {
    await _firestore.collection('groups').add(groupData);
  }
Future<List<GroupModel>> getGroupsByUser(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('groups')
              .where('createdBy', isEqualTo: userId)
              .get();
      print("Fetched groups for user $userId: ${querySnapshot.docs.length}");
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return GroupModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching groups for user $userId: $e");
      return [];
    }
  }

}
