/// Merepresentasikan seorang peserta dalam sebuah acara.
class Participant {
  /// Membentuk objek [Participant].
  Participant({
    required this.userId,
    required this.username,
    required this.status,
    required this.joinedAt,
  });

  /// Pengidentifikasi unik (ID) dari pengguna yang berpartisipasi.
  final int userId;

  /// Nama pengguna (username) dari peserta.
  final String username;

  /// Status peserta (contoh: 'approved', 'pending', 'attended').
  final String status;

  /// Stempel waktu (timestamp) saat peserta bergabung dalam acara.
  final DateTime joinedAt;

  /// Membuat objek [Participant] dari sebuah Map JSON.
  factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        userId: int.parse(json["user_id"].toString()),
        username: json["username"] ?? "",
        status: json["status"] ?? "",
        joinedAt: DateTime.parse(json["joined_at"]),
      );

  /// Mengonversi objek [Participant] ini ke dalam Map JSON.
  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "username": username,
        "status": status,
        "joined_at": joinedAt.toIso8601String(),
      };
}