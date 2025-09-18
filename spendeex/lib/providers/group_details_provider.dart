import 'package:flutter/widgets.dart';
import 'package:spendeex/data/repositories/group_repository.dart';
import 'package:spendeex/data/repositories/expense_repository.dart';
import 'package:spendeex/data/repositories/activity_logs_repository.dart';
import 'package:spendeex/data/repositories/user_repository.dart';
import 'package:spendeex/data/models/group_model.dart';
import 'package:spendeex/data/models/group_members_model.dart';
import 'package:spendeex/data/models/expense_model.dart';
import 'package:spendeex/data/models/activity_logs_model.dart';

class GroupDetailsProvider with ChangeNotifier {
  final GroupRepository _groupRepo = GroupRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final ActivityLogsRepository _activityRepo = ActivityLogsRepository();
  final UserRepository _userRepo = UserRepository();

  GroupModel? _group;
  List<GroupMembersModel> _members = [];
  List<ExpenseModel> _expenses = [];
  List<ActivityLogsModel> _activityLogs = [];
  Map<String, double> _balances = {};
  bool _isLoading = false;
  String? _error;
  int _selectedMemberIndex = 0;

  // Cache for user names to avoid repeated API calls
  final Map<String, String> _userNameCache = {};

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

      // Preload user names for all members and expense participants
      await _preloadUserNames();

      // Calculate balances
      _calculateBalances();

    } catch (e) {
      _error = 'Failed to load group details: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Preload user names for better performance
  Future<void> _preloadUserNames() async {
    final userIds = <String>{};
    
    // Add all member user IDs
    for (final member in _members) {
      userIds.add(member.userId);
    }
    
    // Add all expense payer IDs
    for (final expense in _expenses) {
      userIds.add(expense.paidBy);
    }
    
    // Add all activity log user IDs
    for (final activity in _activityLogs) {
      userIds.add(activity.userId);
    }
    
    // Fetch all user names in parallel
    await Future.wait(userIds.map((userId) => _fetchAndCacheUserName(userId)));
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

  Future<String> getMemberName(String userId) async {
    // Check cache first to avoid repeated API calls
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId]!;
    }

    try {
      final userData = await _userRepo.getUserById(userId);
      if (userData != null) {
        final name = userData['name'] as String? ?? '';
        final email = userData['email'] as String? ?? '';
        
        // Use name if available, otherwise use email, otherwise use fallback
        String displayName;
        if (name.isNotEmpty) {
          displayName = name;
        } else if (email.isNotEmpty) {
          displayName = email.split('@')[0]; // Use email username part
        } else {
          displayName = 'User ${userId.substring(0, 6)}...'; // Fallback with short ID
        }
        
        // Cache the result
        _userNameCache[userId] = displayName;
        return displayName;
      }
    } catch (e) {
      debugPrint("Error fetching user name for $userId: $e");
    }
    
    // Fallback if user not found or error occurred
    final fallbackName = 'User ${userId.substring(0, 6)}...';
    _userNameCache[userId] = fallbackName;
    return fallbackName;
  }

  // Synchronous version for immediate display (uses cache or fallback)
  String getMemberNameSync(String userId) {
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId]!;
    }
    
    // Return fallback and trigger async fetch
    _fetchAndCacheUserName(userId);
    return 'Loading...';
  }

  // Helper method to fetch and cache user name in background
  Future<void> _fetchAndCacheUserName(String userId) async {
    if (_userNameCache.containsKey(userId)) return;
    
    try {
      final userData = await _userRepo.getUserById(userId);
      if (userData != null) {
        final name = userData['name'] as String? ?? '';
        final email = userData['email'] as String? ?? '';
        
        String displayName;
        if (name.isNotEmpty) {
          displayName = name;
        } else if (email.isNotEmpty) {
          displayName = email.split('@')[0];
        } else {
          displayName = 'User ${userId.substring(0, 6)}...';
        }
        
        _userNameCache[userId] = displayName;
        notifyListeners(); // Update UI when name is loaded
      }
    } catch (e) {
      debugPrint("Error fetching user name for $userId: $e");
      _userNameCache[userId] = 'User ${userId.substring(0, 6)}...';
    }
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
    _userNameCache.clear(); // Clear user name cache
    _error = null;
    _isLoading = false;
    _selectedMemberIndex = 0;
    notifyListeners();
  }
}