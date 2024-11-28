// user_profile_page.dart
import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/main.dart';
import 'package:provider/provider.dart';
import 'package:mbileprogrammingproject/controlles/profilecontroller.dart';
import 'package:mbileprogrammingproject/models/profilemodel.dart';

import 'controlles/maincontroller.dart';

class UserProfilePage extends StatefulWidget
{
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final userProfileController = Provider.of<UserProfileController>(context, listen: false);
    _nameController = TextEditingController(text: userProfileController.userProfile.name);
    _emailController = TextEditingController(text: userProfileController.userProfile.email);

    // Load profile from storage when the page is initialized
    userProfileController.loadProfileFromStorage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final userProfileController = Provider.of<UserProfileController>(context, listen: false);
    userProfileController.updateProfile(
      newName: _nameController.text,
      newEmail: _emailController.text,
    );
    await userProfileController.saveProfileToStorage();
    Navigator.pop(context); // Navigate back after saving
  }

  @override
  Widget build(BuildContext context) {
    final userProfileController = Provider.of<UserProfileController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifications'),
                  Switch(
                    value: userProfileController.userProfile.notificationsEnabled,
                    onChanged: (value) {
                      userProfileController.updateProfile(
                        newNotifications: value,
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save'),
              ),

              ElevatedButton
                (
                onPressed: ()
                {
                  final mainViewController = Provider.of<MainViewController>(context, listen: false);
                  mainViewController.updateSelectedIndex(3);
                },
                child: Text('My Pledged Gifts'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
