import 'package:flutter/widgets.dart';
import 'package:spendeex/core/auth_utils.dart';
import 'package:spendeex/data/repositories/group_repository.dart';
import 'package:spendeex/data/models/group_model.dart';

class GroupProvider with ChangeNotifier {
  final GroupRepository _groupRepo = GroupRepository();

  List<GroupModel> _userGroups = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<GroupModel> get userGroups => _userGroups;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasGroups => _userGroups.isNotEmpty;

  // Initialize and load user groups
  Future<void> loadUserGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUserId = AuthUtils.getCurrentUserId();
      if (currentUserId != null) {
        _userGroups = await _groupRepo.getGroupsByUser(currentUserId);
      } else {
        _userGroups = [];
        _error = 'User not authenticated';
      }
    } catch (e) {
      _error = 'Failed to load groups: $e';
      _userGroups = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh groups
  Future<void> refreshGroups() async {
    await loadUserGroups();
  }

  // Add a new group to the list (useful after creating a group)
  void addGroup(GroupModel group) {
    _userGroups.insert(0, group);
    notifyListeners();
  }

  // Clear data (useful for logout)
  void clear() {
    _userGroups.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}