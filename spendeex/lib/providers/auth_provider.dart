import 'package:flutter/material.dart';
import 'package:spendeex/data/repositories/auth_repository.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isAuthenticated = false;
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    final user = await _authRepository.signInWithGoogle();
    _isAuthenticated = user != null;
    print('isAuthenticated: $_isAuthenticated');

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _isAuthenticated = false;
    notifyListeners();
  }
}
