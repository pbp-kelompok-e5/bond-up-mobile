import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bond_up_mobile/features/event-discovery/data/models/event_model.dart';


class EventDiscoveryService {
  // TODO: Replace with your actual Django backend URL
  // For Android emulator: http://10.0.2.2:8000
  // For web/Chrome: http://localhost:8000
  // For production: https://farrell-bagoes-sigmaapp.pbp.cs.ui.ac.id
  static const String baseUrl = 'http://localhost:8000';

  final CookieRequest request;

  EventDiscoveryService(this.request);

  // Fetch Event List For Event Discovery Page
  Future<List<Event>> fetchEvents(CookieRequest request) async {
    final response = await request.get('$baseUrl/event_discovery/events/json/');
    var data = response;
    // Convert JSON to Event Models
    List<Event> listEvent = [];
    for (var d in data) {
      if (d != null) {
        listEvent.add(Event.fromJson(d));
      }
    }
    return listEvent;
  }

  // Fetch Event List For My Event Discovery Page
  Future<List<Event>> fetchMyEvents(CookieRequest request) async {
    final response = await request.get(
        '$baseUrl/event_discovery/events/my-joined/json/');
    var data = response;
    // Convert JSON to Event Models
    List<Event> listEvent = [];
    for (var d in data) {
      if (d != null) {
        listEvent.add(Event.fromJson(d));
      }
    }
    return listEvent;
  }

  // Join Event

  // Leave Event
}