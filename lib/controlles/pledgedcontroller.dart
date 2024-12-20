import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mbileprogrammingproject/models/pledgedmodel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class GiftpledgedController extends ChangeNotifier
{
  late Database _database;
  List<pGift> _gifts = [];

  List<pGift> get gifts => _gifts;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();


  // Initialize the database
  Future<void> initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gifts.db');

    // For development: Delete the database if it already exists


    _database = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute('''
        CREATE TABLE gifts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          friendName TEXT,
          isPending INTEGER,
          EventName TEXT,
          userId TEXT
        )
      ''');
      },
      version: 1,
    );

    await _loadGifts();
  }


  // Load gifts from the database
  // Modify the query to include userId to fetch only the current user's gifts
  Future<List<pGift>> _loadGifts() async
  {
    final currentUser = FirebaseAuth.instance.currentUser;

    // Debugging: Check if the current user is logged in
    if (currentUser == null) {
      print('No user is currently logged in.');
      return []; // Return an empty list if no user is logged in
    }

    // Debugging: Log the user ID being used for the query
    print('Fetching gifts for userId: ${currentUser.uid}');

    try {
      // Clear the existing gifts before loading new ones
      _gifts.clear();

      // Query the database for gifts specific to the current user
      final List<Map<String, dynamic>> maps = await _database.query(
        'gifts',
        where: 'userId = ?', // Filter by userId
        whereArgs: [currentUser.uid],
      );

      // Debugging: Log the number of gifts retrieved from the database
      print('Found ${maps.length} gifts for userId: ${currentUser.uid}');

      // If there are no gifts found, return an empty list
      if (maps.isEmpty) {
        print('No gifts found for userId: ${currentUser.uid}');
        return []; // Return an empty list if no gifts are found
      }

      // Map the query result to a list of pGift objects
      _gifts = List.generate(maps.length, (i) {
        print('Gift loaded: ${maps[i]}'); // Debugging: Log each gift being loaded
        return pGift(
          name: maps[i]['name'],
          friendName: maps[i]['friendName'],
          EventName: maps[i]['EventName'],
          isPending: maps[i]['isPending'] == 1,
          userId: maps[i]['userId'],
        );
      });

      // Debugging: Confirm the list of gifts loaded
      print('Gifts loaded for userId: ${currentUser.uid}: $_gifts');

      notifyListeners();

      return _gifts;
    } catch (e) {
      // Debugging: Log any errors encountered during the database query
      print('Error loading gifts for userId: ${currentUser.uid}: $e');
      return []; // Return an empty list in case of an error
    }
  }


  Future<void> _showNotification(String friendName, String giftName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'gift_channel',
      'Gift Notifications',
      channelDescription: 'Notifications for pledged gifts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      'Gift Pledged',
      'You have pledged $giftName for $friendName!',
      notificationDetails,
    );
  }



  // Add a new gift to the database and the local list
  Future<void> addGift(pGift gift) async {
    // Debug: Log the gift details being added
    print('Attempting to add gift: ${gift.toMap()}');

    try {
      // Insert the gift into the database
      final int result = await _database.insert('gifts', gift.toMap());

      // Debug: Log the result of the database insertion
      if (result != 0) {
        print('Gift successfully added to database with ID: $result');
      } else {
        print('Failed to add gift to database.');
      }

      // Add the gift to the in-memory list
      _gifts.add(pGift(
        name: gift.name,
        friendName: gift.friendName,
        EventName: gift.EventName,
        isPending: gift.isPending,
        userId: gift.userId,
      ));
      await _showNotification(gift.friendName, gift.name);
      // Debug: Log the current list of gifts in memory
      print('Gift successfully added to memory. Current gifts: $_gifts');

      // Notify listeners of the change
      notifyListeners();
    } catch (e) {
      // Debug: Log any errors encountered
      print('Error adding gift to database: $e');
    }
  }



  // Modify the status of a gift (mark as completed or pending)
  Future<void> modifyGift(pGift gift) async
  {
    gift.isPending = !gift.isPending;
    await _database.update(
      'gifts',
      gift.toMap(),
      where: 'name = ? AND friendName = ?',
      whereArgs: [gift.name, gift.friendName],
    );
    await _loadGifts();  // Refresh the local list after the update
    notifyListeners();
  }

  // Delete a gift from the database and local list
  Future<void> deleteGift(pGift gift) async
  {
    await _database.delete(
      'gifts',
      where: 'name = ? AND friendName = ?',
      whereArgs: [gift.name, gift.friendName],
    );
    _gifts.remove(gift);
    notifyListeners();
  }
}