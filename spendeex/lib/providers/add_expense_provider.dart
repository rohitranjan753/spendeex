import 'package:flutter/widgets.dart';
import 'package:spendeex/core/auth_utils.dart';
import 'package:spendeex/data/models/expense_model.dart';
import 'package:spendeex/data/models/group_model.dart';
import 'package:spendeex/data/repositories/expense_repository.dart';
import 'package:spendeex/data/repositories/group_repository.dart';

class AddExpenseProvider with ChangeNotifier {
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final GroupRepository _groupRepo = GroupRepository();

  // Form state
  String _title = '';
  String _description = '';
  GroupModel? _selectedGroup;
  List<GroupModel> _userGroups = [];
  List<ExpenseModel> _items = []; // Using ExpenseModel instead of ExpenseItem
  List<String> _selectedParticipants = [];
  String _selectedSplitType = 'equally';
  String _paidBy = '';
  bool _isLoading = false;

  // Getters
  String get title => _title;
  String get description => _description;
  GroupModel? get selectedGroup => _selectedGroup;
  List<GroupModel> get userGroups => _userGroups;
  List<ExpenseModel> get items => _items; // Return ExpenseModel list
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
      _paidBy = userId; // Default to current user
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
      category: '',
      date: DateTime.now(),
      recurring: false,
      notes: '',
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

  void selectGroup(GroupModel group) {
    _selectedGroup = group;
    _selectedParticipants = List.from(group.participants);
    // Update existing items with new groupId
    _items = _items.map((item) => item.copyWith(groupId: group.id)).toList();
    notifyListeners();
  }

  void addExpense() {
    _items.add(_createEmptyExpenseModel());
    notifyListeners();
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

  Map<String, double> _calculateSplitAmounts() {
    final Map<String, double> splitAmounts = {};
    
    switch (_selectedSplitType) {
      case 'equally':
        final amountPerPerson = totalAmount / _selectedParticipants.length;
        for (final participant in _selectedParticipants) {
          splitAmounts[participant] = amountPerPerson;
        }
        break;
      case 'unequally':
      case 'percentage':
      case 'shares':
      case 'adjustment':
        // For now, default to equal split
        // These can be implemented later with custom UI
        final amountPerPerson = totalAmount / _selectedParticipants.length;
        for (final participant in _selectedParticipants) {
          splitAmounts[participant] = amountPerPerson;
        }
        break;
    }
    
    return splitAmounts;
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

    _isLoading = true;
    notifyListeners();

    try {
      // For complex expenses, we'll use the ComplexExpenseModel
      // Use ExpenseModel items directly (no conversion needed)
      final expenseItems =
          _items
              .where((item) => item.title.isNotEmpty && item.amount > 0)
              .toList();

      final complexExpense = ComplexExpenseModel(
        id: '', // Will be generated by Firestore
        title: _title,
        description: _description,
        groupId: _selectedGroup!.id,
        paidBy: _paidBy,
        totalAmount: totalAmount,
        items: expenseItems, // Now using ExpenseModel directly
        participants: _selectedParticipants,
        splitAmounts: _calculateSplitAmounts(),
        splitType: _selectedSplitType,
        createdAt: DateTime.now(),
        createdBy: AuthUtils.getCurrentUserId() ?? '',
      );

      await _expenseRepo.createComplexExpense(complexExpense);
      
      _isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return 'Failed to save expense: $e';
    }
  }

  void reset() {
    _title = '';
    _description = '';
    _selectedGroup = null;
    _items = [_createEmptyExpenseModel()];
    _selectedParticipants = [];
    _selectedSplitType = 'equally';
    _paidBy = AuthUtils.getCurrentUserId() ?? '';
    notifyListeners();
  }
}