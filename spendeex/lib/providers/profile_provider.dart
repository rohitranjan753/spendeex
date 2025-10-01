import 'package:flutter/foundation.dart';
import 'package:spendeex/core/auth_utils.dart';
import 'package:spendeex/data/repositories/user_repository.dart';
import 'package:spendeex/data/repositories/expense_repository.dart';
import 'package:spendeex/data/repositories/group_repository.dart';
import 'package:spendeex/data/repositories/activity_logs_repository.dart';
import 'package:spendeex/data/repositories/payments_repository.dart';
import 'package:spendeex/data/models/expense_model.dart';
import 'package:spendeex/data/models/expense_participants_model.dart';
import 'package:spendeex/data/models/group_model.dart';
import 'package:spendeex/data/models/activity_logs_model.dart';
import 'package:spendeex/data/models/payments_model.dart';

class ProfileProvider with ChangeNotifier {
  final UserRepository _userRepo = UserRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final GroupRepository _groupRepo = GroupRepository();
  final ActivityLogsRepository _activityRepo = ActivityLogsRepository();
  final PaymentsRepository _paymentsRepo = PaymentsRepository();

  // User data
  Map<String, dynamic>? _currentUserData;
  
  // Statistics
  double _totalSpent = 0.0;
  double _moneyOwed = 0.0;
  double _moneyToReceive = 0.0;
  
  // Activities and expenses
  List<ActivityLogsModel> _recentActivities = [];
  List<ExpenseModel> _recentExpenses = [];
  List<ExpenseParticipantsModel> _userParticipants = [];
  List<GroupModel> _userGroups = [];
  
  // Loading states
  bool _isLoading = false;
  String? _error;
  
  // Cache for user names
  final Map<String, String> _userNameCache = {};

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get currentUserData => _currentUserData;
  double get totalSpent => _totalSpent;
  double get moneyOwed => _moneyOwed;
  double get moneyToReceive => _moneyToReceive;
  List<ActivityLogsModel> get recentActivities => _recentActivities;
  List<ExpenseModel> get recentExpenses => _recentExpenses;
  List<GroupModel> get userGroups => _userGroups;

  // Get user display name
  String get userName {
    if (_currentUserData == null) return 'Loading...';
    
    final name = _currentUserData!['name'] as String? ?? '';
    if (name.isNotEmpty) return name;
    
    final email = _currentUserData!['email'] as String? ?? '';
    if (email.isNotEmpty) return email.split('@')[0];
    
    return 'User';
  }

  // Get user email
  String get userEmail {
    if (_currentUserData == null) return '';
    return _currentUserData!['email'] as String? ?? '';
  }

  // Get user profile picture URL
  String? get userProfilePic {
    if (_currentUserData == null) return null;
    return _currentUserData!['profilePic'] as String?;
  }

