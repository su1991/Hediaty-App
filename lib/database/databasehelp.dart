import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String password;  // Add password field
  final String preferences;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.preferences,
  });

  // Constructor to create a User object from a map
  factory User.fromMap(Map<String, dynamic> map)
  {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],  // Ensure password is extracted
      preferences: map['preferences'],
    );
  }
}


class DatabaseHelper
{
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Singleton pattern to initialize the database once
  Future<Database> get database async {
    if (_database != null) return _database!;  // Return cached instance
    _database = await _initDatabase();  // Initialize it if not created yet
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

  Future<void> _onCreate(Database db, int version) async
  {
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT UNIQUE,
        password TEXT,  // Add password field
        preferences TEXT
      )
    ''');

    // Other table creation code...
  }

  // CRUD for Users
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;  // Get the database instance
    return db.insert('Users', user);
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;  // Get the database instance
    var result = await db.query(
      'Users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return User.fromMap(result.first);  // Return the user object
    }
    return null;
  }

  // CRUD for other tables...

  // CRUD for Events
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;  // Get the database instance
    return db.insert('Events', event);
  }

  insertGift(Map<String, dynamic> giftMap) {}

  getGifts() {}

// Other CRUD methods for `Events`, `Gifts`, `Friends`...

// Make sure every method that interacts with the database uses `final db = await database;`
}
