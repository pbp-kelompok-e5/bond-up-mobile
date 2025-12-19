/// Merepresentasikan sebuah acara olahraga dengan berbagai detail.
class Event {
  /// Membentuk objek [Event].
  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.sportType,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.city,
    required this.locationName,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.status,
    required this.organizerUsername,
    this.isJoined,
  });

  /// Pengidentifikasi unik (ID) untuk acara tersebut.
  final int id;

  /// Judul dari acara.
  final String title;

  /// Deskripsi mendalam mengenai acara.
  final String description;

  /// URL menuju gambar thumbnail acara.
  final String thumbnail;

  /// Jenis olahraga untuk acara ini (contoh: 'Badminton', 'Futsal').
  final String sportType;

  /// Tanggal kapan acara akan berlangsung.
  final DateTime eventDate;

  /// Waktu mulai acara dalam format "HH:MM:SS".
  final String startTime;

  /// Waktu berakhirnya acara dalam format "HH:MM:SS".
  final String endTime;

  /// Kota tempat acara diselenggarakan.
  final String city;

  /// Nama lokasi spesifik acara (contoh: 'Gelanggang Olahraga ABC').
  final String locationName;

  /// Jumlah maksimum peserta yang diizinkan untuk acara ini.
  final int maxParticipants;

  /// Jumlah peserta yang saat ini sudah bergabung.
  final int currentParticipants;

  /// Status acara saat ini (contoh: 'upcoming', 'open', 'cancelled', 'completed').
  final String status;

  /// Nama pengguna (username) dari penyelenggara acara.
  final String organizerUsername;

  /// Opsional: Menunjukkan apakah pengguna saat ini sudah bergabung ke acara tersebut.
  final bool? isJoined;

  /// Membuat objek [Event] dari sebuah Map JSON.
  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        thumbnail: json['thumbnail'] ?? '',
        sportType: json['sport_type'] ?? '',
        eventDate: DateTime.parse(json['event_date'].toString()),
        startTime: json['start_time'].toString(),
        endTime: json['end_time'].toString(),
        city: json['city'] ?? '',
        locationName: json['location_name'] ?? '',
        maxParticipants: int.parse(json['max_participants'].toString()),
        currentParticipants: int.parse(json['current_participants'].toString()),
        status: json['status'] ?? '',
        organizerUsername: json['organizer'] ?? 'Unknown',
        isJoined: json['is_joined'] ?? false,
      );

  /// Mengonversi objek [Event] ini ke dalam Map JSON.
  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "description": description,
        "thumbnail": thumbnail,
        "sport_type": sportType,
        "event_date": eventDate.toIso8601String(),
        "start_time": startTime,
        "end_time": endTime,
        "city": city,
        "location_name": locationName,
        "max_participants": maxParticipants,
        "current_participants": currentParticipants,
        "status": status,
        "organizer": organizerUsername,
        "is_joined": isJoined,
      };
}