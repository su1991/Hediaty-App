import 'package:flutter/material.dart';
import 'package:mbileprogrammingproject/models/eventlistmodel.dart';

class EventController extends ChangeNotifier
{
  List<Event> _events = [
    Event(name: 'Birthday Party', category: 'Personal', status: 'Upcoming'),
    Event(name: 'Conference', category: 'Work', status: 'Current'),
    Event(name: 'Wedding', category: 'Personal', status: 'Past'),
  ];

  List<Event> get events => _events;

  String _dropdownValue = 'Category';
  String get dropdownValue => _dropdownValue;

  void setDropdownValue(String value)
  {
    _dropdownValue = value;
    notifyListeners();
  }


  void addEvent() {
    _events.add(Event(name: 'New Event', category: 'General', status: 'Upcoming'));
    notifyListeners();
  }

  void deleteEvent(int index) {
    _events.removeAt(index);
    notifyListeners();
  }

  void editEvent(int index, String name, String category, String status) {
    _events[index] = Event(name: name, category: category, status: status);
    notifyListeners();
  }

  void sortEvents(String criterion)
  {
    switch (criterion) {
      case 'Category':
        _events.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'Status':
        _events.sort((a, b) => a.status.compareTo(b.status));
        break;
      case 'Name':
        _events.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    notifyListeners();
  }
}
