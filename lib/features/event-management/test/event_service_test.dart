import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/features/event-management/models/event.dart';
import 'package:bond_up_mobile/features/event-management/services/event_service.dart';

class MockCookieRequest extends Mock implements CookieRequest {}

void main() {
  group('EventService', () {
    late EventService eventService;
    late MockCookieRequest mockCookieRequest;

    setUp(() {
      mockCookieRequest = MockCookieRequest();
      eventService = EventService(mockCookieRequest);
    });

    test('fetchMyEvents returns a list of events', () async {
      final eventsJson = [
        {
          'id': 1,
          'title': 'Test Event 1',
          'description': 'Description 1',
          'thumbnail': 'thumb1.png',
          'sport_type': 'Sport 1',
          'event_date': '2025-01-01T12:00:00Z',
          'start_time': '12:00:00',
          'end_time': '14:00:00',
          'city': 'City 1',
          'location_name': 'Location 1',
          'max_participants': '10',
          'current_participants': '5',
          'status': 'upcoming'
        },
      ];

      when(mockCookieRequest.get(argThat(isA<String>()))).thenAnswer((_) async => eventsJson);

      final events = await eventService.fetchMyEvents();

      expect(events, isA<List<Event>>());
      expect(events.length, 1);
      expect(events[0].title, 'Test Event 1');
    });

    test('fetchEventDetail returns an event', () async {
      final eventJson = {
        'id': 1,
        'title': 'Test Event 1',
        'description': 'Description 1',
        'thumbnail': 'thumb1.png',
        'sport_type': 'Sport 1',
        'event_date': '2025-01-01T12:00:00Z',
        'start_time': '12:00:00',
        'end_time': '14:00:00',
        'city': 'City 1',
        'location_name': 'Location 1',
        'max_participants': '10',
        'current_participants': '5',
        'status': 'upcoming'
      };

      when(mockCookieRequest.get(argThat(isA<String>()))).thenAnswer((_) async => eventJson);

      final event = await eventService.fetchEventDetail(1);

      expect(event, isA<Event>());
      expect(event.id, 1);
      expect(event.title, 'Test Event 1');
    });

    test('createEvent returns a success message', () async {
      final payload = {'title': 'New Event'};
      final response = {'status': 'success', 'message': 'Event created'};

      when(mockCookieRequest.postJson(argThat(isA<String>()), argThat(isA<String>()))).thenAnswer((_) async => response);

      final result = await eventService.createEvent(payload);

      expect(result, response);
    });

    test('updateEvent returns a success message', () async {
      final payload = {'title': 'Updated Event'};
      final response = {'status': 'success', 'message': 'Event updated'};

      when(mockCookieRequest.postJson(argThat(isA<String>()), argThat(isA<String>()))).thenAnswer((_) async => response);

      final result = await eventService.updateEvent(1, payload);

      expect(result, response);
    });

    test('deleteEvent returns a success message', () async {
      final response = {'status': 'success', 'message': 'Event deleted'};

      when(mockCookieRequest.postJson(argThat(isA<String>()), argThat(isA<String>()))).thenAnswer((_) async => response);

      final result = await eventService.deleteEvent(1);

      expect(result, response);
    });

    test('cancelEvent returns a success message', () async {
      final response = {'status': 'success', 'message': 'Event cancelled'};

      when(mockCookieRequest.postJson(argThat(isA<String>()), argThat(isA<String>()))).thenAnswer((_) async => response);

      final result = await eventService.cancelEvent(1);

      expect(result, response);
    });

    test('fetchParticipants returns a list of participants', () async {
      final participantsJson = [
        {'user_id': 1, 'username': 'user1', 'status': 'joined'},
        {'user_id': 2, 'username': 'user2', 'status': 'attended'},
      ];

      when(mockCookieRequest.get(argThat(isA<String>()))).thenAnswer((_) async => participantsJson);

      final participants = await eventService.fetchParticipants(1);

      expect(participants, isA<List<Map<String, dynamic>>>());
      expect(participants.length, 2);
      expect(participants[0]['username'], 'user1');
    });

    test('manageParticipant returns a success message', () async {
      final response = {'status': 'success', 'message': 'Participant managed'};

      when(mockCookieRequest.postJson(argThat(isA<String>()), argThat(isA<String>()))).thenAnswer((_) async => response);

      final result = await eventService.manageParticipant(1, 'remove', 1);

      expect(result, response);
    });
  });
}
