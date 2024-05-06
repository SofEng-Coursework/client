class FeedbackEntry {
  final String userId;
  final String name;
  final String comments;
  final int rating;
  final int timestamp;

  FeedbackEntry({
    required this.userId,
    required this.name,
    required this.comments,
    required this.rating,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch;

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      userId: json['userId'] as String,
      name: json['name'] as String,
      comments: json['comments'] as String,
      rating: json['rating'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'comments': comments,
      'rating': rating,
      'timestamp': timestamp,
    };
  }
}
