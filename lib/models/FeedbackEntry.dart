class FeedbackEntry {
  final String userId;
  final String comments;
  final int rating;
  final int timestamp;

  FeedbackEntry({
    required this.userId,
    required this.comments,
    required this.rating,
  }) : timestamp = DateTime.now().millisecondsSinceEpoch;

  factory FeedbackEntry.fromJson(Map<String, dynamic> json) {
    return FeedbackEntry(
      userId: json['userId'] as String,
      comments: json['comments'] as String,
      rating: json['rating'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'comments': comments,
      'rating': rating,
      'timestamp': timestamp,
    };
  }
}
