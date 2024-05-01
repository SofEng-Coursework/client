class QueueUserEntry {
  final String userId;
  final String? name;
  final int timestamp;

  QueueUserEntry({
    required this.userId,
    required this.name,
    required this.timestamp,
  });

  factory QueueUserEntry.fromJson(Map<String, dynamic> json) {
    return QueueUserEntry(
      userId: json['userId'] as String,
      name: json['name'] as String?,
      timestamp: json['timestamp'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'timestamp': timestamp,
    };
  }
}

class QueueLog {
  final String userId;
  final int start;
  final int end;

  QueueLog({
    required this.userId,
    required this.start,
    required this.end,
  });

  factory QueueLog.fromJson(Map<String, dynamic> json) {
    return QueueLog(
      userId: json['userId'] as String,
      start: json['start'] as int,
      end: json['end'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'start': start,
      'end': end,
    };
  }
}

class Queue {
  final String id;
  final String name;
  final bool open;
  final double? capacity;
  final List<QueueUserEntry> users;
  final List<QueueLog> logs;

  Queue({
    required this.id,
    required this.name,
    required this.open,
    required this.users,
    required this.logs,
    this.capacity,
  });

  bool isFull() {
    return capacity != null && users.length >= capacity!;
  }

  factory Queue.fromJson(Map<String, dynamic> json) {
    return Queue(
      id: json['id'] as String,
      name: json['name'] as String,
      open: json['open'] as bool,
      capacity: json['capacity'] as double?,
      users: (json['users'] as List).map((e) => QueueUserEntry.fromJson(e)).toList(),
      logs: (json['logs'] as List).map((e) => QueueLog.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'open': open,
      'capacity': capacity,
      'users': users.map((e) => e.toJson()).toList(),
      'logs': logs.map((e) => e.toJson()).toList(),
    };
  }
}
