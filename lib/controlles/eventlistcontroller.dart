import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/models/eventlistmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mbileprogrammingproject/controlles/giftdetailscontroller.dart';





class EventController extends ChangeNotifier
{
  late List<Event> events = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GiftController giftController = GiftController();

  String _dropdownValue = 'Category';
  String get dropdownValue => _dropdownValue;

  Future<void> fetchEvents(String userId) async
  {
    try
    {

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .get();

      // Fetch events and remove duplicates
      events = snapshot.docs.map((doc) {
        return Event.fromFirestore(doc);
      }).toList();

      // Remove duplicates using a Set to ensure unique events
      events = events.toSet().toList();

      // Only notify listeners if the events list has been updated
      if (events.isNotEmpty) {
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching events: $e');
    }
  }


  void sortEvents(String criterion)
  {
    switch (criterion) {
      case 'Category':
        events.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Status':
        events.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 'Name':
        events.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    notifyListeners();
  }

  Future<List<Event>> getAllEvents() async
  {
    return events;
  }

  void setDropdownValue(String value)
  {
    _dropdownValue = value;
    notifyListeners();
  }

  Future<void> addEvent(String userId, Event newEvent) async
  {
    try
    {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .add({
        'name': newEvent.name,
        'category': newEvent.category,
        'status': newEvent.status,
      });

      final addedEvent = Event(
        id: docRef.id,
        name: newEvent.name,
        category: newEvent.category,
        status: newEvent.status,
        gifts: newEvent.gifts,
      );

      // Call the addGiftToEvent method for each gift
      if (newEvent.gifts.isNotEmpty) {
        for (var gift in newEvent.gifts) {
          String giftId = gift.id?.toString() ?? '';
          await giftController.addGiftToEvent(
            name: gift.name,
            category: gift.category,
            status: gift.status,
            eventId: docRef.id,  // Firestore event ID
            description: gift.description,
            price: gift.price,
            giftId: giftId, userId: userId,  // If gift.id is empty, pass an empty string
          );
        }
      }


      events.add(addedEvent);
      notifyListeners();

      print('Event added with ID: ${docRef.id}');
    } catch (e) {
      print('Error adding event: $e');
    }
  }



  Future<void> editEvent(String userId, int index, String name, String category, String status) async
  {
    final event = events[index];
    try {
      if (event.id != null && event.id!.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(event.id)
            .update({
          'name': name,
          'category': category,
          'status': status,
        });

        events[index] = Event(
          id: event.id,
          name: name,
          category: category,
          status: status,
        );
        notifyListeners();

        print('Event updated successfully');
      } else {
        print('Event ID is empty or null');
      }
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  Future<void> deleteEvent(String userId, int index) async
  {
    final event = events[index];
    try {
      if (event.id != null && event.id!.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('events')
            .doc(event.id)
            .delete();

        events.removeAt(index);
        notifyListeners();

        print('Event deleted');
      } else {
        print('Event ID is empty or null');
      }
    } catch (e) {
      print('Error deleting event: $e');
    }
  }
}

