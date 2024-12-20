import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbileprogrammingproject/controlles/maincontroller.dart';
import 'package:mbileprogrammingproject/database/dataV2.dart'; // Import DatabaseHelper
import 'package:mbileprogrammingproject/signup.dart'; // Import Sign-Up Page
import 'package:mbileprogrammingproject/main.dart';
import 'package:mbileprogrammingproject/auth_service.dart';// Import the main view

class LoginPage extends StatefulWidget
{
  @override
  _LoginScreenState createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  // Email validation
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your email';
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zAZ]{2,}$").hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }
  // Password validation
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your password';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
  void _login() async
  {
    // Validate the form fields
    if (_formKey.currentState?.validate() ?? false)
    {
      // Sign in with Firebase Authentication
      var user = await _authService.signIn(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null)
      {
        // Check if user exists in local database
        final dbHelper = DatabaseHelperv2();
        final existingUser = await dbHelper.getUserByEmail(_emailController.text);

        if (existingUser == null)
        {
          // If user doesn't exist, fetch data from Firestore and cache it
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          if (userDoc.exists)
          {
            final userData = userDoc.data();
            if (userData != null)
            {
              // Cache the user data locally in the SQLite database
              await dbHelper.cacheUserData
                (
                user.uid, // Pass the user ID
                {
                  'name': userData['name'] ?? '',
                  'email': userData['email'] ?? '',
                  'preferences': userData['preferences'] ?? '',
                  'password': userData['password'] ?? '', // Password is fetched from Firestore
                },
              );
            }
          }
        } else {
          // User already exists locally, you can update or just proceed
          print('User already exists locally.');

        }

        // After the user is logged in, load friends list
        // This assumes that your MainViewController is set up with Provider


        // Navigate to MainView after successful login
        Navigator.pushReplacement
          (
          context,
          MaterialPageRoute(builder: (_) => MainView()),
        );
      } else {
        // Handle login failure and show error using a Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed. Please check credentials.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: Text("Login"),backgroundColor: Colors.green,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email",border:
                OutlineInputBorder(),suffixIcon: Icon(Icons.email),),
                validator: _validateEmail,
              ), SizedBox(height: 16,),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password",border:
                OutlineInputBorder(),suffixIcon: Icon(Icons.lock),),
                validator: _validatePassword,
              ), SizedBox(height: 16,),
              ElevatedButton(
                onPressed: _login,
                child: Text("Login"),
              ),
              TextButton(
                onPressed: ()
                {
                  Navigator.push
                    (
                      context,
                      MaterialPageRoute(builder: (_) => SignUpPage()), //

                  );
                },
                child: Text("Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

