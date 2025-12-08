import 'package:flutter_test/flutter_test.dart';
import 'package:bond_up_mobile/features/event-management/models/event.dart';

void main() {
  group('Event Model', () {
    test('fromJson creates a valid Event object', () {
      final json = {
        'id': 1,
        'title': 'Test Event',
        'description': 'This is a test event.',
        'thumbnail': 'https://example.com/thumbnail.png',
        'sport_type': 'Running',
        'event_date': '2025-12-10T10:00:00Z',
        'start_time': '10:00:00',
        'end_time': '12:00:00',
        'city': 'Test City',
        'location_name': 'Test Location',
        'max_participants': '20',
        'current_participants': '5',
        'status': 'upcoming',
      };

      final event = Event.fromJson(json);

      expect(event.id, 1);
      expect(event.title, 'Test Event');
      expect(event.description, 'This is a test event.');
      expect(event.thumbnail, 'https://example.com/thumbnail.png');
      expect(event.sportType, 'Running');
      expect(event.eventDate, DateTime.parse('2025-12-10T10:00:00Z'));
      expect(event.startTime, '10:00:00');
      expect(event.endTime, '12:00:00');
      expect(event.city, 'Test City');
      expect(event.locationName, 'Test Location');
      expect(event.maxParticipants, 20);
      expect(event.currentParticipants, 5);
      expect(event.status, 'upcoming');
    });

    test('toJson returns a valid JSON map', () {
      final event = Event(
        id: 1,
        title: 'Test Event',
        description: 'This is a test event.',
        thumbnail: 'https://example.com/thumbnail.png',
        sportType: 'Running',
        eventDate: DateTime.parse('2025-12-10T10:00:00Z'),
        startTime: '10:00:00',
        endTime: '12:00:00',
        city: 'Test City',
        locationName: 'Test Location',
        maxParticipants: 20,
        currentParticipants: 5,
        status: 'upcoming',
      );

      final json = event.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Test Event');
      expect(json['description'], 'This is a test event.');
      expect(json['thumbnail'], 'https://example.com/thumbnail.png');
      expect(json['sport_type'], 'Running');
      expect(json['event_date'], '2025-12-10T10:00:00.000Z');
      expect(json['start_time'], '10:00:00');
      expect(json['end_time'], '12:00:00');
      expect(json['city'], 'Test City');
      expect(json['location_name'], 'Test Location');
      expect(json['max_participants'], 20);
      expect(json['current_participants'], 5);
      expect(json['status'], 'upcoming');
    });
  });
}
