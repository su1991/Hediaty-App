import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbileprogrammingproject/controlles/maincontroller.dart';
import 'package:mbileprogrammingproject/models/mainmodel.dart';

import 'main.dart';

class LoginPage extends StatefulWidget
{
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
{
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
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
                String email = _emailController.text;
                String password = _passwordController.text;

                // Validate email and password (can add real validation)
                if (email.isNotEmpty && password.isNotEmpty) {
                  // Call login logic in the controller
                  await _login(context);
                } else {
                  // Show error message if email or password is empty
                  _showErrorDialog("Please enter both email and password.");
                }
              },
              child: Text("LOGIN"),
            ),
          ],
        ),
      ),
    );
  }

  // The login logic
  Future<void> _login(BuildContext context) async
  {
    final controller = Provider.of<MainViewController>(context, listen: false);

    // Simulate a login action (you can replace this with your own logic)
    if (_emailController.text == 'test@example.com' && _passwordController.text == 'password') {
      // Successfully logged in
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      controller.setLoginStatus(true);  // Update the controller state

      // Navigate to the main view
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainView()),
      );
    } else {
      // Incorrect login credentials
      _showErrorDialog("Invalid email or password.");
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
