class pGift
{
  final String name;
  final String friendName;
  final String EventName;
  bool isPending;
  final String userId;

  // Include userId

  // Constructor with all fields
  pGift({
    required this.name,
    required this.friendName,
    required this.EventName,
    required this.isPending,
    required this.userId,
    // Add userId here
  });

  // Convert object to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'friendName': friendName,
      'EventName': EventName,
      'isPending': isPending ? 1 : 0,
      'userId': userId,
      // Include userId in the map
    };
  }

  // Factory constructor to create an object from a map
  factory pGift.fromMap(Map<String, dynamic> map) {
    return pGift(
      name: map['name'],
      friendName: map['friendName'],
      EventName: map['EventName'],
      isPending: map['isPending'] == 1,
      userId: map['userId'],
      // Map the userId field
    );
  }
}
