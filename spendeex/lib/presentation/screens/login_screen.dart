import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: authProvider.isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => authProvider.signInWithGoogle(),
                child: Text("Sign in with Google"),
              ),
      ),
    );
  }
}
