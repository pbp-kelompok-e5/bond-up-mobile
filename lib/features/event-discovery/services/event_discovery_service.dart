import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../event-management/models/event.dart';
import 'package:bond_up_mobile/core/constants/api_constants.dart';

const String baseApi = "${ApiConstants.baseUrl}/event-discovery";

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
}
