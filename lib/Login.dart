import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbileprogrammingproject/controlles/maincontroller.dart';
import 'package:mbileprogrammingproject/database/databasehelp.dart'; // Import DatabaseHelper
import 'package:mbileprogrammingproject/signup.dart';
import 'package:mbileprogrammingproject/main.dart';// Import Sign-Up Page

class LoginPage extends StatefulWidget
{
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    final controller = Provider.of<MainViewController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text("Login"), backgroundColor: Colors.yellow),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {

                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();

                // Validate email and password
                if (email.isNotEmpty && password.isNotEmpty)
                {
                  // Call login logic in the controller
                  await _login(context, email, password);
                } else
                {
                  // Show error message if email or password is empty
                  _showErrorDialog("Please enter both email and password.");
                }
              },
              child: Text("LOGIN"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: ()
              {
                // Navigate to the Sign-Up page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }

  // The login logic
  Future<void> _login(BuildContext context, String email, String password) async
  {
    final controller = Provider.of<MainViewController>(context, listen: false);
    final dbHelper = DatabaseHelper();

    try {
      // Retrieve the user by email from the database
      final user = await dbHelper.getUserByEmail(email);

      if (user != null && user.password == password)
      {
        // Successfully logged in
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        controller.setLoginStatus(true); // Update the controller state

        // Navigate to the main view
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainView()),
        );
      } else
      {
        // Incorrect login credentials
        _showErrorDialog("Invalid email or password.");
      }
    } catch (error)
    {
      // Handle database or other errors
      _showErrorDialog("An error occurred during login. Please try again.");
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Login Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
