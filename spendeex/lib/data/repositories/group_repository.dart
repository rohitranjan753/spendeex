import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spendeex/data/models/group_model.dart';
import 'package:spendeex/data/models/group_members_model.dart';

class GroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> groupExists(String title) async {
    final existing = await _firestore
        .collection('groups')
        .where('title', isEqualTo: title)
        .get();
    return existing.docs.isNotEmpty;
  }

  Future<String> createGroup(GroupModel group) async {
    try {
      final docRef = await _firestore.collection('groups').add(group.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint("Error creating group: $e");
      rethrow;
    }
  }

  Future<void> addGroupMember(GroupMembersModel member) async {
    try {
      await _firestore.collection('group_members').add(member.toMap());
    } catch (e) {
      debugPrint("Error adding group member: $e");
      rethrow;
    }
  }

  Future<void> addMultipleGroupMembers(List<GroupMembersModel> members) async {
    try {
      final batch = _firestore.batch();
      
      for (final member in members) {
        final docRef = _firestore.collection('group_members').doc();
        batch.set(docRef, member.toMap());
      }
      
      await batch.commit();
    } catch (e) {
      debugPrint("Error adding multiple group members: $e");
      rethrow;
    }
  }

  Future<List<GroupModel>> getGroupsByUser(String userId) async {
    try {
      // Get groups where user is a member
      final memberQuery = await _firestore
          .collection('group_members')
          .where('userId', isEqualTo: userId)
          .get();
      
      if (memberQuery.docs.isEmpty) {
        return [];
      }
      
      final groupIds = memberQuery.docs
          .map((doc) => doc.data()['groupId'] as String)
          .toList();
      
      final List<GroupModel> groups = [];
      
      // Firestore 'in' query limitation of 10 items
      for (int i = 0; i < groupIds.length; i += 10) {
        final batch = groupIds.skip(i).take(10).toList();
        final querySnapshot = await _firestore
            .collection('groups')
            .where(FieldPath.documentId, whereIn: batch)
            .orderBy('createdAt', descending: true)
            .get();
        
        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          
          // Get member count for this group
          final membersQuery =
              await _firestore
                  .collection('group_members')
                  .where('groupId', isEqualTo: doc.id)
                  .get();

          final memberIds =
              membersQuery.docs
                  .map((memberDoc) => memberDoc.data()['userId'] as String)
                  .toList();

          // Create group model with populated participants
          final group = GroupModel(
            id: doc.id,
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            category: data['category'] ?? '',
            createdBy: data['createdBy'] ?? '',
            createdAt: (data['createdAt'] as Timestamp).toDate(),
            participants: memberIds, // Populate with actual member IDs
          );

          groups.add(group);
        }
      }
      
      return groups;
    } catch (e) {
      debugPrint("Error fetching groups for user $userId: $e");
      return [];
    }
  }

  Future<List<GroupMembersModel>> getGroupMembers(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('group_members')
          .where('groupId', isEqualTo: groupId)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return GroupMembersModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      debugPrint("Error fetching group members for group $groupId: $e");
      return [];
    }
  }

  Future<void> removeGroupMember(String groupId, String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('group_members')
          .where('groupId', isEqualTo: groupId)
          .where('userId', isEqualTo: userId)
          .get();
      
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint("Error removing group member: $e");
      rethrow;
    }
  }

  Future<GroupModel?> getGroupById(String groupId) async {
    try {
      final doc = await _firestore.collection('groups').doc(groupId).get();
      if (doc.exists) {
        return GroupModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching group $groupId: $e");
      return null;
    }
  }
}
