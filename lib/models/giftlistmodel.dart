class Gift {
  String name;
  String category;
  String status;

  Gift({
    required this.name,
    required this.category,
    required this.status,
  });

  // Optional: Add helper methods if needed
  Map<String, String> toMap() {
    return {
      'name': name,
      'category': category,
      'status': status,
    };
  }

  @override
  String toString() => 'Gift(name: $name, category: $category, status: $status)';
}
