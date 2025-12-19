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

  // POST Join Request
  Future<bool> joinEvent(int eventId) async {
    try {
      final response = await request.post(
          '$baseUrl/event_discovery/events/$eventId/join',
          {} // Empty body, ID is in the URL
      );

      // Check message from views.py: return JsonResponse({'message': 'Joined'}, status=201)
      if (response['message'] == 'Joined') {
        return true;
      } else {
        // Handle 'Event is full' or 'Could not join'
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // DEL Leave Request
  Future<bool> leaveEvent(int eventId) async {
    try {
      // Using POST as this modifies server state, even though it deletes a record
      final response = await request.post(
          '$baseUrl/event_discovery/events/$eventId/leave',
          {}
      );

      // Check message from views.py: return JsonResponse({'message': 'Left'}, status=201)
      if (response['message'] == 'Left') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // GET Participant Status
  Future<String> getParticipantStatus(int eventId) async {
    try {
      // The endpoint defined in urls.py is events/<id>/participant-status/
      final response = await request.get(
        '$baseUrl/event_discovery/events/$eventId/participant-status/',
      );

      // The Django view returns: {'status': '...'}
      if (response != null && response['status'] != null) {
        return response['status'];
      }

      return 'not_participating';
    } catch (e) {
      // Fallback in case of error (e.g., not logged in or network issue)
      return 'not_participating';
    }
  }
}