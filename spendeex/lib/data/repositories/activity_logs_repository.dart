import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spendeex/data/models/activity_logs_model.dart';

class ActivityLogsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createActivityLog(ActivityLogsModel activityLog) async {
    try {
      await _firestore.collection('activity_logs').add(activityLog.toMap());
    } catch (e) {
      debugPrint("Error creating activity log: $e");
      rethrow;
    }
  }

  Future<List<ActivityLogsModel>> getActivityLogsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('activity_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ActivityLogsModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching activity logs for user $userId: $e");
      return [];
    }
  }

  Future<List<ActivityLogsModel>> getActivityLogsByGroup(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('activity_logs')
          .where('groupId', isEqualTo: groupId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ActivityLogsModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching activity logs for group $groupId: $e");
      return [];
    }
  }
}