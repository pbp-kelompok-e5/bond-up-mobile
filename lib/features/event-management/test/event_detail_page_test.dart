import 'package:bond_up_mobile/features/event-management/screens/event_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/features/event-management/models/event.dart';
import 'package:bond_up_mobile/features/event-management/screens/event_detail_page.dart';
import 'package:bond_up_mobile/features/event-management/services/event_service.dart';
import 'package:mockito/mockito.dart';

class MockCookieRequest extends Mock implements CookieRequest {}
class MockEventService extends Mock implements EventService {}

void main() {
  group('EventDetailPage', () {
    late MockCookieRequest mockCookieRequest;
    late MockEventService mockEventService;
    late Event testEvent;

    setUp(() {
      mockCookieRequest = MockCookieRequest();
      mockEventService = MockEventService();
      testEvent = Event(
        id: 1,
        title: 'Test Event',
        description: 'Test Description',
        thumbnail: 'https://via.placeholder.com/150',
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
    });

    testWidgets('renders event details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService), // Provide MockEventService
          ],
          child: MaterialApp(
            home: EventDetailPage(event: testEvent),
          ),
        ),
      );

      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Sport: Test Sport'), findsOneWidget);
      expect(find.text('City: Test City'), findsOneWidget);
      expect(find.text('Location: Test Location'), findsOneWidget);
    });

    testWidgets('tapping edit button navigates to edit page', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService), // Provide MockEventService
          ],
          child: MaterialApp(
            home: EventDetailPage(event: testEvent),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Verify that Navigator.push was called and that the new page is EventFormPage
      expect(find.byType(EventFormPage), findsOneWidget);
    });

    testWidgets('tapping cancel button shows confirmation dialog and cancels event', (WidgetTester tester) async {
      when(mockEventService.cancelEvent(any(that: isA<int>()))).thenAnswer((_) async => {'message': 'Event cancelled successfully'});

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: EventDetailPage(event: testEvent),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Cancellation'), findsOneWidget);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      verify(mockEventService.cancelEvent(testEvent.id)).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Event cancelled successfully'), findsOneWidget);
      expect(find.byType(EventListPage), findsOneWidget); // Verify pop
    });

    testWidgets('tapping delete button deletes the event', (WidgetTester tester) async {
      when(mockEventService.deleteEvent(any(that: isA<int>()))).thenAnswer((_) async => {'message': 'Event deleted successfully'});

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<CookieRequest>(create: (_) => mockCookieRequest),
            Provider<EventService>(create: (_) => mockEventService),
          ],
          child: MaterialApp(
            home: EventDetailPage(event: testEvent),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Ensure the confirmation dialog for delete also appears (if applicable, the current code doesn't show one)
      // If there's no confirmation dialog, directly verify service call and snackbar.
      verify(mockEventService.deleteEvent(testEvent.id)).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Event deleted successfully'), findsOneWidget);
      expect(find.byType(EventListPage), findsOneWidget); // Verify pop
    });

  });
}
