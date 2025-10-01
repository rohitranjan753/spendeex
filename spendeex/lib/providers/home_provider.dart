import 'package:flutter/foundation.dart';
import 'package:spendeex/core/auth_utils.dart';
import 'package:spendeex/data/repositories/expense_repository.dart';
import 'package:spendeex/data/repositories/group_repository.dart';
import 'package:spendeex/data/repositories/activity_logs_repository.dart';
import 'package:spendeex/data/repositories/payments_repository.dart';
import 'package:spendeex/data/repositories/user_repository.dart';
import 'package:spendeex/data/models/expense_model.dart';
import 'package:spendeex/data/models/expense_participants_model.dart';
import 'package:spendeex/data/models/group_model.dart';
import 'package:spendeex/data/models/activity_logs_model.dart';
import 'package:spendeex/data/models/payments_model.dart';

class HomeProvider with ChangeNotifier {
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final GroupRepository _groupRepo = GroupRepository();
  final ActivityLogsRepository _activityRepo = ActivityLogsRepository();
  final PaymentsRepository _paymentsRepo = PaymentsRepository();
  final UserRepository _userRepo = UserRepository();

  // State variables
  List<ExpenseModel> _recentExpenses = [];
  List<ComplexExpenseModel> _recentComplexExpenses = [];
  List<ExpenseParticipantsModel> _allParticipants = [];
  List<ActivityLogsModel> _recentActivities = [];
  List<PaymentsModel> _recentPayments = [];
  List<GroupModel> _userGroups = [];
  
  double _totalBalance = 0.0;
  double _pendingPayments = 0.0;
  double _receivables = 0.0;
  double _monthlySpending = 0.0;
  
  bool _isLoading = false;
  String? _error;
  
  // Cache for user names
  final Map<String, String> _userNameCache = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalBalance => _totalBalance;
  double get pendingPayments => _pendingPayments;
  double get receivables => _receivables;
  double get monthlySpending => _monthlySpending;
  List<ActivityLogsModel> get recentActivities => _recentActivities;
  List<ExpenseModel> get recentExpenses => _recentExpenses;
  List<GroupModel> get userGroups => _userGroups;

  // Initialize and load dashboard data
  Future<void> loadDashboardData() async {
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

      // Load recent expenses (last 30 days)
      await _loadRecentExpenses(currentUserId);

      // Load recent activities (last 15 activities)
      await _loadRecentActivities(currentUserId);

      // Load recent payments
      _recentPayments = await _paymentsRepo.getPaymentsByUser(currentUserId);

      // Calculate balances
      await _calculateBalances(currentUserId);

      // Calculate monthly spending
      _calculateMonthlySpending(currentUserId);

    } catch (e) {
      _error = 'Failed to load dashboard data: $e';
      debugPrint("HomeProvider error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load recent expenses from all user groups
  Future<void> _loadRecentExpenses(String userId) async {
    _recentExpenses.clear();
    _recentComplexExpenses.clear();
    _allParticipants.clear();

    // Get expenses from all user groups
    for (final group in _userGroups) {
      final groupExpenses = await _expenseRepo.getExpensesByGroup(group.id);
      final complexExpenses = await _expenseRepo.getComplexExpensesByGroup(group.id);
      final participants = await _expenseRepo.getGroupExpenseParticipants(group.id);

      _recentExpenses.addAll(groupExpenses);
      _recentComplexExpenses.addAll(complexExpenses);
      _allParticipants.addAll(participants);
    }

    // Also get user's direct expenses
    final userExpenses = await _expenseRepo.getExpensesByUser(userId);
    _recentExpenses.addAll(userExpenses);

    // Remove duplicates and sort by date
    _recentExpenses = _recentExpenses.toSet().toList();
    _recentComplexExpenses = _recentComplexExpenses.toSet().toList();
    _allParticipants = _allParticipants.toSet().toList();

    // Sort by date and take only recent ones
    _recentExpenses.sort((a, b) => b.date.compareTo(a.date));
    _recentExpenses = _recentExpenses.take(10).toList();

    _recentComplexExpenses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _recentComplexExpenses = _recentComplexExpenses.take(5).toList();
  }

  // Load recent activities
  Future<void> _loadRecentActivities(String userId) async {
    final activities = <ActivityLogsModel>[];

    // Get activities from all user groups
    for (final group in _userGroups) {
      final groupActivities = await _activityRepo.getActivityLogsByGroup(group.id);
      activities.addAll(groupActivities);
    }

    // Sort by timestamp and take recent ones
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _recentActivities = activities.take(15).toList();

    // Preload user names for activities
    final userIds = _recentActivities.map((activity) => activity.userId).toSet();
    await Future.wait(userIds.map((id) => _fetchAndCacheUserName(id)));
  }

  // Calculate user balances
  Future<void> _calculateBalances(String userId) async {
    _totalBalance = 0.0;
    _pendingPayments = 0.0;
    _receivables = 0.0;

    // Calculate from all participants where user is involved
    for (final participant in _allParticipants) {
      if (participant.userId == userId) {
        if (participant.settled) {
          // This is already settled
          continue;
        } else {
          // Find the corresponding expense
          final expense = _recentExpenses.firstWhere(
            (exp) => exp.id == participant.expenseId,
            orElse: () => ExpenseModel(
              id: '', groupId: '', title: '', amount: 0.0,
              paidBy: '', category: '', date: DateTime.now()
            ),
          );

          if (expense.id.isNotEmpty) {
            if (expense.paidBy == userId) {
              // User paid, others owe to user
              _receivables += participant.share;
              _totalBalance += participant.share;
            } else {
              // User owes to the payer
              _pendingPayments += participant.share;
              _totalBalance -= participant.share;
            }
          }
        }
      }
    }

    // Add receivables from payments
    for (final payment in _recentPayments) {
      if (payment.toUser == userId && payment.isPending) {
        _receivables += payment.amount;
        _totalBalance += payment.amount;
      } else if (payment.fromUser == userId && payment.isPending) {
        _pendingPayments += payment.amount;
        _totalBalance -= payment.amount;
      }
    }
  }

  // Calculate current month spending
  void _calculateMonthlySpending(String userId) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    _monthlySpending = 0.0;

    // Calculate from regular expenses
    final monthlyExpenses = _recentExpenses.where((expense) =>
        expense.paidBy == userId &&
        expense.date.isAfter(currentMonth) &&
        expense.date.isBefore(nextMonth)).toList();

    _monthlySpending += monthlyExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // Calculate from complex expenses
    final monthlyComplexExpenses = _recentComplexExpenses.where((expense) =>
        expense.paidBy == userId &&
        expense.createdAt.isAfter(currentMonth) &&
        expense.createdAt.isBefore(nextMonth)).toList();

    _monthlySpending += monthlyComplexExpenses.fold(0.0, (sum, expense) => sum + expense.totalAmount);
  }

  // Get spending data for the last 7 days
  List<Map<String, dynamic>> getWeeklySpendingData() {
    final currentUserId = AuthUtils.getCurrentUserId();
    if (currentUserId == null) return [];

    final List<Map<String, dynamic>> weeklyData = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(Duration(days: 1));

      final dailyExpenses = _recentExpenses.where((expense) =>
          expense.paidBy == currentUserId &&
          expense.date.isAfter(dayStart) &&
          expense.date.isBefore(dayEnd)).toList();

      final dailyComplex = _recentComplexExpenses.where((expense) =>
          expense.paidBy == currentUserId &&
          expense.createdAt.isAfter(dayStart) &&
          expense.createdAt.isBefore(dayEnd)).toList();

      final dailyTotal = 
          dailyExpenses.fold(0.0, (sum, exp) => sum + exp.amount) +
          dailyComplex.fold(0.0, (sum, exp) => sum + exp.totalAmount);

      weeklyData.add({
        'day': day.day.toDouble(),
        'amount': dailyTotal,
        'dayName': _getDayName(day.weekday),
      });
    }

    return weeklyData;
  }

