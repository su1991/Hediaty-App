import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:mbileprogrammingproject/database/dataV2.dart'; // Import your DatabaseHelper
import 'package:mbileprogrammingproject/Login.dart'; // Import Login page

class SignUpPage extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final DatabaseHelperv2 _dbHelper = DatabaseHelperv2(); // Initialize DatabaseHelper

  String? _validatename(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your email';
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zAZ]{2,}$").hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    } else if (value.length <= 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Create a new user in Firebase Authentication
        final firebaseUser = await firebase_auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final userCollection = FirebaseFirestore.instance.collection('users');

        // Add the user to the Firestore collection
        await userCollection.doc(firebaseUser.user?.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          // Default preferences or additional user info
        });

        // Initialize the friends subcollection (it will be empty initially)
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.user?.uid)
            .collection('friends'); // Create an empty friends subcollection

        // Cache the user locally (if required)
        final newUser = User(
          id: 0, // SQLite auto-increment
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          preferences: '', // Default preferences
          password: _passwordController.text.trim(), // Save the password securely
        );

        await _dbHelper.insertUser(newUser);

        // Navigate to the Login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
        );
      } on firebase_auth.FirebaseAuthException catch (e) {
        // Handle Firebase errors
        final errorMessage = e.message ?? 'An error occurred';
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up'), backgroundColor: Colors.green),
      body: SingleChildScrollView( // Make the body scrollable
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'name',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 16),
              // Email field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.email),
                ),
              ),
              SizedBox(height: 16),
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 16),
              // Confirm password field
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 16),
              // Sign-Up button
              ElevatedButton(
                onPressed: _signUp,
                child: Text('Sign Up'),
              ),
              // Navigate to login screen
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => LoginPage()),
                  );
                },
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
