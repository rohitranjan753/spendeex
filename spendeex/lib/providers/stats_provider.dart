import 'package:flutter/foundation.dart';
import 'package:spendeex/core/auth_utils.dart';
import 'package:spendeex/data/repositories/expense_repository.dart';
import 'package:spendeex/data/repositories/group_repository.dart';
import 'package:spendeex/data/models/expense_model.dart';
import 'package:spendeex/data/models/expense_participants_model.dart';
import 'package:spendeex/data/models/group_model.dart';
import 'package:spendeex/data/models/group_members_model.dart';

class StatsProvider with ChangeNotifier {
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final GroupRepository _groupRepo = GroupRepository();

  // State variables
  List<ExpenseModel> _allExpenses = [];
  List<ComplexExpenseModel> _complexExpenses = [];
  List<ExpenseParticipantsModel> _allParticipants = [];
  List<GroupModel> _userGroups = [];
  Map<String, List<GroupMembersModel>> _groupMembers = {};
  
  bool _isLoading = false;
  String? _error;
  String _selectedCategory = 'All';
  DateTime _selectedMonth = DateTime.now();

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  DateTime get selectedMonth => _selectedMonth;
  List<String> get availableCategories => _getAvailableCategories();

  // Initialize and load all stats data
  Future<void> loadStatsData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUserId = AuthUtils.getCurrentUserId();
      if (currentUserId == null) {
        _error = 'User not authenticated';
        return;
      }

      // Load user's groups
      _userGroups = await _groupRepo.getGroupsByUser(currentUserId);

      // Load expenses and participants for all user groups
      for (final group in _userGroups) {
        final groupExpenses = await _expenseRepo.getExpensesByGroup(group.id);
        final complexExpenses = await _expenseRepo.getComplexExpensesByGroup(group.id);
        final participants = await _expenseRepo.getGroupExpenseParticipants(group.id);
        final members = await _groupRepo.getGroupMembers(group.id);

        _allExpenses.addAll(groupExpenses);
        _complexExpenses.addAll(complexExpenses);
        _allParticipants.addAll(participants);
        _groupMembers[group.id] = members;
      }

      // Also load expenses where user is directly involved
      final userExpenses = await _expenseRepo.getExpensesByUser(currentUserId);
      _allExpenses.addAll(userExpenses);

