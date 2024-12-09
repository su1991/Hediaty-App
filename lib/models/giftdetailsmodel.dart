class Gift {
  final int ? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final int ? eventId;


  Gift({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.eventId,

  });

  // Mapping Map<String, dynamic> to Gift
  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      eventId: map['eventId'],
       // Handle null if necessary
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
  Gift copyWith({
    int? id,
    String? name,
    String? category,
    String? status,
    int? eventId,

  }) {
    return Gift
      (
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId, description: '', price: 0
    );
  }
}