  // Initialize and load all profile data
  Future<void> loadProfileData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final currentUserId = AuthUtils.getCurrentUserId();
      if (currentUserId == null) {
        _error = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load user data
      await _loadUserData(currentUserId);
      
      // Load user's groups
      _userGroups = await _groupRepo.getGroupsByUser(currentUserId);
      
      // Load user's expense participants to calculate statistics
      await _loadUserParticipants(currentUserId);
      
      // Calculate statistics
      await _calculateStatistics(currentUserId);
      
      // Load recent activities
      await _loadRecentActivities(currentUserId);
      
      // Load recent expenses
      await _loadRecentExpenses(currentUserId);

      _error = null;
    } catch (e) {
      _error = 'Failed to load profile data: $e';
      debugPrint('Error loading profile data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load current user data
  Future<void> _loadUserData(String userId) async {
    try {
      // Try to get user from Firestore first
      _currentUserData = await _userRepo.getUserById(userId);
      
      // If not found in Firestore, get from Firebase Auth
      if (_currentUserData == null) {
        final currentUser = AuthUtils.getCurrentUser();
        if (currentUser != null) {
          _currentUserData = {
            'uid': currentUser.uid,
            'email': currentUser.email ?? '',
            'name': currentUser.displayName ?? '',
            'profilePic': currentUser.photoURL,
          };
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Load user's expense participants for statistics calculation
  Future<void> _loadUserParticipants(String userId) async {
    try {
      _userParticipants.clear();
      
      // Get participants for all user's groups
      for (final group in _userGroups) {
        final groupParticipants = await _expenseRepo.getGroupExpenseParticipants(group.id);
        _userParticipants.addAll(groupParticipants.where((p) => p.userId == userId));
      }
    } catch (e) {
      debugPrint('Error loading user participants: $e');
    }
  }

  // Calculate user statistics
  Future<void> _calculateStatistics(String userId) async {
    try {
      _totalSpent = 0.0;
      _moneyOwed = 0.0;
      _moneyToReceive = 0.0;

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);
      final nextMonth = DateTime(now.year, now.month + 1, 1);

      // Get all expenses for user's groups
      List<ExpenseModel> allExpenses = [];
      List<ComplexExpenseModel> allComplexExpenses = [];
      
      for (final group in _userGroups) {
        final groupExpenses = await _expenseRepo.getExpensesByGroup(group.id);
        final groupComplexExpenses = await _expenseRepo.getComplexExpensesByGroup(group.id);
        allExpenses.addAll(groupExpenses);
        allComplexExpenses.addAll(groupComplexExpenses);
      }

      // Calculate total spent (expenses paid by user in current month)
      final monthlyExpenses = allExpenses.where((expense) =>
          expense.paidBy == userId &&
          expense.date.isAfter(currentMonth) &&
          expense.date.isBefore(nextMonth)).toList();

      _totalSpent = monthlyExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

      // Add complex expenses
      final monthlyComplexExpenses = allComplexExpenses.where((expense) =>
          expense.paidBy == userId &&
          expense.createdAt.isAfter(currentMonth) &&
          expense.createdAt.isBefore(nextMonth)).toList();

      _totalSpent += monthlyComplexExpenses.fold(0.0, (sum, expense) => sum + expense.totalAmount);

      // Calculate money owed by user (unsettled shares)
      final userOwedParticipants = _userParticipants.where((participant) => 
          !participant.settled).toList();

      for (final participant in userOwedParticipants) {
        final expense = allExpenses.firstWhere(
          (exp) => exp.id == participant.expenseId,
          orElse: () => ExpenseModel(
            id: '', groupId: '', title: '', amount: 0.0, 
            paidBy: '', category: '', date: DateTime.now()
          ),
        );

        if (expense.id.isNotEmpty && expense.paidBy != userId) {
          _moneyOwed += participant.share;
        }
      }

      // Calculate money to receive (money others owe to user)
      final expensesPaidByUser = allExpenses.where((expense) => expense.paidBy == userId).toList();

      for (final expense in expensesPaidByUser) {
        final expenseParticipants = await _expenseRepo.getExpenseParticipants(expense.id);
        for (final participant in expenseParticipants) {
          if (participant.userId != userId && !participant.settled) {
            _moneyToReceive += participant.share;
          }
        }
      }

    } catch (e) {
      debugPrint('Error calculating statistics: $e');
    }
  }

  // Load recent activities
  Future<void> _loadRecentActivities(String userId) async {
    try {
      _recentActivities.clear();
      
      // Get activities from all user's groups
      for (final group in _userGroups) {
        final groupActivities = await _activityRepo.getActivityLogsByGroup(group.id);
        _recentActivities.addAll(groupActivities);
      }
      
      // Sort by timestamp and take latest 10
      _recentActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _recentActivities = _recentActivities.take(10).toList();

      // Cache user names for activities
      for (final activity in _recentActivities) {
        await _fetchAndCacheUserName(activity.userId);
      }
    } catch (e) {
      debugPrint('Error loading recent activities: $e');
    }
  }

  // Load recent expenses
  Future<void> _loadRecentExpenses(String userId) async {
    try {
      _recentExpenses.clear();
      
      // Get expenses from all user's groups
      for (final group in _userGroups) {
        final groupExpenses = await _expenseRepo.getExpensesByGroup(group.id);
        _recentExpenses.addAll(groupExpenses);
      }
      
      // Sort by date and take latest 5
      _recentExpenses.sort((a, b) => b.date.compareTo(a.date));
      _recentExpenses = _recentExpenses.take(5).toList();
    } catch (e) {
      debugPrint('Error loading recent expenses: $e');
    }
  }

  // Get formatted activity for display
  List<Map<String, dynamic>> getFormattedActivities() {
    return _recentActivities.take(3).map((activity) {
      String title = activity.formattedAction;
      String subtitle = _formatTimeAgo(activity.timestamp);
      String displayName = getUserNameSync(activity.userId);
      
      // Customize display based on action type
      if (activity.isExpenseAction) {
        if (activity.action == 'create_expense') {
          title = 'New expense added';
          if (activity.details.contains('₹')) {
            final amountMatch = RegExp(r'₹([\d,]+\.?\d*)').firstMatch(activity.details);
            if (amountMatch != null) {
              title = 'Added ₹${amountMatch.group(1)} expense';
            }
          }
        }
      } else if (activity.isPaymentAction) {
        if (activity.action == 'make_payment') {
          title = 'Payment made';
        }
      }

      return {
        'title': title,
        'subtitle': subtitle,
        'user': displayName,
        'time': activity.timestamp,
        'isExpense': activity.isExpenseAction,
        'isPayment': activity.isPaymentAction,
      };
    }).toList();
  }

  // Get formatted past expenses for display
  List<Map<String, dynamic>> getFormattedPastExpenses() {
    return _recentExpenses.take(3).map((expense) {
      // Check if expense is settled by checking if user has any unsettled participants
      bool isSettled = true;
      try {
        final userParticipant = _userParticipants.firstWhere(
          (p) => p.expenseId == expense.id,
          orElse: () => ExpenseParticipantsModel(
            id: '', expenseId: '', userId: '', share: 0.0, settled: true
          ),
        );
        isSettled = userParticipant.settled;
      } catch (e) {
        // If no participant found, assume settled
        isSettled = true;
      }

      return {
        'title': expense.title,
        'amount': '₹${expense.amount.toStringAsFixed(0)}',
        'category': expense.category,
        'settled': isSettled,
        'date': expense.date,
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
    return 'User';
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
          displayName = 'User';
        }
        
        _userNameCache[userId] = displayName;
        notifyListeners(); // Update UI when name is loaded
      }
    } catch (e) {
      debugPrint("Error fetching user name for $userId: $e");
      _userNameCache[userId] = 'User';
    }
  }

  // Format time ago
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await loadProfileData();
  }
}