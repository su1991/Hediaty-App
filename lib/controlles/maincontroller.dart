import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbileprogrammingproject/models/mainmodel.dart';

import '../Login.dart';
import '../models/eventlistmodel.dart';
import '../models/giftdetailsmodel.dart';

class MainViewController extends ChangeNotifier
{
  final MainModel _model = MainModel();
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  int _selectedIndex = 0;
  List<Friend> _friends = [];
  List<Event> _events = [];

  // Public getters for other parts of the app to use
  bool get isLoggedIn => _isLoggedIn;
  List<Event> get events => _events;
  bool get isInitialized => _isInitialized;
  int get selectedIndex => _selectedIndex;
  List<Friend> get friends => _friends;

  // Constructor to load login status
  MainViewController()
  {
    _checkLoginStatus();  // Automatically check login status when the controller is created
  }


  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
    _isLoggedIn = false; // Update login state
    notifyListeners();

    // Redirect to LoginPage
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void setLoginStatus(bool status)
  {
    _isLoggedIn = status;
    notifyListeners();  // Notify listeners to update the UI
  }

  Future<void> login(String email, String password) async
  {
    final user = await _model.getUser(email);
    if (user != null && user.password == password)
    {
      _isLoggedIn = true;
      _events = await _model.getEvents(user.id);
      notifyListeners(); // Notify the UI to refresh
    } else {
      throw Exception("Invalid login credentials.");
    }
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


  // Method to load friends (this can be replaced by your actual database/API logic)
  Future<void> loadFriends(int userId) async
  {
    // Simulate database or API call for loading friends
    _friends = [
      Friend(name: "John Doe", profilePic: "https://via.placeholder.com/50", events: "1 Upcoming Event"),
      Friend(name: "Jane Smith", profilePic: "https://via.placeholder.com/50", events: "No Upcoming Events"),
      Friend(name: "Alex Brown", profilePic: "https://via.placeholder.com/50", events: "2 Upcoming Events"),
    ];
    notifyListeners();
  }

  // Method to log the user in
  Future<List<Gift>> fetchGifts(int eventId) async
  {
    return await _model.getGifts(eventId);
  }

  initializeApp() {

  }

  // Method to log the user out

}
