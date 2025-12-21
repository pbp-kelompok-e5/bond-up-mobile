import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/event_with_status.dart';
import '../models/event.dart';

const String baseApi = "https://farrell-bagoes-sigmaapp.pbp.cs.ui.ac.id/event-discovery";

/// Kelas layanan untuk mengambil riwayat acara yang diikuti pengguna.
/// 
/// Layanan ini berinteraksi dengan API backend untuk mendapatkan daftar acara
/// di mana pengguna saat ini terdaftar sebagai peserta, beserta status partisipasinya.
class EventHistoryService {
  /// Instance [CookieRequest] yang digunakan untuk melakukan permintaan terautentikasi.
  final CookieRequest request;

  /// Membuat [EventHistoryService] dengan [CookieRequest] yang diberikan.
  EventHistoryService(this.request);

  /// Mengambil daftar acara yang diikuti oleh pengguna saat ini beserta status partisipasinya.
  ///
  /// Mengembalikan [Future] yang menghasilkan [List] berisi objek [EventWithStatus].
  /// Setiap objek berisi informasi acara lengkap dan status partisipasi pengguna
  /// (joined, attended, atau cancelled).
  Future<List<EventWithStatus>> fetchEventHistory() async {
    try {
      // Mengambil daftar acara yang diikuti pengguna
      final eventsRes = await request.get("$baseApi/events/my-joined/json/");
      List eventsData = eventsRes;
      
      // Membuat list untuk menyimpan event dengan status
      List<EventWithStatus> eventsWithStatus = [];
      
      // Untuk setiap event, ambil status partisipasi pengguna
      for (var eventJson in eventsData) {
        Event event = Event.fromJson(eventJson);
        
        // Mengambil status partisipasi untuk event ini
        String status = await _fetchParticipantStatus(event.id);
        
        eventsWithStatus.add(EventWithStatus(
          event: event,
          participantStatus: status,
        ));
      }
      
      return eventsWithStatus;
    } catch (e) {
      // Jika terjadi error, kembalikan list kosong
      return [];
    }
  }

  /// Mengambil status partisipasi pengguna untuk acara tertentu.
  ///
  /// Menerima [eventId] sebagai input.
  /// Mengembalikan [Future] yang menghasilkan [String] status partisipasi.
  /// Nilai yang mungkin: 'joined', 'attended', 'cancelled', 'not_participating'
  Future<String> _fetchParticipantStatus(int eventId) async {
    try {
      final res = await request.get("$baseApi/events/$eventId/participant-status/");
      
      if (res != null && res['status'] != null) {
        return res['status'];
      }
      
      return 'not_participating';
    } catch (e) {
      return 'not_participating';
    }
  }
}

