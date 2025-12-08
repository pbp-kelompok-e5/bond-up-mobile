import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/features/event-management/models/event.dart';
import 'package:bond_up_mobile/features/event-management/screens/my_events_page.dart';
import 'package:bond_up_mobile/features/event-management/services/event_service.dart';
import 'package:mockito/mockito.dart';
import 'package:bond_up_mobile/features/event-management/screens/event_form_page.dart';
import 'package:bond_up_mobile/features/event-management/screens/event_detail_page.dart';

class MockCookieRequest extends Mock implements CookieRequest {}
class MockEventService extends Mock implements EventService {}

void main() {
  group('MyEventsPage', () {
    late MockCookieRequest mockCookieRequest;
    late MockEventService mockEventService;

    setUp(() {
      mockCookieRequest = MockCookieRequest();
      mockEventService = MockEventService();
    });

    testWidgets('shows a loading indicator when fetching events', (WidgetTester tester) async {
      when(mockEventService.fetchMyEvents()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: MyEventsPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows an error message when fetching events fails', (WidgetTester tester) async {
      when(mockEventService.fetchMyEvents()).thenThrow(Exception('Failed to fetch'));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: MyEventsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error: Exception: Failed to fetch'), findsOneWidget);
    });

    testWidgets('shows "No events" when there are no events', (WidgetTester tester) async {
      when(mockEventService.fetchMyEvents()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: MyEventsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();

      expect(find.text('No events'), findsOneWidget);
    });

    testWidgets('displays a list of upcoming and past events', (WidgetTester tester) async {
      final events = [
        Event(
          id: 1,
          title: 'Upcoming Event',
          description: '',
          thumbnail: '',
          sportType: '',
          eventDate: DateTime.now().add(const Duration(days: 1)),
          startTime: '',
          endTime: '',
          city: 'Test City',
          locationName: '',
          maxParticipants: 10,
          currentParticipants: 5,
          status: 'upcoming',
        ),
        Event(
          id: 2,
          title: 'Past Event',
          description: '',
          thumbnail: '',
          sportType: '',
          eventDate: DateTime.now().subtract(const Duration(days: 1)),
          startTime: '',
          endTime: '',
          city: 'Test City',
          locationName: '',
          maxParticipants: 10,
          currentParticipants: 5,
          status: 'completed',
        ),
      ];

      when(mockEventService.fetchMyEvents()).thenAnswer((_) async => events);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: MyEventsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Upcoming Events'), findsOneWidget);
      expect(find.text('Upcoming Event'), findsOneWidget);
      expect(find.text('Past Events'), findsOneWidget);
      expect(find.text('Past Event'), findsOneWidget);
    });

    testWidgets('tapping add button navigates to EventFormPage', (WidgetTester tester) async {
      when(mockEventService.fetchMyEvents()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: MyEventsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle(); // Ensure initial loading is done

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(EventFormPage), findsOneWidget);
    });

    testWidgets('tapping on an event in the list navigates to EventDetailPage', (WidgetTester tester) async {
      final event = Event(
        id: 1,
        title: 'Event to View',
        description: '',
        thumbnail: '',
        sportType: '',
        eventDate: DateTime.now().add(const Duration(days: 1)),
        startTime: '',
        endTime: '',
        city: 'View City',
        locationName: '',
        maxParticipants: 10,
        currentParticipants: 5,
        status: 'upcoming',
      );
      when(mockEventService.fetchMyEvents()).thenAnswer((_) async => [event]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: MyEventsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Event to View'));
      await tester.pumpAndSettle();

      expect(find.byType(EventDetailPage), findsOneWidget);
      expect(find.text('Event to View'), findsOneWidget);
    });

    testWidgets('tapping edit from popup menu navigates to EventFormPage', (WidgetTester tester) async {
      final event = Event(
        id: 1,
        title: 'Editable Event',
        description: '',
        thumbnail: '',
        sportType: '',
        eventDate: DateTime.now().add(const Duration(days: 1)),
        startTime: '',
        endTime: '',
        city: 'Edit City',
        locationName: '',
        maxParticipants: 10,
        currentParticipants: 5,
        status: 'upcoming',
      );
      when(mockEventService.fetchMyEvents()).thenAnswer((_) async => [event]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: MyEventsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.byType(EventFormPage), findsOneWidget);
      expect(find.text('Edit Event'), findsOneWidget);
    });

    testWidgets('tapping cancel from popup menu cancels event and refreshes', (WidgetTester tester) async {
      final event = Event(
        id: 1,
        title: 'Cancelable Event',
        description: '',
        thumbnail: '',
        sportType: '',
        eventDate: DateTime.now().add(const Duration(days: 1)),
        startTime: '',
        endTime: '',
        city: 'Cancel City',
        locationName: '',
        maxParticipants: 10,
        currentParticipants: 5,
        status: 'upcoming',
      );
      when(mockEventService.fetchMyEvents()).thenAnswer((_) async => [event]);
      when(mockEventService.cancelEvent(argThat(isA<int>()))).thenAnswer((_) async => {'message': 'Event cancelled successfully'});

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: MyEventsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Cancellation'), findsOneWidget);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      verify(mockEventService.cancelEvent(event.id)).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Event cancelled successfully'), findsOneWidget);
      verify(mockEventService.fetchMyEvents()).called(2); // Initial fetch + refresh
    });

    testWidgets('tapping delete from popup menu deletes event and refreshes', (WidgetTester tester) async {
      final event = Event(
        id: 1,
        title: 'Deletable Event',
        description: '',
        thumbnail: '',
        sportType: '',
        eventDate: DateTime.now().add(const Duration(days: 1)),
        startTime: '',
        endTime: '',
        city: 'Delete City',
        locationName: '',
        maxParticipants: 10,
        currentParticipants: 5,
        status: 'upcoming',
      );
      when(mockEventService.fetchMyEvents()).thenAnswer((_) async => [event]);
      when(mockEventService.deleteEvent(argThat(isA<int>()))).thenAnswer((_) async => {'message': 'Event deleted successfully'});

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: MyEventsPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Deletion'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      verify(mockEventService.deleteEvent(event.id)).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Event deleted successfully'), findsOneWidget);
      verify(mockEventService.fetchMyEvents()).called(2); // Initial fetch + refresh
    });
  });
}
