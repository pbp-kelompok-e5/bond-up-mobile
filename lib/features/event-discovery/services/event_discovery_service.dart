import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../event-management/models/event.dart';

const String baseApi = "http://localhost:8000/event-discovery";

class EventDiscoveryService {
  final CookieRequest request;
  EventDiscoveryService(this.request);

  Future<List<Event>> fetchAllEvents() async {
    final res = await request.get("$baseApi/events/json/");
    List data = res;
    return data.map((e) => Event.fromJson(e)).toList();
  }

  Future<Event> fetchEventById(int eventId) async {
    final res = await request.get("$baseApi/events/$eventId/json/");
    return Event.fromJson(res);
  }

  Future<Map<String, dynamic>> joinEvent(int eventId) async {
    final res = await request.postJson(
      "$baseApi/events/$eventId/join/",
      jsonEncode({}), // Send empty body for POST
    );
    return res;
  }

  Future<Map<String, dynamic>> leaveEvent(int eventId) async {
    final res = await request.postJson(
      "$baseApi/events/$eventId/leave/",
      jsonEncode({}), // Send empty body for POST
    );
    return res;
  }

  /// Fetches the username of the currently logged-in user.
  Future<String?> fetchCurrentUsername() async {
    // Note: The base URL for authentication endpoints is different.
    // Assuming the authentication API is at http://localhost:8000/auth/flutter/profile/
    const authApiBase = "http://localhost:8000/auth/flutter"; 
    final res = await request.get("$authApiBase/profile/");
    if (res['status'] == true && res['data'] != null) {
      return res['data']['user']['username'];
    }
    return null;
  }
}
