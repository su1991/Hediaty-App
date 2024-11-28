class Event {
  String name;
  String category;
  String status;

  Event({
    required this.name,
    required this.category,
    required this.status,
  });

  // Factory constructor for creating an Event object from JSON
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      status: json['status'] ?? '',
    );
  }

  // Method to convert an Event object to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'status': status,
    };
  }
}
