import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/eventlistmodel.dart';
import '../models/giftdetailsmodel.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String preferences;
  final String password;
  final String profilePic;
  final String events;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.preferences,
    required this.password,
    this.profilePic = '', // Default value if profilePic is optional
    this.events = '',
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? 0,
      name: map['name'],
      email: map['email'],
      preferences: map['preferences'] ?? '', // Handle null preferences
      password: map['password'],
      profilePic: map['profilePic'] ?? '',
      events: map['events'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
      'password': password,
      'profilePic': profilePic,
      'events': events,
    };
  }
}

class DatabaseHelperv2 {
  static final DatabaseHelperv2 _instance = DatabaseHelperv2._internal();
  static DatabaseHelperv2 get instance => _instance;
  Database? _database;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory DatabaseHelperv2() => _instance;

  DatabaseHelperv2._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async

  {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'Hediaty_v2.db');
    await deleteDatabase(path);
    final database = await openDatabase(
      path,
      version: 3,  // This should be set to the correct version
      onCreate: _onCreate,

    );



    int version = await database.getVersion();
    print('Database version: ${await database.getVersion()}');



    return database;
  }





  Future<void> _onCreate(Database db, int version) async
  {
    // Create Users table with 'user_id' instead of 'id'
    await db.execute('''  
    CREATE TABLE IF NOT EXISTS Users (
      user_id TEXT PRIMARY KEY ,  
      name TEXT,
      email TEXT UNIQUE,
      preferences TEXT,
      password TEXT,
      profilePic TEXT DEFAULT '',
      events TEXT DEFAULT ''
    )
    ''');

    // Create other necessary tables (Events, Gifts, Friends, etc.)
    await db.execute(''' 
    CREATE TABLE IF NOT EXISTS Events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      date TEXT,
      location TEXT,
      description TEXT,
      userId INTEGER,
      FOREIGN KEY(userId) REFERENCES Users(id) ON DELETE CASCADE
    )
    ''');

    await db.execute(''' 
    CREATE TABLE IF NOT EXISTS Gifts
    (
      id TEXT,
      name TEXT,
      description TEXT,
      category TEXT,
      price DOUBLE,
      status TEXT,
      eventId TEXT, -- eventId is TEXT and nullable
      FOREIGN KEY(eventId) REFERENCES Events(id) ON DELETE CASCADE
    )
    ''');

    await db.execute(''' 
    CREATE TABLE IF NOT EXISTS Friends (
      userId INTEGER,
      friendId INTEGER,
      PRIMARY KEY (userId, friendId),
      FOREIGN KEY(userId) REFERENCES Users(id) ON DELETE CASCADE,
      FOREIGN KEY(friendId) REFERENCES Users(id) ON DELETE CASCADE
    )
    ''');


  }





  Future<void> cacheUserData(String userId, Map<String, String> userData) async {
    final db = await database;

    // Check if the user already exists in the database
    final existingUser = await db.query(
      'Users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (existingUser.isNotEmpty) {
      // Update the user data if the user already exists
      await db.update(
        'Users',
        {
          'name': userData['name'],
          'email': userData['email'],
          'preferences': userData['preferences'],
          'password': userData['password'],
        },
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } else {
      // Insert new user data if the user doesn't exist
      await db.insert(
        'Users',
        {
          'user_id': userId,
          'name': userData['name'],
          'email': userData['email'],
          'preferences': userData['preferences'],
          'password': userData['password'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> syncUserFromFirestore(String email) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(email).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        User user = User.fromMap(userData);
        await insertUser(user);
      } else {
        print('No user found in Firestore with email $email');
      }
    } catch (e) {
      print('Error syncing user from Firestore: $e');
    }
  }

  Future<void> syncUserToFirestore(String email) async {
    try {
      final user = await getUserByEmail(email);
      if (user != null) {
        await _firestore.collection('users').doc(email).set(user.toMap());
        print('User data synced to Firestore');
      } else {
        print('No user found with email $email');
      }
    } catch (e) {
      print('Error syncing user to Firestore: $e');
    }
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    try {
      await db.insert(
        'Users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      print('User inserted successfully into SQLite!');
    } catch (e) {
      print('Error inserting user: $e');
    }
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Add other methods for syncing events, gifts, friends, etc. as per your code

  Future<void> loginUser(String email, String password) async {
    try {
      final user = await getUserByEmail(email);

      if (user != null && user.password == password) {
        print('Login successful for ${user.name}');
        final friends = await loadUserFriends(user.id);

        if (friends.isNotEmpty) {
          print('Friends list loaded: $friends');
        } else {
          print('No friends found for this user.');
        }
      } else {
        print('Login failed: Invalid credentials');
      }
    } catch (e) {
      print('Error logging in: $e');
    }
  }

  Future<List<Map<String, Object?>>> loadUserFriends(int userId) async {
    final db = await database;

    // Query all friends associated with the userId
    final friends = await db.query('Friends', where: 'userId = ?', whereArgs: [userId]);

    if (friends.isEmpty) {
      return [];
    }

    return friends;
  }

  Future<Map<String, dynamic>?> getUserData(String email) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return maps.first; // Return the first match if found
    } else {
      return null; // No user found
    }
  }

  Future<List<Gift>> getGiftsForEvent(String? eventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );

    return List.generate(maps.length, (i) {
      return Gift.fromMap(maps[i]);
    });
  }

  static Future<List<Gift>> getGiftsByEventId(String? eventId) async {
    final db = await DatabaseHelperv2().database;

    // Query gifts for the specified eventId
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );

    // Convert the result to a list of Gift objects
    return List.generate(maps.length, (i) => Gift.fromMap(maps[i]));
  }

  Future<List<Event>> getEventsForUser() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('Events');

    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  Future<int?> insertGift(Map<String, dynamic> giftMap, String? eventId) async {
    final db = await database;

    // Ensure the giftMap contains the correct eventId
    giftMap['eventId'] = eventId; // Set the eventId explicitly

    // Insert the gift with the associated eventId
    final id = await db.insert(
      'Gifts',
      giftMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return id;
  }
  Future<Gift?> getGiftById(String giftId) async {
    final db = await database; // Assuming you have a reference to your database
    final res = await db.query(
      'gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );

    if (res.isNotEmpty) {
      return Gift.fromMap(res.first); // Assuming you have a `fromMap` method in your `Gift` class
    }
    return null; // Return null if no gift with that ID is found
  }

  Future<List<Gift>> getAllGifts() async
  {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('Gifts');
    print("Fetched data from database: $maps");
    return List.generate(maps.length, (i) {
      return Gift.fromMap(maps[i]);
    });
  }

  Future<void> deleteGift(int giftId) async {
    final db = await database;

    await db.delete(
      'Gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }
}