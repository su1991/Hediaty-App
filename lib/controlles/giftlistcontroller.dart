import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/models/giftdetailsmodel.dart';
import 'package:provider/provider.dart';

import 'giftdetailscontroller.dart';

class GiftlistController extends ChangeNotifier {
  final GiftController _giftController = GiftController();
  List<Gift> gifts = [];
  List<Gift> eventGifts = [];
  bool isLoading = false;
  Map<int, List<Gift>> selectedGiftsPerEvent = {}; // Track selected gifts by eventId

  // Get the list of selected gifts for a specific event
  List<Gift> getSelectedGiftsForEvent(int eventId) {
    return selectedGiftsPerEvent[eventId] ?? [];
  }

  // Add a gift to the selected list for a specific event
  void addGiftToSelectedList(int eventId, Gift gift) {
    if (!selectedGiftsPerEvent.containsKey(eventId)) {
      selectedGiftsPerEvent[eventId] = [];
    }
    if (!selectedGiftsPerEvent[eventId]!.contains(gift)) {
      selectedGiftsPerEvent[eventId]!.add(gift);
      notifyListeners();
    }
  }

  // Remove a gift from the selected list for a specific event
  void removeGiftFromSelectedList(int eventId, Gift gift) {
    selectedGiftsPerEvent[eventId]?.remove(gift);
    notifyListeners();
  }

  // Clear selected gifts for an event
  void clearSelectedGifts(int eventId) {
    selectedGiftsPerEvent[eventId] = [];
    notifyListeners();
  }

  // Edit an existing gift
  void editGift(int index, String name, String category, String status) {
    gifts[index] = gifts[index].copyWith(name: name, category: category, status: status);
    notifyListeners();
  }

  // Remove gift from the list of event gifts
  void removeGiftFromList(int giftId) {
    eventGifts.removeWhere((gift) => gift.id == giftId);
    notifyListeners();
  }

  // Delete a gift and show confirmation
  void _deleteGift(BuildContext context, int giftId) {
    final giftController = Provider.of<GiftlistController>(context, listen: false);

    // Remove the gift from the local list
    giftController.removeGiftFromList(giftId);

    // Optionally, show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gift removed from the list!')),
    );
  }

  // Load all gifts (no event ID needed)
  Future<void> loadAllGifts() async {
    try {
      gifts = await _giftController.getAllGifts();
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      print('Error loading all gifts: $e');
      gifts = []; // Reset the list in case of error
      notifyListeners(); // Notify listeners after error
    }
  }

  // Sort the gifts by a specified field (name, category, or status)
  void sortGifts(String sortBy) {
    if (sortBy == 'name') {
      gifts.sort((a, b) => a.name.compareTo(b.name));
    } else if (sortBy == 'category') {
      gifts.sort((a, b) => a.category.compareTo(b.category));
    } else if (sortBy == 'status') {
      gifts.sort((a, b) => a.status.compareTo(b.status));
    }
    notifyListeners();
  }

  // Load event-specific gifts
  Future<void> loadEventGifts(int eventId) async {
    try {
      print('Loading gifts for event ID: $eventId');
      eventGifts = await _giftController.getAvailableGiftsForEvent(eventId);

      // Ensure selected gifts are reset or managed correctly when loading event gifts
      if (!selectedGiftsPerEvent.containsKey(eventId)) {
        selectedGiftsPerEvent[eventId] = [];
      }

      notifyListeners(); // Notify listeners after updating the list
    } catch (e) {
      print('Error loading event gifts: $e');
      eventGifts = []; // In case of an error, reset to an empty list
      notifyListeners(); // Notify listeners after error
    }
  }

  // Refresh event-specific gifts
  void refreshGifts(int eventId) {
    loadEventGifts(eventId);
  }
}
