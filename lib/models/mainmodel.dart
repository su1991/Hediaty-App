import 'package:mbileprogrammingproject/database/datav2.dart';

import 'eventlistmodel.dart';
import 'giftdetailsmodel.dart';
class Friend
{
  final String name;
  final String profilePic;
  final String events;
  final String  id;
  final String fcmToken;

  Friend({
    required this.name,
    required this.profilePic,
    required this.events,
    required this. id,
    required this.fcmToken,
  });



  factory Friend.fromMap(Map<String, dynamic> map)
  {
    return Friend(
      id: map['id'] ?? '',  // Ensure you provide a default value or handle null properly
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      events: map['events'] ?? '', fcmToken: '',
    );
  }


  Map<String, dynamic> toMap()
  {
    return {
      'name': name,
      'profilePic': profilePic,
      'events': events,
      'id': id,
    };
  }
}


class MainViewState
{
  final bool isLoggedIn;
  final int selectedIndex;

  MainViewState({
    required this.isLoggedIn,
    required this.selectedIndex,
  });

  MainViewState copyWith({bool? isLoggedIn, int? selectedIndex}) {
    return MainViewState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }


}

class MainModel {
  final DatabaseHelperv2 dbHelper = DatabaseHelperv2();

  // Fetch user data
  Future<User?> getUser(String email) async {
    return await dbHelper.getUserByEmail(email);
  }

  // Fetch events for the current user
  Future<List<Event>> getEvents(int userId) async {
    return await dbHelper.getEventsForUser();
  }

  // Fetch gifts for a specific event
  Future<List<Gift>> getGifts(String eventId) async {
    return await DatabaseHelperv2.getGiftsByEventId(eventId);
  }
}
