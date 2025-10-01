import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/providers/friends_provider.dart';
import 'package:spendeex/config/theme.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendsProvider>().loadFriendsWithBalances();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlack,
        elevation: 0,
        title: Text(
          'Friends',
          style: TextStyle(
            color: AppTheme.primaryWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppTheme.primaryWhite),
            onPressed: () {
              context.read<FriendsProvider>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<FriendsProvider>(
        builder: (context, friendsProvider, child) {
          if (friendsProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
              ),
            );
          }

          if (friendsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.errorRed,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    friendsProvider.error!,
                    style: TextStyle(
                      color: AppTheme.lightGrey,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => friendsProvider.refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      foregroundColor: AppTheme.primaryWhite,
                    ),
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (friendsProvider.friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    color: AppTheme.mediumGrey,
                    size: 80,
                  ),
                  SizedBox(height: 24),
                  Text(
                    'No friends yet',
                    style: TextStyle(
                      color: AppTheme.primaryWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add friends to groups to see them here',
                    style: TextStyle(
                      color: AppTheme.lightGrey,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              friendsProvider.refresh();
            },
            color: AppTheme.successGreen,
            backgroundColor: AppTheme.cardBlack,
            child: ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: friendsProvider.friends.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final friend = friendsProvider.friends[index];
                return _buildFriendCard(context, friend);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendCard(BuildContext context, FriendBalance friend) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkGrey,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.successGreen.withOpacity(0.2),
                backgroundImage: friend.profilePic != null && friend.profilePic!.isNotEmpty
                    ? NetworkImage(friend.profilePic!)
                    : null,
                child: friend.profilePic == null || friend.profilePic!.isEmpty
                    ? Text(
                        friend.name.isNotEmpty ? friend.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: AppTheme.successGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 16),
              
              // Friend Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      style: TextStyle(
                        color: AppTheme.primaryWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (friend.email.isNotEmpty)
                      Text(
                        friend.email,
                        style: TextStyle(
                          color: AppTheme.lightGrey,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Balance Display
              _buildBalanceChip(friend),
            ],
          ),
          
          if (!friend.isSettled) ...[
            SizedBox(height: 16),
            _buildActionButtons(context, friend),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceChip(FriendBalance friend) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    if (friend.isSettled) {
      backgroundColor = AppTheme.mediumGrey.withOpacity(0.2);
      textColor = AppTheme.mediumGrey;
      text = 'Settled';
      icon = Icons.check_circle_outline;
    } else if (friend.owesYou) {
      backgroundColor = AppTheme.successGreen.withOpacity(0.2);
      textColor = AppTheme.successGreen;
      text = '+₹${friend.absoluteBalance.toStringAsFixed(0)}';
      icon = Icons.trending_up;
    } else {
      backgroundColor = AppTheme.errorRed.withOpacity(0.2);
      textColor = AppTheme.errorRed;
      text = '-₹${friend.absoluteBalance.toStringAsFixed(0)}';
      icon = Icons.trending_down;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, FriendBalance friend) {
    return Row(
      children: [
        if (friend.owesYou) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showRemindDialog(context, friend),
              icon: Icon(Icons.notifications_active, size: 18),
              label: Text('Remind'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen.withOpacity(0.2),
                foregroundColor: AppTheme.successGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppTheme.successGreen, width: 1),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          SizedBox(width: 12),
        ],
        
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showPaymentRequestDialog(context, friend),
            icon: Icon(Icons.payment, size: 18),
            label: Text(friend.youOwe ? 'Pay' : 'Request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: friend.youOwe 
                  ? AppTheme.errorRed.withOpacity(0.2)
                  : AppTheme.warningOrange.withOpacity(0.2),
              foregroundColor: friend.youOwe 
                  ? AppTheme.errorRed 
                  : AppTheme.warningOrange,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: friend.youOwe ? AppTheme.errorRed : AppTheme.warningOrange, 
                  width: 1,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  void _showRemindDialog(BuildContext context, FriendBalance friend) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Remind ${friend.name}',
            style: TextStyle(color: AppTheme.primaryWhite),
          ),
          content: Text(
            'Send a reminder notification to ${friend.name} about the ₹${friend.absoluteBalance.toStringAsFixed(2)} they owe you?',
            style: TextStyle(color: AppTheme.lightGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: AppTheme.mediumGrey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                
                final success = await context.read<FriendsProvider>().sendDebtReminder(
                  friend.userId,
                  friend.absoluteBalance,
                );

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reminder sent to ${friend.name}'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send reminder'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: AppTheme.primaryWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Send Reminder'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentRequestDialog(BuildContext context, FriendBalance friend) {
    final TextEditingController amountController = TextEditingController(
      text: friend.isSettled ? '' : friend.absoluteBalance.toStringAsFixed(2),
    );
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBlack,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            friend.youOwe ? 'Record Payment' : 'Request Payment',
            style: TextStyle(color: AppTheme.primaryWhite),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(color: AppTheme.primaryWhite),
                decoration: InputDecoration(
                  labelText: 'Amount (₹)',
                  labelStyle: TextStyle(color: AppTheme.lightGrey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.darkGrey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.successGreen),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: reasonController,
                style: TextStyle(color: AppTheme.primaryWhite),
                decoration: InputDecoration(
                  labelText: friend.youOwe ? 'Payment note (optional)' : 'Reason for request',
                  labelStyle: TextStyle(color: AppTheme.lightGrey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.darkGrey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.successGreen),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: AppTheme.mediumGrey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final amountText = amountController.text.trim();
                final reason = reasonController.text.trim();
                
                if (amountText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter an amount'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }

                final amount = double.tryParse(amountText);
                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid amount'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }

                if (!friend.youOwe && reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a reason for the request'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();

                if (friend.youOwe) {
                  // For now, just show a message about payment recording
                  // In a real app, this would integrate with payment processors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Payment recording feature coming soon'),
                      backgroundColor: AppTheme.warningOrange,
                    ),
                  );
                } else {
                  final success = await context.read<FriendsProvider>().sendPaymentRequest(
                    friend.userId,
                    amount,
                    reason.isNotEmpty ? reason : 'Payment request',
                  );

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Payment request sent to ${friend.name}'),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to send payment request'),
                        backgroundColor: AppTheme.errorRed,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: friend.youOwe ? AppTheme.errorRed : AppTheme.warningOrange,
                foregroundColor: AppTheme.primaryWhite,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(friend.youOwe ? 'Record Payment' : 'Send Request'),
            ),
          ],
        );
      },
    );
  }
}