import 'package:flutter/foundation.dart';
import 'package:spendeex/core/auth_utils.dart';
import 'package:spendeex/data/repositories/group_repository.dart';
import 'package:spendeex/data/repositories/expense_repository.dart';
import 'package:spendeex/data/repositories/payments_repository.dart';
import 'package:spendeex/data/repositories/user_repository.dart';
import 'package:spendeex/data/repositories/notifications_repository.dart';

class FriendsProvider with ChangeNotifier {
  final GroupRepository _groupRepo = GroupRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final PaymentsRepository _paymentsRepo = PaymentsRepository();
  final UserRepository _userRepo = UserRepository();
  final NotificationsRepository _notificationsRepo = NotificationsRepository();

  // State variables
  List<FriendBalance> _friends = [];
  bool _isLoading = false;
  String? _error;

  // Cache for user names to avoid repeated API calls
  final Map<String, String> _userNameCache = {};

  // Getters
  List<FriendBalance> get friends => _friends;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load friends and calculate balances
  Future<void> loadFriendsWithBalances() async {
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

      // Get all friends from shared groups
      final friendsData = await _groupRepo.getFriendsFromSharedGroups(currentUserId);
      
      // Calculate balances for each friend
      final List<FriendBalance> friendsWithBalances = [];
      
      for (final friendData in friendsData) {
        final friendUserId = friendData['uid'] as String;
        
        // Calculate net balance between current user and this friend
        final balance = await _calculateNetBalance(currentUserId, friendUserId);
        
        final friendBalance = FriendBalance(
          userId: friendUserId,
          name: friendData['name'] ?? friendData['email']?.split('@')[0] ?? 'User',
          email: friendData['email'] ?? '',
          profilePic: friendData['profilePic'],
          balance: balance,
        );
        
        friendsWithBalances.add(friendBalance);
        
        // Cache the user name
        _userNameCache[friendUserId] = friendBalance.name;
      }

      // Sort friends by balance (highest owed to you first, then alphabetically)
      friendsWithBalances.sort((a, b) {
        if (a.balance != b.balance) {
          return b.balance.compareTo(a.balance); // Higher balance first (they owe you more)
        }
        return a.name.compareTo(b.name); // Alphabetical for same balance
      });

      _friends = friendsWithBalances;
      _error = null;
    } catch (e) {
      _error = 'Failed to load friends: $e';
      debugPrint('Error loading friends with balances: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate net balance between two users
  Future<double> _calculateNetBalance(String currentUserId, String friendUserId) async {
    try {
      double netBalance = 0.0;

      // Get all user's groups to check shared expenses
      final userGroups = await _groupRepo.getGroupsByUser(currentUserId);
      
      for (final group in userGroups) {
        // Check if friend is also in this group
        final groupMembers = await _groupRepo.getGroupMembers(group.id);
        final isFriendInGroup = groupMembers.any((member) => member.userId == friendUserId);
        
        if (!isFriendInGroup) continue;

        // Get all expense participants for this group
        final groupParticipants = await _expenseRepo.getGroupExpenseParticipants(group.id);
        final groupExpenses = await _expenseRepo.getExpensesByGroup(group.id);

        // Create a map of expense ID to payer ID
        final expensePayerMap = <String, String>{};
        for (final expense in groupExpenses) {
          expensePayerMap[expense.id] = expense.paidBy;
        }

        // Calculate balance from participants data
        for (final participant in groupParticipants) {
          final expenseId = participant.expenseId;
          final payerId = expensePayerMap[expenseId];
          
          if (payerId == null) continue;
          
          // If current user paid and friend owes
          if (payerId == currentUserId && participant.userId == friendUserId && !participant.settled) {
            netBalance += participant.share; // Friend owes current user
          }
          
          // If friend paid and current user owes
          if (payerId == friendUserId && participant.userId == currentUserId && !participant.settled) {
            netBalance -= participant.share; // Current user owes friend
          }
        }
      }

      // Also check direct payments between users
      final netPaymentBalance = await _paymentsRepo.calculateNetBalance(currentUserId, friendUserId);
      netBalance -= netPaymentBalance; // Subtract payments made

      return netBalance;
    } catch (e) {
      debugPrint('Error calculating net balance between $currentUserId and $friendUserId: $e');
      return 0.0;
    }
  }

  // Send payment request notification
  Future<bool> sendPaymentRequest(String friendUserId, double amount, String reason) async {
    try {
      final currentUser = AuthUtils.getCurrentUser();
      if (currentUser == null) return false;

      final currentUserName = currentUser.displayName ?? 
                             currentUser.email?.split('@')[0] ?? 
                             'Someone';

      await _notificationsRepo.sendPaymentRequestNotification(
        toUserId: friendUserId,
        fromUserName: currentUserName,
        amount: amount,
        reason: reason,
      );

      return true;
    } catch (e) {
      debugPrint('Error sending payment request: $e');
      return false;
    }
  }

  // Send reminder notification
  Future<bool> sendDebtReminder(String friendUserId, double amount, {String? expenseName}) async {
    try {
      final currentUser = AuthUtils.getCurrentUser();
      if (currentUser == null) return false;

      final currentUserName = currentUser.displayName ?? 
                             currentUser.email?.split('@')[0] ?? 
                             'Someone';

      await _notificationsRepo.sendDebtReminderNotification(
        toUserId: friendUserId,
        fromUserName: currentUserName,
        amount: amount,
        expenseName: expenseName,
      );

      return true;
    } catch (e) {
      debugPrint('Error sending debt reminder: $e');
      return false;
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

  // Refresh data
  void refresh() {
    loadFriendsWithBalances();
  }

  // Clear data
  void clear() {
    _friends.clear();
    _userNameCache.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

// Model class for friend with balance
class FriendBalance {
  final String userId;
  final String name;
  final String email;
  final String? profilePic;
  final double balance; // Positive means they owe you, negative means you owe them

  FriendBalance({
    required this.userId,
    required this.name,
    required this.email,
    this.profilePic,
    required this.balance,
  });

  bool get owesYou => balance > 0;
  bool get youOwe => balance < 0;
  bool get isSettled => balance == 0;
  double get absoluteBalance => balance.abs();
}