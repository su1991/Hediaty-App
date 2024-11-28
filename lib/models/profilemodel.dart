// models/user_profile.dart
class UserProfile
{
  String? name;
  String? email;
  bool notificationsEnabled;

  UserProfile({
    this.name,
    this.email,
    this.notificationsEnabled = false,
  });

  // Method to update the profile data
  void updateProfile({String? newName, String? newEmail, bool? newNotifications}) {
    if (newName != null) name = newName;
    if (newEmail != null) email = newEmail;
    if (newNotifications != null) notificationsEnabled = newNotifications;
  }
}
