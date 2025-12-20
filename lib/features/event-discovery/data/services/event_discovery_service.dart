import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/features/event-discovery/data/models/event_model.dart';
import 'package:bond_up_mobile/core/constants/api_constants.dart';


class EventDiscoveryService {
  /// Base URL for API requests - imported from centralized API constants
  static const String baseUrl = ApiConstants.baseUrl;

  final CookieRequest request;

  EventDiscoveryService(this.request);

  // Fetch Event List For Event Discovery Page
  Future<List<Event>> fetchEvents(CookieRequest request) async {
    final response = await request.get('$baseUrl/event-discovery/events/json');
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
        '$baseUrl/event-discovery/events/my-joined/json');
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
          '$baseUrl/event-discovery/events/$eventId/join',
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
          '$baseUrl/event-discovery/events/$eventId/leave',
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
        '$baseUrl/event-discovery/events/$eventId/participant-status/',
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

  // Fetch Event JSON BY ID
  Future<Event?> fetchEventById(String eventId) async {
    try {
      // Construct the URL matching your Django urls.py: path('events/<int:id>/json/', ...)
      final response = await request.get('$baseUrl/event-discovery/events/$eventId/json/');

      // Django usually returns a single object for this specific endpoint
      if (response != null) {
        return Event.fromJson(response);
      }
      return null;
    } catch (e) {
      //debugPrint("Error fetching event $eventId: $e");
      return null;
    }
  }
}