      // Remove duplicates
      _allExpenses = _allExpenses.toSet().toList();
      _complexExpenses = _complexExpenses.toSet().toList();
      _allParticipants = _allParticipants.toSet().toList();

    } catch (e) {
      _error = 'Failed to load statistics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get total spending for current month
  double getTotalSpending() {
    final currentUserId = AuthUtils.getCurrentUserId();
    if (currentUserId == null) return 0.0;

    final filteredExpenses = _getFilteredExpenses();
    
    // Calculate from simple expenses where user paid
    final simpleTotal = filteredExpenses
        .where((expense) => expense.paidBy == currentUserId)
        .fold(0.0, (sum, expense) => sum + expense.amount);

    // Calculate from complex expenses where user paid
    final complexTotal = _complexExpenses
        .where((expense) => 
            expense.paidBy == currentUserId && 
            _isInSelectedMonth(expense.createdAt) &&
            (_selectedCategory == 'All' || 
             expense.items.any((item) => item.category == _selectedCategory)))
        .fold(0.0, (sum, expense) => sum + expense.totalAmount);

    return simpleTotal + complexTotal;
  }

  // Get pending payments (amount user needs to pay to others)
  double getPendingPayments() {
    final currentUserId = AuthUtils.getCurrentUserId();
    if (currentUserId == null) return 0.0;

    double pending = 0.0;

    // Calculate from expense participants where user owes money
    final filteredParticipants = _allParticipants
        .where((participant) => 
            participant.userId == currentUserId && 
            !participant.settled)
        .toList();

    for (final participant in filteredParticipants) {
      final expense = _allExpenses.firstWhere(
        (exp) => exp.id == participant.expenseId,
        orElse: () => ExpenseModel(
          id: '', groupId: '', title: '', amount: 0.0, 
          paidBy: '', category: '', date: DateTime.now()
        ),
      );

      if (expense.id.isNotEmpty && 
          expense.paidBy != currentUserId &&
          _isInSelectedMonth(expense.date) &&
          (_selectedCategory == 'All' || expense.category == _selectedCategory)) {
        pending += participant.share;
      }
    }

    return pending;
  }

  // Get amount others owe to user
  double getOwedAmount() {
    final currentUserId = AuthUtils.getCurrentUserId();
    if (currentUserId == null) return 0.0;

    double owed = 0.0;

    // Find expenses paid by current user
    final expensesPaidByUser = _getFilteredExpenses()
        .where((expense) => expense.paidBy == currentUserId)
        .toList();

    for (final expense in expensesPaidByUser) {
      // Find participants for this expense (excluding the payer)
      final expenseParticipants = _allParticipants
          .where((participant) => 
              participant.expenseId == expense.id && 
              participant.userId != currentUserId &&
              !participant.settled)
          .toList();

      for (final participant in expenseParticipants) {
        owed += participant.share;
      }
    }

    return owed;
  }

  // Get settled amount for current month
  double getSettledAmount() {
    final currentUserId = AuthUtils.getCurrentUserId();
    if (currentUserId == null) return 0.0;

    double settled = 0.0;

    // Calculate settled amounts where user was involved
    final settledParticipants = _allParticipants
        .where((participant) => 
            participant.userId == currentUserId && 
            participant.settled)
        .toList();

    for (final participant in settledParticipants) {
      final expense = _allExpenses.firstWhere(
        (exp) => exp.id == participant.expenseId,
        orElse: () => ExpenseModel(
          id: '', groupId: '', title: '', amount: 0.0, 
          paidBy: '', category: '', date: DateTime.now()
        ),
      );

      if (expense.id.isNotEmpty && 
          _isInSelectedMonth(expense.date) &&
          (_selectedCategory == 'All' || expense.category == _selectedCategory)) {
        settled += participant.share;
      }
    }

    return settled;
  }

  // Get spending data for graph (last 6 months)
  List<Map<String, dynamic>> getSpendingGraphData() {
    final currentUserId = AuthUtils.getCurrentUserId();
    if (currentUserId == null) return [];

    final List<Map<String, dynamic>> graphData = [];
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      final monthlyExpenses = _allExpenses
          .where((expense) => 
              expense.paidBy == currentUserId &&
              expense.date.isAfter(month) && 
              expense.date.isBefore(nextMonth) &&
              (_selectedCategory == 'All' || expense.category == _selectedCategory))
          .toList();

      final monthlyComplex = _complexExpenses
          .where((expense) => 
              expense.paidBy == currentUserId &&
              expense.createdAt.isAfter(month) && 
              expense.createdAt.isBefore(nextMonth) &&
              (_selectedCategory == 'All' || 
               expense.items.any((item) => item.category == _selectedCategory)))
          .toList();

      final simpleTotal = monthlyExpenses.fold(0.0, (sum, exp) => sum + exp.amount);
      final complexTotal = monthlyComplex.fold(0.0, (sum, exp) => sum + exp.totalAmount);
      final total = simpleTotal + complexTotal;

      graphData.add({
        'month': month.month.toDouble(),
        'amount': total,
        'monthName': _getMonthName(month.month),
      });
    }

    return graphData;
  }

  // Get category-wise breakdown
  Map<String, double> getCategoryBreakdown() {
    final currentUserId = AuthUtils.getCurrentUserId();
    if (currentUserId == null) return {};

    final Map<String, double> categoryData = {};
    final filteredExpenses = _getFilteredExpenses()
        .where((expense) => expense.paidBy == currentUserId)
        .toList();

    for (final expense in filteredExpenses) {
      categoryData[expense.category] = 
          (categoryData[expense.category] ?? 0.0) + expense.amount;
    }

    // Add complex expenses
    final filteredComplex = _complexExpenses
        .where((expense) => 
            expense.paidBy == currentUserId && 
            _isInSelectedMonth(expense.createdAt))
        .toList();

    for (final expense in filteredComplex) {
      for (final item in expense.items) {
        categoryData[item.category] = 
            (categoryData[item.category] ?? 0.0) + item.amount;
      }
    }

    return categoryData;
  }

  // Helper methods
  List<ExpenseModel> _getFilteredExpenses() {
    return _allExpenses
        .where((expense) => 
            _isInSelectedMonth(expense.date) &&
            (_selectedCategory == 'All' || expense.category == _selectedCategory))
        .toList();
  }

  bool _isInSelectedMonth(DateTime date) {
    return date.year == _selectedMonth.year && 
           date.month == _selectedMonth.month;
  }

  List<String> _getAvailableCategories() {
    final categories = <String>{'All'};
    
    for (final expense in _allExpenses) {
      categories.add(expense.category);
    }
    
    for (final complexExpense in _complexExpenses) {
      for (final item in complexExpense.items) {
        categories.add(item.category);
      }
    }
    
    return categories.toList()..sort();
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  // Setters
  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  void refresh() {
    loadStatsData();
  }

  void clear() {
    _allExpenses.clear();
    _complexExpenses.clear();
    _allParticipants.clear();
    _userGroups.clear();
    _groupMembers.clear();
    _error = null;
    _isLoading = false;
    _selectedCategory = 'All';
    _selectedMonth = DateTime.now();
    notifyListeners();
  }
}