import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;
      print("User credentials: ${userCredential.user}");

      if (user != null) {
        await _saveUserToFirestore(user);
      }
      
      return user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  Future<void> _saveUserToFirestore(User user) async {
    // First check if a user with this email already exists (created via email)
    final querySnapshot =
        await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      // User exists with this email, update their profile with Google data
      final existingDoc = querySnapshot.docs.first;
      final userData = existingDoc.data();
      final String? existingName = userData['name'];
      final String? existingProfilePic = userData['profilePic'];

      // Update the existing document with Google sign-in data
      await _firestore.collection('users').doc(existingDoc.id).update({
        'name': user.displayName ?? existingName ?? '',
        'profilePic': user.photoURL ?? existingProfilePic ?? '',
        'uid': user.uid, // Update with Firebase Auth UID
        // Keep the original email and createdAt
      });
    } else {
      // Check if user exists with Firebase Auth UID
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // User doesn't exist, create new document
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName,
          'email': user.email,
          'profilePic': user.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
