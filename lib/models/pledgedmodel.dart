class Gift {
  final String name;
  final String friendName;
  final DateTime dueDate;
  bool isPending;

  Gift({
    required this.name,
    required this.friendName,
    required this.dueDate,
    this.isPending = true,
  });

  get category => null;

  get status => null;

  // Optional: Add a method to map the Gift into a database-friendly format
  Map<String, dynamic> toMap()
  {
    return {
      'name': name,
      'friendName': friendName,
      'dueDate': dueDate.toIso8601String(),
      'isPending': isPending ? 1 : 0,
    };
  }

  @override
  String toString() {
    return 'Gift(name: $name, friendName: $friendName, dueDate: $dueDate, isPending: $isPending)';
  }
}
