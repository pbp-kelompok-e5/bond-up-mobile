import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/features/event-management/models/event.dart';
import 'package:bond_up_mobile/features/event-management/screens/event_form_page.dart';
import 'package:bond_up_mobile/features/event-management/services/event_service.dart';
import 'package:mockito/mockito.dart';

class MockCookieRequest extends Mock implements CookieRequest {}
class MockEventService extends Mock implements EventService {}

void main() {
  group('EventFormPage', () {
    late MockCookieRequest mockCookieRequest;
    late MockEventService mockEventService;

    setUp(() {
      mockCookieRequest = MockCookieRequest();
      mockEventService = MockEventService();
    });

    testWidgets('renders correctly for creating a new event', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: EventFormPage(),
          ),
        ),
      );

      expect(find.text('Create Event'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(8));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('renders correctly for editing an existing event', (WidgetTester tester) async {
      final event = Event(
        id: 1,
        title: 'Test Event',
        description: 'Test Description',
        thumbnail: 'https://example.com/thumb.png',
        sportType: 'Test Sport',
        eventDate: DateTime.now(),
        startTime: '10:00',
        endTime: '12:00',
        city: 'Test City',
        locationName: 'Test Location',
        maxParticipants: 20,
        currentParticipants: 10,
        status: 'upcoming',
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: EventFormPage(event: event),
          ),
        ),
      );

      expect(find.text('Edit Event'), findsOneWidget);
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Test Sport'), findsOneWidget);
      expect(find.text('https://example.com/thumb.png'), findsOneWidget);
      expect(find.text('Test City'), findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('shows validation error for empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: EventFormPage(),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Cannot be empty'), findsWidgets);
    });

    testWidgets('creates a new event when form is submitted', (WidgetTester tester) async {
      when(mockEventService.createEvent(argThat(isA<Map<String, dynamic>>()))).thenAnswer((_) async => {'message': 'Event created successfully'});

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: EventFormPage(),
          ),
        ),
      );

      await tester.enterText(find.widgetWithText(TextFormField, 'Title'), 'New Event Title');
      await tester.enterText(find.widgetWithText(TextFormField, 'Description'), 'New Event Description');
      await tester.enterText(find.widgetWithText(TextFormField, 'Sport Type'), 'Basketball');
      await tester.enterText(find.widgetWithText(TextFormField, 'Thumbnail URL'), 'https://new.thumb.com/img.png');
      await tester.enterText(find.widgetWithText(TextFormField, 'City'), 'New City');
      await tester.enterText(find.widgetWithText(TextFormField, 'Location Name'), 'New Location');
      await tester.enterText(find.widgetWithText(TextFormField, 'Start Time (HH:MM:SS)'), '09:00:00');
      await tester.enterText(find.widgetWithText(TextFormField, 'End Time (HH:MM:SS)'), '11:00:00');
      await tester.enterText(find.widgetWithText(TextFormField, 'Max Participants'), '15');


      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(mockEventService.createEvent(any)).called(1); // Verify createEvent was called
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Event created successfully'), findsOneWidget);
      expect(find.byType(EventFormPage), findsNothing); // Verify pop
    });

    testWidgets('updates an event when form is submitted', (WidgetTester tester) async {
      final event = Event(
        id: 1,
        title: 'Test Event',
        description: 'Test Description',
        thumbnail: 'https://example.com/thumb.png',
        sportType: 'Test Sport',
        eventDate: DateTime.now(),
        startTime: '10:00',
        endTime: '12:00',
        city: 'Test City',
        locationName: 'Test Location',
        maxParticipants: 20,
        currentParticipants: 10,
        status: 'upcoming',
      );
      
      when(mockEventService.updateEvent(any, any)).thenAnswer((_) async => {'message': 'Event updated successfully'});

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: EventFormPage(event: event),
          ),
        ),
      );

      await tester.enterText(find.widgetWithText(TextFormField, 'Test Event'), 'Updated Event Title');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      verify(mockEventService.updateEvent(event.id, any)).called(1); // Verify updateEvent was called
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Event updated successfully'), findsOneWidget);
      expect(find.byType(EventFormPage), findsNothing); // Verify pop
    });
  });
}
