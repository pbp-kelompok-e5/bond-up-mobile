import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/event.dart';

const String baseApi = "http://localhost:8000/event-management/api";

class EventService {
  final CookieRequest request;
  EventService(this.request);

  Future<List<Event>> fetchMyEvents() async {
    final res = await request.get("$baseApi/my-events/");
    List data = res;
    return data.map((e) => Event.fromJson(e)).toList();
  }

  Future<Event> fetchEventDetail(int id) async {
    final res = await request.get("$baseApi/events/$id/");
    return Event.fromJson(res);
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> payload) async {
    final res = await request.postJson("$baseApi/events/create/", jsonEncode(payload));
    return res;
  }

  Future<Map<String, dynamic>> updateEvent(int id, Map<String, dynamic> payload) async {
    final res = await request.postJson("$baseApi/events/$id/update/", jsonEncode(payload));
    return res;
  }

  Future<Map<String, dynamic>> deleteEvent(int id) async {
    final res = await request.postJson("$baseApi/events/$id/delete/", "{}");
    return res;
  }

  Future<List<Map<String, dynamic>>> fetchParticipants(int eventId) async {
    final res = await request.get("$baseApi/events/$eventId/participants/");
    return List<Map<String, dynamic>>.from(res);
  }

  Future<Map<String, dynamic>> manageParticipant(int eventId, String action, int userId) async {
    final res = await request.postJson(
      "$baseApi/events/$eventId/participants/manage/",
      jsonEncode({"action": action, "user_id": userId}),
    );
    return res;
  }
}
