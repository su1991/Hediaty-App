import 'package:flutter/cupertino.dart';
import '../database/databasehelp.dart';
import 'package:mbileprogrammingproject/models/giftdetailsmodel.dart';

class GiftController extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  /// Save a gift to the database
  Future<int> saveGift(Gift gift) async {
    try {
      print('Attempting to save gift: ${gift.toMap()}');
      // Convert Gift object to Map and save
      final giftMap = gift.toMap();
      final result = await _databaseHelper.insertGift(giftMap);
      print('Gift saved successfully with ID: $result');
      return result;
    } catch (e) {
      print('Error saving gift: $e');
      return -1; // Indicate failure
    }
  }

  /// Fetch all gifts for a specific event
  Future<List<Gift>> getAllGifts() async {
    try {
      // Fetch all gifts from the database
      final allGifts = await _databaseHelper.getAllGifts();

      // Print fetched gifts for debugging
      print('Fetched ${allGifts.length} gifts successfully.');

      // Return the list of gifts
      return allGifts; // No need to map again, as `allGifts` is already a List<Gift>
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }


  /// Fetch all gifts that are available to add (i.e., not yet associated with the event)
  Future<List<Gift>> getAvailableGiftsForEvent(int eventId) async
  {
    final db = await _databaseHelper.database;

    // Fetch gifts with eventId not equal to the one specified or eventId = 0 (unassigned)
    final query = '''
    SELECT * FROM Gifts
    WHERE eventId IS NULL OR eventId = 0 OR eventId != ?
  ''';

    final result = await db.rawQuery(query, [eventId]);

    print('Query result: $result'); // Debugging output to see the result

    return result.map((giftMap) => Gift.fromMap(giftMap)).toList();
  }


  /// Add a new gift to the database and notify listeners
  Future<void> addGift({
    required String name,
    required String category,
    required String status,
    required int eventId,
    required String description,
    required double price,
  }) async {
    try {
      print('Creating a new gift...');
      final newGift = Gift(
        id: null, // ID will be auto-assigned by the database
        name: name,
        category: category,
        status: status,
        eventId: eventId,
        description: description,
        price: price,
      );
      final result = await saveGift(newGift);
      if (result != -1) {
        print('Gift added successfully.');
        notifyListeners(); // Notify listeners to update the UI
      } else {
        print('Failed to add gift.');
      }
    } catch (e) {
      print('Error adding new gift: $e');
    }
  }

  /// Add a gift to the event
  Future<void> addGiftToEvent({
    required String name,
    required String category,
    required String status,
    required int eventId,
    required String description,
    required double price,
  }) async {
    try {
      print('Creating a new gift for the event...');
      final newGift = Gift(
        id: null, // ID will be auto-assigned by the database
        name: name,
        category: category,
        status: status,
        eventId: eventId,
        description: description,
        price: price,
      );
      final result = await saveGift(newGift); // Save the gift to the database
      if (result != -1) {
        print('Gift added successfully to the event.');
        notifyListeners(); // Notify listeners to update the UI
      } else {
        print('Failed to add gift to event.');
      }
    } catch (e) {
      print('Error adding gift to event: $e');
    }
  }

  Future<void> deleteGift(int giftId) async {
    try {
      await _databaseHelper.deleteGift(giftId);
      print('Gift deleted successfully');
    } catch (e) {
      print('Error deleting gift: $e');
      throw Exception('Error deleting gift');
    }
  }
}
