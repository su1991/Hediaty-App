import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
class AuthService extends ChangeNotifier
{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Sign up method (creates a new user with email and password)
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await
      _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Return the created user
    } catch (e) {
      return null; // Return null if error occurs (sign-up failed)
    }
  }
  // Sign-in method (returns a User? object)
  Future<User?> signIn(String email, String password) async
  {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // Returning the logged-in user
      return userCredential.user;
    } catch (e)
    {
      print("Login failed: $e");
      return null; // Return null if login fails
    }
  }
  // Sign-out method
  Future<void> signOut() async
  {
    await _auth.signOut();
  }
  // Get current user method
  User? getCurrentUser()
  {
    return _auth.currentUser;
  }
  // Check if a user is logged in
  bool isUserLoggedIn()
  {
    return _auth.currentUser != null;
  }
}