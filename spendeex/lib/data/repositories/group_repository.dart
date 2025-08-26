import 'package:cloud_firestore/cloud_firestore.dart';

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
}
