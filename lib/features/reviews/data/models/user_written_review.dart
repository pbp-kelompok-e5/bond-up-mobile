class UserWrittenReview {
  final int id;
  final String eventTitle;
  final String revieweeName; // Orang yang kita beri nilai (to_user)
  final int rating;
  final String comment;
  final String createdAt;

  UserWrittenReview({
    required this.id,
    required this.eventTitle,
    required this.revieweeName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory UserWrittenReview.fromJson(Map<String, dynamic> json) {
    return UserWrittenReview(
      id: json['id'],
      eventTitle: json['event_title'],
      revieweeName: json['reviewee_name'], 
      rating: json['rating'],
      comment: json['comment'],
      createdAt: json['created_at'],
    );
  }
}