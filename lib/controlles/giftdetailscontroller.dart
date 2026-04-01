import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/models/giftdetailsmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbileprogrammingproject/database/dataV2.dart';

class GiftController extends ChangeNotifier
{
  final DatabaseHelperv2 _databaseHelper = DatabaseHelperv2();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Gift> gifts = [];
  List<Gift> eventGifts = [];
  bool isLoading = false;
  Map<String, List<Gift>> selectedGiftsPerEvent = {};
  bool isSyncingGifts = false; // Flag to prevent redundant syncs

  // Get the list of selected gifts for a specific event
  List<Gift> getSelectedGiftsForEvent(String eventId)
  {
    return selectedGiftsPerEvent[eventId] ?? [];
  }

  // Add a gift to the selected list for a specific event
  Future<void> addGiftToSelectedList(String userId, String eventId, Gift gift) async
  {
    try
    {
      // Reference to the Firestore collection for this specific event
      CollectionReference giftCollectionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts');

      // Add the gift data to Firestore, Firestore will automatically generate a gift ID
      DocumentReference newGiftRef = await giftCollectionRef.add({
        'name': gift.name,
        'description': gift.description,
        'category': gift.category,
        'price': gift.price,
        'status': gift.status,
        'eventId': eventId,  // Store the event ID in the gift document
      });

      // You can update the gift object with the generated ID if needed
      String generatedGiftId = newGiftRef.id;

      // Optionally, you can update the gift with the generated ID in Firestore
      await newGiftRef.update({'id': generatedGiftId});

      // Update the selectedGiftsPerEvent map with the new gift for this event
      if (selectedGiftsPerEvent[eventId] == null) {
        selectedGiftsPerEvent[eventId] = [];
      }
      gift.id = generatedGiftId;  // Assign the generated ID to the gift
      selectedGiftsPerEvent[eventId]?.add(gift);  // Add the gift to the local list for this event

      notifyListeners();  // Notify listeners to update the UI

      print('Gift added to event successfully with ID: $generatedGiftId');
    } catch (e) {
      print('Error adding gift to event: $e');
    }
  }



  // Remove a gift from the selected list for a specific event
  void removeGiftFromSelectedList(String eventId, Gift gift) {
    selectedGiftsPerEvent[eventId]?.remove(gift);
    notifyListeners();
  }

  // Fetch event-specific gifts from Firestore
  Future<void> getEventGifts(String eventId) async {
    try {
      isLoading = true;
      notifyListeners();
      eventGifts = await getAvailableGiftsForEvent(eventId);
      notifyListeners();
    } catch (e) {
      print('Error fetching gifts for event ID $eventId: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Save a gift to both the local database (SQLite) and Firestore
  Future<int?> saveGift(Gift gift) async
  {
    try {
      print('saveGift called for gift: ${gift.name} with ID: ${gift.id}');

      // Save to local SQLite
      final result = await _databaseHelper.insertGift(gift.toMap(), gift.eventId!);
      print('Gift saved locally with ID: $result');

      // Check Firestore to prevent duplicates
      final existingGiftQuery = await _firestore
          .collection('gifts')
          .where('giftId', isEqualTo: gift.id)
          .get();

      if (existingGiftQuery.docs.isEmpty)
      {
        // Save to Firestore if it doesn't exist
        final docRef = await _firestore.collection('gifts').add(gift.toMap());
        print('Gift saved to Firestore with ID: ${docRef.id}');
      } else {
        print('Gift with ID ${gift.id} already exists in Firestore. Skipping save.');
      }

      return result;
    } catch (e) {
      print('Error saving gift: $e');
      return -1;
    }
  }

  // Add a gift to an event in Firestore
  Future<void> addGiftToEvent({
    required String name,
    required String category,
    required String status,
    required String eventId,
    required String description,
    required double price,
    required String giftId,
    required String userId,
  }) async {
    try {
      // Check if gift already exists in the event
      final existingGiftSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .get();

      if (existingGiftSnapshot.exists) {
        print('Gift already added to event $eventId');
        return; // Prevent adding the same gift again
      }

      final newGift = Gift(
        id: giftId,
        name: name,
        description: description,
        category: category,
        price: price,
        status: status,
        eventId: eventId,
      );

      // Save gift under the correct path in Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .set(newGift.toMap()); // Save the gift data

      print('Gift "$name" successfully added to event ID: $eventId under user $userId');
    } catch (e) {
      print('Error adding gift "$name" to event ID $eventId: $e');
    }
  }

  // Remove a gift from an event
  Future<void> removeGiftFromEvent(String eventId, String giftId) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'gifts': FieldValue.arrayRemove([giftId]),
      });

      await deleteGift(int.tryParse(giftId) ?? 0);
      print('Gift with ID "$giftId" removed from event ID: $eventId');
    } catch (e) {
      print('Error removing gift from event ID $eventId: $e');
    }
  }

  // Delete a gift from both SQLite and Firestore
  Future<void> deleteGift(int giftId) async {
    try {
      await _databaseHelper.deleteGift(giftId);
      await _firestore.collection('gifts').doc(giftId.toString()).delete();
      print('Gift with ID $giftId deleted.');
    } catch (e) {
      print('Error deleting gift with ID $giftId: $e');
    }
  }

  // Refresh event-specific gifts
  void refreshGifts(String eventId) {
    getEventGifts(eventId);
    notifyListeners();
  }

  // Load all gifts
  Future<void> loadAllGifts() async {
    try {
      gifts = await getAllGifts();
      notifyListeners();
    } catch (e) {
      print('Error loading all gifts: $e');
      gifts = [];
      notifyListeners();
    }
  }

  // Fetch all gifts from SQLite and Firestore
  Future<List<Gift>> getAllGifts() async {
    try {
      final allGifts = await _databaseHelper.getAllGifts();
      if (allGifts.isEmpty) {
        await syncGiftsFromFirestore();
        return await _databaseHelper.getAllGifts();
      }
      return allGifts;
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }

  // Sync gifts from Firestore and save them to SQLite
  Future<void> syncGiftsFromFirestore() async {
    if (isSyncingGifts) {
      print('Sync already in progress. Skipping.');
      return;
    }
    isSyncingGifts = true;

    try {
      final gifts = await _firestore.collection('gifts').get();
      for (var doc in gifts.docs) {
        final giftData = doc.data();
        final giftId = doc.id;

        // Check if the gift exists locally
        final existingGift = await _databaseHelper.getGiftById(giftId);
        if (existingGift != null) {
          continue; // Skip existing gifts
        }

        final gift = Gift.fromMap(giftData);
        await _databaseHelper.insertGift(gift.toMap(), gift.eventId!);
      }
      print('Gifts synced successfully from Firestore.');
    } catch (e) {
      print('Error syncing gifts from Firestore: $e');
    } finally {
      isSyncingGifts = false;
    }
  }

  // Fetch available gifts for an event
  Future<List<Gift>> getAvailableGiftsForEvent(String eventId) async {
    try {
      List<Gift> gifts = await DatabaseHelperv2.getGiftsByEventId(eventId);
      if (gifts.isEmpty) {
        final snapshot = await _firestore
            .collection('gifts')
            .where('eventId', isEqualTo: eventId)
            .get();

        gifts = snapshot.docs.map((doc) {
          return Gift.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
      }
      return gifts;
    } catch (e) {
      print('Error fetching gifts for event ID $eventId: $e');
      return [];
    }
  }
}
