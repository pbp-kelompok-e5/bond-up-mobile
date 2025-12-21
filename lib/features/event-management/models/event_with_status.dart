import 'event.dart';

/// Merepresentasikan sebuah acara dengan status partisipasi pengguna.
/// 
/// Model ini memperluas informasi acara dengan menambahkan status partisipasi
/// pengguna saat ini (joined, attended, cancelled).
class EventWithStatus {
  /// Membentuk objek [EventWithStatus].
  EventWithStatus({
    required this.event,
    required this.participantStatus,
  });

  /// Data acara lengkap.
  final Event event;

  /// Status partisipasi pengguna dalam acara ini.
  /// Nilai yang mungkin: 'joined', 'attended', 'cancelled'
  final String participantStatus;

  /// Membuat objek [EventWithStatus] dari sebuah Map JSON.
  /// 
  /// JSON yang diharapkan memiliki struktur:
  /// {
  ///   "event": { ... data event ... },
  ///   "participant_status": "joined" | "attended" | "cancelled"
  /// }
  factory EventWithStatus.fromJson(Map<String, dynamic> json) {
    return EventWithStatus(
      event: Event.fromJson(json['event'] ?? json),
      participantStatus: json['participant_status'] ?? json['status'] ?? 'joined',
    );
  }

  /// Mengonversi objek [EventWithStatus] ini ke dalam Map JSON.
  Map<String, dynamic> toJson() => {
        "event": event.toJson(),
        "participant_status": participantStatus,
      };
}

