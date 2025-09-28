import 'package:flutter/widgets.dart';
import 'package:spendeex/core/auth_utils.dart';
import 'package:spendeex/data/models/expense_model.dart';
import 'package:spendeex/data/models/group_model.dart';
import 'package:spendeex/data/repositories/expense_repository.dart';
import 'package:spendeex/data/repositories/group_repository.dart';
import 'package:spendeex/data/repositories/activity_logs_repository.dart';
import 'package:spendeex/data/repositories/user_repository.dart';
import 'package:spendeex/data/models/activity_logs_model.dart';

class AddExpenseProvider with ChangeNotifier {
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final GroupRepository _groupRepo = GroupRepository();
  final ActivityLogsRepository _activityRepo = ActivityLogsRepository();
  final UserRepository _userRepo = UserRepository();

  // Form state
  String _title = '';
  String _description = '';
  String _category = '';
  GroupModel? _selectedGroup;
  List<GroupModel> _userGroups = [];
  List<ExpenseModel> _items = [];
  List<String> _selectedParticipants = [];
  String _selectedSplitType = 'Equally';
  String _paidBy = '';
  bool _isLoading = false;

  // Cache for user names to avoid repeated API calls
  final Map<String, String> _userNameCache = {};

  // Getters
  String get title => _title;
  String get description => _description;
  String get category => _category;
  GroupModel? get selectedGroup => _selectedGroup;
  List<GroupModel> get userGroups => _userGroups;
  List<ExpenseModel> get items => _items;
  List<String> get selectedParticipants => _selectedParticipants;
  String get selectedSplitType => _selectedSplitType;
  String get paidBy => _paidBy;
  bool get isLoading => _isLoading;

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.amount);

  // Initialize provider and load user groups
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final userId = AuthUtils.getCurrentUserId();
    if (userId != null) {
      _userGroups = await _groupRepo.getGroupsByUser(userId);
      _paidBy = userId;
    }

    // Initialize with one empty expense item
    _items = [_createEmptyExpenseModel()];

    _isLoading = false;
    notifyListeners();
  }

  ExpenseModel _createEmptyExpenseModel() {
    return ExpenseModel(
      id: '',
      groupId: _selectedGroup?.id ?? '',
      title: '',
      amount: 0.0,
      paidBy: _paidBy,
      category: _category,
      date: DateTime.now(),
      recurring: false,
      notes: _description,
      imageUrl: null,
    );
  }

  void updateTitle(String value) {
    _title = value.trim();
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value.trim();
    notifyListeners();
  }

  void updateCategory(String value) {
    _category = value.trim();
    // Update existing items with new category
    _items = _items.map((item) => item.copyWith(category: _category)).toList();
    notifyListeners();
  }

  void selectGroup(GroupModel group) {
    _selectedGroup = group;
    // Remove duplicates and initialize selected participants with all unique group members
    final uniqueParticipants = group.participants.toSet().toList();
    _selectedParticipants = List.from(uniqueParticipants);
    // Update existing items with new groupId
    _items = _items.map((item) => item.copyWith(groupId: group.id)).toList();
    notifyListeners();
  }

  void addExpenseItem() {
    _items.add(_createEmptyExpenseModel());
    notifyListeners();
  }

  void addExpense() {
    _items.add(_createEmptyExpenseModel());
    notifyListeners();
  }

  void removeExpenseItem(int index) {
    if (_items.length > 1) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void removeExpense(int index) {
    if (_items.length > 1) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  void updateExpense(
    int index,
    String name,
    double amount, {
    String? imageUrl,
  }) {
    if (index < _items.length) {
      _items[index] = _items[index].copyWith(
        title: name,
        amount: amount,
        imageUrl: imageUrl,
        paidBy: _paidBy,
        groupId: _selectedGroup?.id ?? '',
        category: _category,
        notes: _description,
      );
      notifyListeners();
    }
  }

  void toggleParticipant(String participantId) {
    if (_selectedParticipants.contains(participantId)) {
      _selectedParticipants.remove(participantId);
    } else {
      _selectedParticipants.add(participantId);
    }
    notifyListeners();
  }

  void setSplitType(String splitType) {
    _selectedSplitType = splitType;
    notifyListeners();
  }

  void setPaidBy(String userId) {
    _paidBy = userId;
    // Update all items with new paidBy
    _items = _items.map((item) => item.copyWith(paidBy: userId)).toList();
    notifyListeners();
  }

  Future<String?> saveExpense() async {
    if (_title.isEmpty) {
      return 'Please enter an expense title';
    }

    if (_selectedGroup == null) {
      return 'Please select a group';
    }

    if (_selectedParticipants.isEmpty) {
      return 'Please select at least one participant';
    }

    if (_items.isEmpty ||
        _items.every((item) => item.title.isEmpty || item.amount <= 0)) {
      return 'Please add at least one valid expense item';
    }

    if (_paidBy.isEmpty) {
      return 'Please select who paid for this expense';
    }

    if (_category.isEmpty) {
      return 'Please select a category';
    }

    _isLoading = true;
    notifyListeners();

    try {
      final currentUserId = AuthUtils.getCurrentUserId();
      if (currentUserId == null) {
        _isLoading = false;
        notifyListeners();
        return 'User not authenticated';
      }

      // Create expense entries for each item
      for (final item in _items) {
        if (item.title.isNotEmpty && item.amount > 0) {
          final expense = item.copyWith(
            title: item.title,
            amount: item.amount,
            paidBy: _paidBy,
            groupId: _selectedGroup!.id,
            category: _category,
            date: DateTime.now(),
            notes: _description,
          );

          // Calculate split amounts for this specific item
          final itemSplitAmounts = <String, double>{};
          final amountPerPerson = item.amount / _selectedParticipants.length;
          
          for (final participant in _selectedParticipants) {
            itemSplitAmounts[participant] = amountPerPerson;
          }

          // Create expense with participants using ExpenseParticipantsModel
          await _expenseRepo.createExpenseWithParticipants(expense, itemSplitAmounts);

          // Log activity for each expense item
          await _activityRepo.createActivityLog(ActivityLogsModel(
            id: '',
            userId: currentUserId,
            groupId: _selectedGroup!.id,
            action: 'create_expense',
              details:
                  'Added expense "${item.title}" of ₹${item.amount.toStringAsFixed(2)} split among ${_selectedParticipants.length} participants',
            timestamp: DateTime.now(),
          ));
        }
      }

      // Log overall expense activity if multiple items
      if (_items.length > 1) {
        await _activityRepo.createActivityLog(
          ActivityLogsModel(
            id: '',
            userId: currentUserId,
            groupId: _selectedGroup!.id,
            action: 'create_expense',
            details:
                'Created expense group "$_title" with total amount ₹${totalAmount.toStringAsFixed(2)} split among ${_selectedParticipants.length} participants',
            timestamp: DateTime.now(),
          ),
        );
      }

      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Failed to save expense: $e';
    }
  }

  // Get user name with caching
  String getUserNameSync(String userId) {
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

  void reset() {
    _title = '';
    _description = '';
    _category = '';
    _selectedGroup = null;
    _items = [_createEmptyExpenseModel()];
    _selectedParticipants = [];
    _selectedSplitType = 'Equally';
    _paidBy = AuthUtils.getCurrentUserId() ?? '';
    notifyListeners();
  }
}