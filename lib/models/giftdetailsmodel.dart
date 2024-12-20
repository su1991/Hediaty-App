class Gift {
  String id; // Made id nullable
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final String? eventId; // eventId should be non-nullable as it’s essential

  Gift({
    required this.id, // id should be nullable
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.eventId, // Make sure eventId is required
  });

  // Mapping Map<String, dynamic> to Gift
  factory Gift.fromMap(Map<String, dynamic> map)
  {
    return Gift
      (
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      eventId: map['eventId'] != null ? map['eventId'].toString() : null,

    );
  }

  // Convert Gift object to Map<String, dynamic> for saving
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'eventId': eventId,
    };
  }

  // Modify the copyWith method to make sure it works as expected
  Gift copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? status,
    String? eventId,
    double? price, // Allow for price modification as well
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price, // Allow price modification
      status: status ?? this.status,
      eventId: eventId ?? this.eventId, // Ensure eventId is handled correctly
    );
  }
}
