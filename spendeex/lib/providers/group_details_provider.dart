import 'package:flutter/widgets.dart';
import 'package:spendeex/data/repositories/group_repository.dart';
import 'package:spendeex/data/repositories/expense_repository.dart';
import 'package:spendeex/data/repositories/activity_logs_repository.dart';
import 'package:spendeex/data/models/group_model.dart';
import 'package:spendeex/data/models/group_members_model.dart';
import 'package:spendeex/data/models/expense_model.dart';
import 'package:spendeex/data/models/activity_logs_model.dart';

class GroupDetailsProvider with ChangeNotifier {
  final GroupRepository _groupRepo = GroupRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final ActivityLogsRepository _activityRepo = ActivityLogsRepository();

  GroupModel? _group;
  List<GroupMembersModel> _members = [];
  List<ExpenseModel> _expenses = [];
  List<ActivityLogsModel> _activityLogs = [];
  Map<String, double> _balances = {};
  bool _isLoading = false;
  String? _error;
  int _selectedMemberIndex = 0;

  // Getters
  GroupModel? get group => _group;
  List<GroupMembersModel> get members => _members;
  List<ExpenseModel> get expenses => _expenses;
  List<ActivityLogsModel> get activityLogs => _activityLogs;
  Map<String, double> get balances => _balances;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedMemberIndex => _selectedMemberIndex;

  // Filtered expenses based on selected member
  List<ExpenseModel> get filteredExpenses {
    if (_selectedMemberIndex == 0) {
      return _expenses; // Show all expenses
    }
    if (_selectedMemberIndex - 1 < _members.length) {
      final selectedMember = _members[_selectedMemberIndex - 1];
      return _expenses.where((expense) => 
        expense.paidBy == selectedMember.userId).toList();
    }
    return _expenses;
  }

  void setSelectedMember(int index) {
    _selectedMemberIndex = index;
    notifyListeners();
  }

  Future<void> loadGroupDetails(String groupId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load group information
      _group = await _groupRepo.getGroupById(groupId);
      if (_group == null) {
        _error = 'Group not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load group members
      _members = await _groupRepo.getGroupMembers(groupId);

      // Load group expenses
      _expenses = await _expenseRepo.getExpensesByGroup(groupId);

      // Load activity logs
      _activityLogs = await _activityRepo.getActivityLogsByGroup(groupId);

      // Calculate balances
      _calculateBalances();

    } catch (e) {
      _error = 'Failed to load group details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateBalances() {
    _balances.clear();
    
    // Initialize balances for all members
    for (final member in _members) {
      _balances[member.userId] = 0.0;
    }

    // Calculate balances based on expenses
    for (final expense in _expenses) {
      final paidBy = expense.paidBy;
      final amount = expense.amount;
      final participantCount = _members.length;
      final sharePerPerson = amount / participantCount;

      // The person who paid gets credit
      _balances[paidBy] = (_balances[paidBy] ?? 0.0) + amount;

      // Everyone owes their share
      for (final member in _members) {
        _balances[member.userId] = (_balances[member.userId] ?? 0.0) - sharePerPerson;
      }
    }
  }

  double getTotalExpenses() {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getUserBalance(String userId) {
    return _balances[userId] ?? 0.0;
  }

  String getMemberName(String userId) {
    // This is a simplified version - in a real app, you'd fetch user names
    final memberIndex = _members.indexWhere((m) => m.userId == userId);
    if (memberIndex != -1) {
      return 'Member ${memberIndex + 1}';
    }
    return 'Unknown User';
  }

  Future<void> refreshData() async {
    if (_group != null) {
      await loadGroupDetails(_group!.id);
    }
  }

  void clear() {
    _group = null;
    _members.clear();
    _expenses.clear();
    _activityLogs.clear();
    _balances.clear();
    _error = null;
    _isLoading = false;
    _selectedMemberIndex = 0;
    notifyListeners();
  }
}