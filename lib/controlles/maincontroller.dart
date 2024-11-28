import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbileprogrammingproject/models/mainmodel.dart';

class MainViewController extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  int _selectedIndex = 0;
  List<Friend> _friends = [];

  // Public getters for other parts of the app to use
  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;
  int get selectedIndex => _selectedIndex;
  List<Friend> get friends => _friends;

  // Constructor to load login status
  MainViewController() {
    _checkLoginStatus();  // Automatically check login status when the controller is created
  }
  void setLoginStatus(bool status)
  {
    _isLoggedIn = status;
    notifyListeners();  // Notify listeners to update the UI
  }


  // Method to check login status from SharedPreferences
  Future<void> _checkLoginStatus() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _isInitialized = true; // After checking login status, initialization is complete
    notifyListeners();
  }

  // Method to update the selected index for navigation
  void updateSelectedIndex(int index)
  {
    _selectedIndex = index;
    debugPrint("Selected index updated to: $_selectedIndex");
    notifyListeners();
  }

  // Method to load friends (this can be replaced by your actual database/API logic)
  Future<void> loadFriends(int userId) async {
    // Simulate database or API call for loading friends
    _friends = [
      Friend(name: "John Doe", profilePic: "https://via.placeholder.com/50", events: "1 Upcoming Event"),
      Friend(name: "Jane Smith", profilePic: "https://via.placeholder.com/50", events: "No Upcoming Events"),
      Friend(name: "Alex Brown", profilePic: "https://via.placeholder.com/50", events: "2 Upcoming Events"),
    ];
    notifyListeners();
  }

  // Method to log the user in
  Future<void> login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    _isLoggedIn = true; // Update the state to logged in
    notifyListeners();  // Notify listeners to update the UI
  }

  // Method to log the user out
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    _isLoggedIn = false; // Update the state to logged out
    notifyListeners();  // Notify listeners to update the UI
  }
}
