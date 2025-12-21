class ReviewParticipant {
  final int id;
  final String username;
  final String? profileImageUrl;

  ReviewParticipant({
    required this.id,
    required this.username,
    this.profileImageUrl,
  });

  factory ReviewParticipant.fromJson(Map<String, dynamic> json) {
    return ReviewParticipant(
      id: int.parse(json['id'].toString()),
      username: json['username'] ?? "",
      profileImageUrl: json['profile_image_url'],
    );
  }
}