class UserReview {
  final int id;
  final String eventTitle;
  final String reviewerName; // Nama orang yang memberi nilai
  final int rating;
  final String comment;
  final String createdAt;

  UserReview({
    required this.id,
    required this.eventTitle,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: json['id'],
      eventTitle: json['event_title'] ?? "No Event",
      reviewerName: json['reviewer_name'] ?? "Anonymous",
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? "",
      createdAt: json['created_at'] ?? "",
    );
  }
}