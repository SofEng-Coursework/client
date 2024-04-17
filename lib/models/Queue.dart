class QueueUserEntry {
  final String userId;
  final int timestamp;

  QueueUserEntry({
    required this.userId,
    required this.timestamp,
  });

  factory QueueUserEntry.fromJson(Map<String, dynamic> json) {
    return QueueUserEntry(
      userId: json['userId'] as String,
      timestamp: json['timestamp'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'timestamp': timestamp,
    };
  }
}

class Queue {
  final String id;
  final String name;
  final bool open;
  final double? capacity;
  final List<QueueUserEntry> users;

  Queue({
    required this.id,
    required this.name,
    required this.open,
    required this.users,
    this.capacity,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    return Queue(
      id: json['id'] as String,
      name: json['name'] as String,
      open: json['open'] as bool,
      capacity: json['capacity'] as double,
      users: (json['users'] as List).map((e) => QueueUserEntry.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'open': open,
      'capacity': capacity,
      'users': users.map((e) => e.toJson()).toList(),
    };
  }
}