  // Get category breakdown for current month
  Map<String, double> getMonthlyCategoyBreakdown() {
    final currentUserId = AuthUtils.getCurrentUserId();
    if (currentUserId == null) return {};

    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);

    final Map<String, double> categoryData = {};

    // From regular expenses
    final monthlyExpenses = _recentExpenses.where((expense) =>
        expense.paidBy == currentUserId &&
        expense.date.isAfter(currentMonth) &&
        expense.date.isBefore(nextMonth)).toList();

    for (final expense in monthlyExpenses) {
      categoryData[expense.category] = 
          (categoryData[expense.category] ?? 0.0) + expense.amount;
    }

    // From complex expenses
    final monthlyComplex = _recentComplexExpenses.where((expense) =>
        expense.paidBy == currentUserId &&
        expense.createdAt.isAfter(currentMonth) &&
        expense.createdAt.isBefore(nextMonth)).toList();

    for (final expense in monthlyComplex) {
      for (final item in expense.items) {
        categoryData[item.category] = 
            (categoryData[item.category] ?? 0.0) + item.amount;
      }
    }

    return categoryData;
  }

  // Get formatted activity for display
  List<Map<String, dynamic>> getFormattedActivities() {
    return _recentActivities.take(5).map((activity) {
      String title = activity.formattedAction;
      String subtitle = activity.details;
      String displayName = getUserNameSync(activity.userId);
      
      // Customize display based on action type
      if (activity.isExpenseAction) {
        if (activity.action == 'create_expense') {
          title = 'New Expense Added';
          if (subtitle.contains('₹')) {
            final amountMatch = RegExp(r'₹([\d,]+\.?\d*)').firstMatch(subtitle);
            if (amountMatch != null) {
              subtitle = 'Added ₹${amountMatch.group(1)} expense';
            }
          }
        }
      } else if (activity.isPaymentAction) {
        title = activity.action == 'make_payment' ? 'Payment Made' : 'Payment Received';
      } else if (activity.isGroupAction) {
        if (activity.action == 'create_group') {
          title = 'Group Created';
          subtitle = 'Created new group';
        }
      }

      return {
        'title': title,
        'subtitle': subtitle,
        'user': displayName,
        'time': activity.timestamp,
        'isExpense': activity.isExpenseAction,
        'isPayment': activity.isPaymentAction,
        'isGroup': activity.isGroupAction,
      };
    }).toList();
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

  // Helper method to fetch and cache user name
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
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching user name for $userId: $e");
      _userNameCache[userId] = 'User ${userId.substring(0, 6)}...';
    }
  }

  // Helper methods
  String _getDayName(int weekday) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday];
  }

  // Public methods
  void refresh() {
    loadDashboardData();
  }

  void clear() {
    _recentExpenses.clear();
    _recentComplexExpenses.clear();
    _allParticipants.clear();
    _recentActivities.clear();
    _recentPayments.clear();
    _userGroups.clear();
    _userNameCache.clear();
    _totalBalance = 0.0;
    _pendingPayments = 0.0;
    _receivables = 0.0;
    _monthlySpending = 0.0;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}