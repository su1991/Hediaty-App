import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:mbileprogrammingproject/models/pledgedmodel.dart';

class GiftpledgedController extends ChangeNotifier
{
  late Database _database;
  List<Gift> _gifts = [];

  List<Gift> get gifts => _gifts;

  // Initialize the database
  Future<void> initDatabase() async
  {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gifts.db');

    _database = await openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE gifts(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            friendName TEXT,
            dueDate TEXT,
            isPending INTEGER
          )
        ''');
      },
      version: 1,
    );
    await _loadGifts();
  }

  // Load gifts from the database
  Future<void> _loadGifts() async {
    final List<Map<String, dynamic>> maps = await _database.query('gifts');
    _gifts = List.generate(maps.length, (i) {
      return Gift(
        name: maps[i]['name'],
        friendName: maps[i]['friendName'],
        dueDate: DateTime.parse(maps[i]['dueDate']),
        isPending: maps[i]['isPending'] == 1,
      );
    });
    notifyListeners();
  }

  // Add a new gift to the database and the local list
  Future<void> addGift(Gift gift) async
  {
    final id = await _database.insert('gifts', gift.toMap());
    _gifts.add(Gift(
      name: gift.name,
      friendName: gift.friendName,
      dueDate: gift.dueDate,
      isPending: gift.isPending,
    ));
    notifyListeners();
  }

  // Modify the status of a gift (mark as completed or pending)
  Future<void> modifyGift(Gift gift) async
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
  Future<void> deleteGift(Gift gift) async
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
