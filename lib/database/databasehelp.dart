import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/eventlistmodel.dart';
import '../models/giftdetailsmodel.dart';

class User
{
  final int id;
  final String name;
  final String email;
  final String preferences;
  final String password;

  User(
      {
    required this.id,
    required this.name,
    required this.email,
    required this.preferences,
    required this.password,
  });

  factory User.fromMap(Map<String, dynamic> map)
  {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      preferences: map['preferences'] ?? '', // Handle null preferences
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap()
  {
    return {
      'id': id,
      'name': name,
      'email': email,
      'preferences': preferences,
      'password': password,
    };
  }
}

class DatabaseHelper
{
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'Hediaty.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Users table
    await db.execute(''' 
    CREATE TABLE Users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      preferences TEXT,
      password TEXT  NOT NULL
    )
    ''');

    // Create Events table
    await db.execute(''' 
    CREATE TABLE Events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      date TEXT,
      location TEXT,
      description TEXT,
      userId INTEGER,
      FOREIGN KEY(userId) REFERENCES Users(id) ON DELETE CASCADE
    )
    ''');

    // Create Gifts table (linked to events by eventId)
    await db.execute(''' 
    CREATE TABLE Gifts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      category TEXT,
      price DOUBLE,
      status TEXT,
      eventId INTEGER,
      FOREIGN KEY(eventId) REFERENCES Events(id) ON DELETE CASCADE
    )
    ''');

    // Create Friends table (many-to-many relationship between users)
    await db.execute(''' 
    CREATE TABLE Friends (
      userId INTEGER,
      friendId INTEGER,
      PRIMARY KEY (userId, friendId),
      FOREIGN KEY(userId) REFERENCES Users(id) ON DELETE CASCADE,
      FOREIGN KEY(friendId) REFERENCES Users(id) ON DELETE CASCADE
    )
    ''');

  }

  // User operations
  Future<void> insertUser(User user) async
  {
    final db = await DatabaseHelper._instance.database;

    try {
      await db.insert(
        'Users',
        user.toMap(),  // Convert the user to a map before insertion
        conflictAlgorithm: ConflictAlgorithm.ignore, // Avoid duplicate email insertion
      );
      print('User inserted successfully!');
    } catch (e) {
      print('Error during sign-up: $e');
    }
  }



  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    print('Fetching user by email: $email'); // Debugging

    // Check if the database has the expected structure
    final List<Map<String, dynamic>> maps = await db.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty)
    {
      print('User found: ${maps.first}'); // Debugging
      return User.fromMap(maps.first);  // Ensure User.fromMap exists and is working
    } else {
      print('No user found for email: $email'); // Debugging
      return null;
    }
  }



  Future<int> updateUserPreferences(int userId, String preferences) async
  {
    final db = await database;
    return await db.update
      (

      'Users',
      {
        'preferences': preferences},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // Event operations
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    return await db.insert('Events', event);
  }

  Future<List<Map<String, dynamic>>> getUserEvents(int userId) async {
    final db = await database;
    return db.query('Events', where: 'userId = ?', whereArgs: [userId]);
  }

  // Gift operations
  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db.insert('Gifts', gift);
  }

  Future<void> deleteGift(int giftId) async {
    final db = await database;
    await db.delete('Gifts', where: 'id = ?', whereArgs: [giftId]);
  }

  Future<List<Map<String, dynamic>>> getEventGifts(int eventId) async {
    final db = await database;
    return db.query(
      'Gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
  }

  Future<int> updateGift(Gift gift) async {
    final db = await database;
    return await db.update(
      'Gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  // Adding a new gift to the event
  Future<void> addGift(String name, String category, String status, double price, int? eventId) async {
    final db = await database;

    final newGift = Gift(
      name: name,
      category: category,
      status: status,
      eventId: eventId ?? 0, // Default to 0 if eventId is null
      description: '',
      price: price,
      id: 0, // Let the database generate the ID
    );

    await db.insert('Gifts', newGift.toMap());
  }

  // Get all gifts
  Future<List<Gift>> getAllGifts() async {
    try {
      final db = await database;

      // Fetch all gifts from the 'Gifts' table
      final List<Map<String, dynamic>> giftMaps = await db.query('Gifts');

      if (giftMaps.isEmpty) {
        print('No gifts found.');
        return [];
      }

      // Return a list of Gift objects mapped from the database results
      return giftMaps.map((giftMap) => Gift.fromMap(giftMap)).toList();
    } catch (e) {
      print('Error fetching all gifts: $e');
      return [];
    }
  }

  // Fetch available gifts for a specific event (gifts not yet associated with the event)
  Future<List<Gift>> getAvailableGiftsForEvent(int eventId) async
  {
    final db = await database;

    // Query gifts that are unassigned or assigned to a different event
    final result = await db.rawQuery('''
    SELECT * FROM Gifts
    WHERE eventId IS NULL OR eventId != ?
  ''', [eventId]);
    print('Available Gifts Query Result: $result');

    return result.map((map) => Gift.fromMap(map)).toList();
  }

  // Friend operations
  Future<int> addFriend(int userId, int friendId) async {
    final db = await database;
    return db.insert('Friends', {
      'userId': userId,
      'friendId': friendId,
    });
  }

  Future<List<Map<String, dynamic>>> getUserFriends(int userId) async {
    final db = await database;
    return db.query('Friends', where: 'userId = ?', whereArgs: [userId]);
  }

  Future<int> removeFriend(int userId, int friendId) async {
    final db = await database;
    return db.delete(
      'Friends',
      where: 'userId = ? AND friendId = ?',
      whereArgs: [userId, friendId],
    );
  }

  // Clear all tables (for testing)
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('Users');
    await db.delete('Events');
    await db.delete('Gifts');
    await db.delete('Friends');
  }

  Future<void> clearUsersTable() async {
    final db = await database;
    await db.delete('Users');
  }

  // Get all events for a user
  Future<List<Event>> getEventsForUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('Events');

    return List.generate(maps.length, (i) {
      return Event.fromMap(maps[i]);
    });
  }

  // Fetch all gifts for a specific event
  Future<List<Gift>> getGiftsForEvent(int eventId) async {
    final db = await database;
    final result = await db.query(
      'Gifts',
      where: 'eventId = ?',
      whereArgs: [eventId], // Fetch gifts only for the specified event
    );

    return result.map((map) => Gift.fromMap(map)).toList();
  }
}
