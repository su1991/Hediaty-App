// controllers/user_profile_controller.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbileprogrammingproject/models/profilemodel.dart';

class UserProfileController extends ChangeNotifier {
  UserProfile userProfile;

  UserProfileController({required this.userProfile});

  // Update user profile fields
  void updateProfile({
    String? newName,
    String? newEmail,
    bool? newNotifications,
  }) {
    userProfile.updateProfile(
      newName: newName,
      newEmail: newEmail,
      newNotifications: newNotifications,
    );
    notifyListeners(); // Notify listeners of the change
  }

  // Save profile data to shared preferences (persistent storage)
  Future<void> saveProfileToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', userProfile.name ?? '');
    await prefs.setString('email', userProfile.email ?? '');
    await prefs.setBool('notificationsEnabled', userProfile.notificationsEnabled);
  }

  // Load profile data from shared preferences (persistent storage)
  Future<void> loadProfileFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userProfile.name = prefs.getString('name');
    userProfile.email = prefs.getString('email');
    userProfile.notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    notifyListeners(); // Notify listeners when profile data is loaded
  }
}
