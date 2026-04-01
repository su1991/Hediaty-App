import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mbileprogrammingproject/models/mainmodel.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../Login.dart';
import '../database/dataV2.dart';
import '../models/eventlistmodel.dart';
import '../models/giftdetailsmodel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MainViewController extends ChangeNotifier
{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken; // Store FCM token
  final MainModel _model = MainModel();
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  int _selectedIndex = 0;
  List<Friend> _friends = [];
  List<Event> events = [];
  List<Friend> _allUsers = [];
  String _userName = "";
  String get userName => _userName;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get isLoggedIn => _isLoggedIn;

  bool get isInitialized => _isInitialized;
  int get selectedIndex => _selectedIndex;
  List<Friend> get friends => _friends;
  List<Friend> get allUsers => _allUsers;

  Future<void> checkLoginStatus() async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (_isLoggedIn)
    {
      String? userId = prefs.getString('userId');
      if (userId != null)
      {
        await initializeApp(); // Ensure this completes
      }
    }

    _isInitialized = true;
    notifyListeners();
  }
  Future<void> initializeNotifications() async
  {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> initializeApp() async
  {
    print("Initializing app...");
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      print("Fetching username for UID: ${firebaseUser.uid}");
      await fetchUserName(firebaseUser.uid);

      // Persist the user ID
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', firebaseUser.uid);

      _isLoggedIn = true;

      // Load friends after fetching user name
      await loadFriends(firebaseUser.uid);  // Load friends here
    }

    _isInitialized = true;
    print("Initialization complete. User name: $_userName"); // Debug
    notifyListeners();
  }

  // Modified fetchEvents to notify listeners
  Future<void> fetchEvents(String userId) async
  {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      events = snapshot.docs.map((doc) {
        return Event.fromFirestore(doc);
      }).toList();

      // Only notify listeners if the events list has been updated
      if (events.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  Future<void> fetchUserName(String userId) async
  {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists)
      {
        print("User document data: ${userDoc.data()}"); // Debug log
        _userName = userDoc.data()?['name'] ?? "User";
        notifyListeners();
        print("Fetched user name: $_userName"); // Debug fetched name
      } else
      {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
  }

  MainViewController()
  {
    print("MainViewController initialized");
    checkLoginStatus();
    initializeFCM();
  }
  Future<void> initializeFCM() async {
    // Request permissions for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('FCM: User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('FCM: User granted provisional permission');
    } else {
      print('FCM: User denied permission');
    }

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $_fcmToken');

    // Save the token to Firestore for the current user
    await _saveFCMTokenToFirestore();

    // Listen for incoming messages
    _listenToMessages();
  }

  Future<void> _saveFCMTokenToFirestore() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && _fcmToken != null) {
      try {
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .update({'fcmToken': _fcmToken});
        print("FCM Token saved to Firestore");
      } catch (e) {
        print("Error saving FCM token: $e");
      }
    }
  }

  void _listenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Received foreground message: ${message.notification?.title}');
      // Show local notification
      await _showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked: ${message.notification?.body}');
      // Handle click (e.g., navigate to specific screen)
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x', // Optional, can be used to pass data on click
    );
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // Handle background message processing
  }


  void updateSelectedIndex(int index) {
    _selectedIndex = index;
    print("Selected index updated to: $_selectedIndex"); // Debugging selected index
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _isLoggedIn = false;
    _userName = "";
    _friends.clear(); // Clear the friends list
    _allUsers.clear(); // Clear all users list if needed
    notifyListeners(); // Notify UI of state changes
    print("User logged out");
    notifyListeners();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  bool isLoading = false;
  void printFriendsList(String context)
  {
    print("Friends list at $context: ${_friends.map((f) => f.name).toList()}");
    printFriendsList('after loading friends');
  }

  Future<void> loadFriends(String userId) async
  {
    try
    {
      // Fetch friends from Firestore where 'deleted' is false
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();

      if (snapshot.docs.isEmpty)
      {
        print("No friends found in Firestore.");
        _friends = []; // Clear the list if no friends are found
      } else {
        // Convert Firestore documents to Friend model objects
        _friends = snapshot.docs.map((doc)
        {
          return Friend.fromMap(doc.data());
        }).toList();

        print("Friends loaded: ${_friends.length}");
      }
    } catch (e)
    {
      // Handle errors gracefully
      print("Error loading friends: $e");
      _friends = []; // Reset the list in case of error
    } finally
    {
      // Notify listeners after data fetching is complete
      notifyListeners();
    }
  }

  Future<void> fetchAllUsers() async
  {
    print("Fetching all users...");
    try {
      final users = await FirebaseFirestore.instance.collection('users').get();
      print("Fetched ${users.docs.length} users from Firestore");

      // Get the current user ID
      final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;

      // Filter out the current user and deleted users
      _allUsers = users.docs.where((doc) {
        final data = doc.data();
        final isDeleted = data['isDeleted'] ?? false;
        final userId = doc.id;

        // Exclude the current user and deleted users
        return !isDeleted && userId != currentUserId;
      }).map((doc) {
        final data = doc.data();
        return Friend(
          name: data['name'] ?? '',
          profilePic: data['profilePic'] ?? 'https://via.placeholder.com/50',
          events: data['events'] ?? 'No Upcoming Events',
          id: doc.id, fcmToken: '',
        );
      }).toList();

      print("Filtered total users: ${_allUsers.length}");
      notifyListeners();  // Update UI with filtered list of users
    } catch (e) {
      print("Error fetching users: $e");
    }
  }

  Future<void> addFriend
      (
      String userId,
      Map<String, dynamic> friendData,
      Friend friend,
      BuildContext context,
      ) async
  {
    final currentUserId = firebase_auth.FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not authenticated. Please log in again.")),
      );
      return;
    }

    // Ensure _userName is loaded
    if (_userName.isEmpty) {
      print("Fetching user name before adding friend...");
      await fetchUserName(currentUserId);
      if (_userName.isEmpty) {
        print("Failed to fetch user name.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to retrieve your user name. Try again.")),
        );
        return;
      }
    }

    try {
      // Step 1: Fetch the latest friends list from Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .get();

      // Convert Firestore data to a local list of friends using Friend.fromMap
      List<Friend> currentFriends = snapshot.docs
          .map((doc) => Friend.fromMap({
        'id': doc.id,
        ...doc.data(), // Merge Firestore fields into the map
      }))
          .toList();

      // Step 2: Check for duplicates
      bool isFriendAlreadyAdded =
      currentFriends.any((existingFriend) => existingFriend.id == friend.id);

      if (isFriendAlreadyAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("This friend is already added.")),
        );
        return;
      }

      // Step 3: Prevent self-friendship
      if (friend.name == _userName) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You cannot add yourself as a friend.")),
        );
        return;
      }

      // Step 4: Add friend to Firestore for both users
      // Add to current user's friends list
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friend.id)
          .set({
        ...friend.toMap(),
        'fcmToken': friend.fcmToken, // Save the FCM token
      } );

      await _sendFriendRequestNotification(friend.fcmToken);
      // Add to the friend's friends list
      await _firestore
          .collection('users')
          .doc(friend.id)
          .collection('friends')
          .doc(currentUserId)
          .set({
        'id': currentUserId,
        'name': _userName,
        'profilePic': 'https://via.placeholder.com/50',
        'events': 'No upcoming events',
        'fcmToken': _fcmToken,
      });

      // Step 5: Update local state and notify listeners
      _friends.add(friend); // Add to local list
      notifyListeners();

      print("Friend added successfully. Current user name: $_userName");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Friend added successfully!")),
      );
    } catch (e) {
      print("Error adding friend: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add friend: $e")),
      );
    }
  }
  Future<void> _sendFriendRequestNotification(String? friendFcmToken) async {
    if (friendFcmToken == null || friendFcmToken.isEmpty) {
      print("FCM token is empty. Cannot send notification.");
      return;
    }

    try {
      final message = {
        "notification": {
          "title": "You have a new friend request",
          "body": "You have been added as a friend!",
        },
        "to": friendFcmToken,
      };

      // Send notification using FCM
      final response = await FirebaseFirestore.instance.collection('fcm').add(message);

      print("Friend notification sent. Response: $response");
    } catch (e) {
      print("Error sending friend notification: $e");
    } } }
