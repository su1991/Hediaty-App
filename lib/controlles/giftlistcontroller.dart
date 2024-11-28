import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/models/giftlistmodel.dart';

class GiftlistController extends ChangeNotifier {
  List<Gift> _gifts = [];
  String _sortCriteria = 'name';

  List<Gift> get gifts => _gifts;

  String get sortCriteria => _sortCriteria;

  void addGift(String name, String category, String status) {
    _gifts.add(Gift(name: name, category: category, status: status));
    notifyListeners();
  }

  void editGift(int index, String name, String category, String status) {
    if (index >= 0 && index < _gifts.length) {
      _gifts[index] = Gift(name: name, category: category, status: status);
      notifyListeners();
    }
  }

  void deleteGift(int index) {
    if (index >= 0 && index < _gifts.length) {
      _gifts.removeAt(index);
      notifyListeners();
    }
  }

  void sortGifts(String criteria) {
    _sortCriteria = criteria;
    if (criteria == 'name') {
      _gifts.sort((a, b) => a.name.compareTo(b.name));
    } else if (criteria == 'category') {
      _gifts.sort((a, b) => a.category.compareTo(b.category));
    } else if (criteria == 'status') {
      _gifts.sort((a, b) => a.status.compareTo(b.status));
    }
    notifyListeners();
  }
}
