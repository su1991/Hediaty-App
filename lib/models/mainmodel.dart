
class Friend
{
  final String name;
  final String profilePic;
  final String events;

  Friend({
    required this.name,
    required this.profilePic,
    required this.events,
  });


  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      name: map['name'],
      profilePic: map['profilePic'],
      events: map['events'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'profilePic': profilePic,
      'events': events,
    };
  }
}


class MainViewState {
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
