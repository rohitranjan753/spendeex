import 'package:firebase_auth/firebase_auth.dart';

class AuthUtils {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the current user's UID if authenticated, null otherwise
  static String? getCurrentUserId() {
    final User? user = _auth.currentUser;
    return user?.uid;
  }

  /// Returns the current user object if authenticated, null otherwise
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Checks if a user is currently authenticated
  static bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  /// Returns the current user's email if authenticated, null otherwise
  static String? getCurrentUserEmail() {
    final User? user = _auth.currentUser;
    return user?.email;
  }

  /// Returns the current user's display name if authenticated, null otherwise
  static String? getCurrentUserDisplayName() {
    final User? user = _auth.currentUser;
    return user?.displayName;
  }

  /// Returns the current user's photo URL if authenticated, null otherwise
  static String? getCurrentUserPhotoURL() {
    final User? user = _auth.currentUser;
    return user?.photoURL;
  }
}