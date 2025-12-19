class Participant {
  Participant({
    required this.userId,
    required this.username,
    required this.status,
    required this.joinedAt,
  });

  final int userId;
  final String username;
  final String status;
  final DateTime joinedAt;

  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        userId: json["user_id"],
        username: json["username"],
        status: json["status"],
        joinedAt: DateTime.parse(json["joined_at"]),
      );

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "username": username,
        "status": status,
        "joined_at": joinedAt.toIso8601String(),
      };
}
