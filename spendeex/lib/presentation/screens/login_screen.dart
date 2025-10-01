import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendeex/config/theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo/Title Section
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryWhite,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 60,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Spendeex',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryWhite,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Split expenses with friends',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.lightGrey,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 80),
              
              // Login Button
              if (authProvider.isLoading)
                Container(
                  height: 56,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryWhite,
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => authProvider.signInWithGoogle(),
                  icon: Icon(Icons.login, color: AppTheme.primaryBlack),
                  label: Text(
                    'Sign in with Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlack,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryWhite,
                    foregroundColor: AppTheme.primaryBlack,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              
              SizedBox(height: 40),
              
              // Footer
              Text(
                'By signing in, you agree to our Terms of Service\nand Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mediumGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
