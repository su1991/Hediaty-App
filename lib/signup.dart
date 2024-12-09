import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/database/databasehelp.dart';
import 'package:mbileprogrammingproject/Login.dart'; // Import Login page

class SignUpPage extends StatefulWidget
{
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
{
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _prefernces = TextEditingController();

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up"), backgroundColor: Colors.yellow),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 16),
            TextField(
              controller: _prefernces,
              decoration: InputDecoration(
                labelText: 'prefernces',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16,),
            TextField(

              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton
              (
              onPressed: () async
              {
                String name = _nameController.text.trim();
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                String prefernces = _prefernces.text.trim();

                // Validate the input fields
                if (_validateInputs(name, email, password,prefernces))
                {
                  // Call sign-up logic
                  await _signUp(name, email, password,prefernces);
                }
              },
              child: Text("SIGN UP"),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                // Navigate back to the Login page
                Navigator.pop(context);
              },
              child: Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }

  // Validation for inputs
  bool _validateInputs(String name, String email, String password, String prefernces)
  {
    if (name.isEmpty || email.isEmpty || password.isEmpty || prefernces.isEmpty)
    {
      _showErrorDialog("Please fill in all the fields.");
      return false;
    }

    // Validate email format using regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      _showErrorDialog("Please enter a valid email address.");
      return false;
    }

    // Validate password length
    if (password.length < 1)
    {
      _showErrorDialog("Password must be at least 1 characters long.");
      return false;
    }

    return true; // All inputs are valid
  }

  // Sign-up logic
  Future<void> _signUp(String name, String email, String password, String preferences) async
  {
    final dbHelper = DatabaseHelper();

    try {
      // Check if user already exists
      final existingUser = await dbHelper.getUserByEmail(email);
      if (existingUser != null)
      {
        print('User already exists: $existingUser');
        _showErrorDialog("User with this email already exists.");
      } else {
        // Insert new user into the database
        final newUser = User(

          id: 0, // Database will auto-generate the ID
          name: name,
          email: email,
          password: password,
          preferences: preferences,
        );
        await dbHelper.insertUser(newUser);
        print('New user created: $newUser');

        // Navigate to the login page after successful sign-up
        Navigator.pop(context);
      }
    } catch (error) {
      // Handle errors like database issues
      print('Error during sign-up: $error');
      _showErrorDialog("An error occurred during sign-up. Please try again.");
    }
  }


  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Sign Up Failed"),
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
