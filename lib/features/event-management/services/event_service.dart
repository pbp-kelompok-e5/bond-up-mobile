import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/event.dart';
import '../models/participant.dart';

/// URL dasar untuk API manajemen acara.
const String baseApi = "http://localhost:8000/event-management/api";

/// Kelas layanan untuk berinteraksi dengan API backend manajemen acara.
class EventService {
  /// Instance [CookieRequest] yang digunakan untuk melakukan permintaan terautentikasi.
  final CookieRequest request;

  /// Membuat [EventService] dengan [CookieRequest] yang diberikan.
  EventService(this.request);

  /// Mengambil daftar acara yang dibuat oleh pengguna saat ini.
  ///
  /// Mengembalikan [Future] yang menghasilkan [List] berisi objek [Event].
  Future<List<Event>> fetchMyEvents() async {
    final res = await request.get("$baseApi/my-events/");
    List data = res;
    return data.map((e) => Event.fromJson(e)).toList();
  }

  /// Mengambil informasi detail dari satu acara tertentu.
  ///
  /// Menerima [id] acara sebagai input.
  /// Mengembalikan [Future] yang menghasilkan objek [Event].
  Future<Event> fetchEventDetail(int id) async {
    final res = await request.get("$baseApi/events/$id/");
    return Event.fromJson(res);
  }

  /// Membuat acara baru.
  ///
  /// Menerima map [payload] yang berisi data acara.
  /// Mengembalikan [Future] yang menghasilkan [Map<String, dynamic>]
  /// berisi respons dari backend (misalnya, pesan sukses).
  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> payload) async {
    final res = await request.postJson("$baseApi/events/create/", jsonEncode(payload));
    return res;
  }

  /// Memperbarui acara yang sudah ada.
  ///
  /// Menerima [id] acara yang akan diperbarui dan map [payload] dengan data terbaru.
  /// Mengembalikan [Future] yang menghasilkan [Map<String, dynamic>]
  /// berisi respons dari backend.
  Future<Map<String, dynamic>> updateEvent(int id, Map<String, dynamic> payload) async {
    final res = await request.postJson("$baseApi/events/$id/update/", jsonEncode(payload));
    return res;
  }

  /// Menghapus sebuah acara.
  ///
  /// Menerima [id] acara yang akan dihapus.
  /// Mengembalikan [Future] yang menghasilkan [Map<String, dynamic>]
  /// berisi respons dari backend.
  Future<Map<String, dynamic>> deleteEvent(int id) async {
    final res = await request.postJson("$baseApi/events/$id/delete/", "{}");
    return res;
  }

  /// Membatalkan sebuah acara.
  ///
  /// Menerima [id] acara yang akan dibatalkan.
  /// Mengembalikan [Future] yang menghasilkan [Map<String, dynamic>]
  /// berisi respons dari backend.
  Future<Map<String, dynamic>> cancelEvent(int id) async {
    // Backend mengharapkan POST atau PATCH. Mengirimkan objek JSON kosong.
    final res = await request.postJson("$baseApi/events/$id/cancel/", "{}");
    return res;
  }

  /// Mengambil daftar peserta untuk acara tertentu.
  ///
  /// Menerima [eventId] sebagai input.
  /// Mengembalikan [Future] yang menghasilkan [List] berisi objek [Participant].
  Future<List<Participant>> fetchParticipants(int eventId) async {
    final res = await request.get("$baseApi/events/$eventId/participants/");
    List data = res;
    return data.map((e) => Participant.fromJson(e)).toList();
  }

  /// Mengelola status peserta dalam sebuah acara (misal: hapus, tandai hadir).
  ///
  /// Menerima [eventId], [action] yang akan dilakukan (misal: "remove", "mark_attended"),
  /// dan [userId] dari peserta yang bersangkutan.
  /// Mengembalikan [Future] yang menghasilkan [Map<String, dynamic>]
  /// berisi respons dari backend.
  Future<Map<String, dynamic>> manageParticipant(int eventId, String action, int userId) async {
    final res = await request.postJson(
      "$baseApi/events/$eventId/participants/manage/",
      jsonEncode({"action": action, "user_id": userId}),
    );
    return res;
  }
}