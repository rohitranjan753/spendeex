import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  /// Check if a user exists with the given email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return {
          'uid': doc.id,
          ...doc.data(),
        };
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user by email $email: $e");
      rethrow;
    }
  }

  /// Create a new user with email and random UID
  Future<Map<String, dynamic>> createUserWithEmail(String email) async {
    try {
      final uid = _uuid.v4();
      final userData = {
        'uid': uid,
        'email': email,
        'name': '', // Empty when added by another person
        'profilePic': '', // Empty when added by another person
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).set(userData);
      
      return {
        'uid': uid,
        ...userData,
        'createdAt': Timestamp.now(), // Return current timestamp for immediate use
      };
    } catch (e) {
      debugPrint("Error creating user with email $email: $e");
      rethrow;
    }
  }

  /// Add or get user by email (checks if exists, creates if not)
  Future<Map<String, dynamic>> addOrGetUserByEmail(String email) async {
    try {
      // First check if user exists
      final existingUser = await getUserByEmail(email);
      if (existingUser != null) {
        return existingUser;
      }

      // Create new user if doesn't exist
      return await createUserWithEmail(email);
    } catch (e) {
      debugPrint("Error adding or getting user by email $email: $e");
      rethrow;
    }
  }
}