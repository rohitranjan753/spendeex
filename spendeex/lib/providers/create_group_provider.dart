import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:spendeex/core/auth_utils.dart';
import 'package:spendeex/data/repositories/group_repository.dart';

class CreateGroupProvider with ChangeNotifier {
  final GroupRepository _groupRepo = GroupRepository();

  String title = '';
  String description = '';
  String category = '';

  void updateGroupDetails(String t, String d) {
    title = t.trim();
    description = d.trim();
  }

  void updateCatgeory(String c) {
    category = c.trim();
  }

  Future<String?> createGroup() async {
    if (title.isEmpty || category.isEmpty) {
      return 'Title and category are required.';
    }

    final exists = await _groupRepo.groupExists(title);
    if (exists) return 'Group with same name already exists.';

    await _groupRepo.createGroup({
      'title': title,
      'description': description,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': AuthUtils.getCurrentUserId(),
    });

    return null;
  }
}
