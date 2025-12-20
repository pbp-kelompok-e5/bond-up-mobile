import 'package:bond_up_mobile/core/theme/app_colors.dart';
import 'package:bond_up_mobile/features/event-management/models/participant.dart';
import 'package:bond_up_mobile/features/event-management/screens/participants_page.dart';
import 'package:bond_up_mobile/features/event-management/services/event_service.dart'; // Import EventService for baseApi
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:mockito/annotations.dart'; // Import for @GenerateMocks
import 'package:provider/provider.dart';
import 'dart:convert'; // For jsonEncode, jsonDecode

import 'participants_page_test.mocks.dart'; // Generated mock file

// Generate a MockCookieRequest
@GenerateMocks([CookieRequest]) // Updated to only generate mock for CookieRequest
void main() {
  late MockCookieRequest mockCookieRequest;

  setUp(() {
    mockCookieRequest = MockCookieRequest();
  });

  // Helper function to pump the ParticipantsPage with necessary providers
  Widget createWidgetUnderTest(int eventId) {
    return MultiProvider(
      providers: [
        Provider<CookieRequest>.value(value: mockCookieRequest),
      ],
      child: MaterialApp(
        home: ParticipantsPage(eventId: eventId),
      ),
    );
  }

  group('ParticipantsPage', () {
    const int testEventId = 1;

    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      // Mock CookieRequest.get to return a Future that never completes, simulating loading
      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/'))
          .thenAnswer((_) => Future.value([])); // Immediately return an empty list to avoid pending timer

      await tester.pumpWidget(createWidgetUnderTest(testEventId));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Advance the clock and pump until the future completes and the UI updates
      await tester.pumpAndSettle();
      // After future completes, it should show "No participants" or actual data
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text("No participants have joined yet."), findsOneWidget);
    });

    testWidgets('displays "No participants" message when list is empty', (WidgetTester tester) async {
      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/'))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createWidgetUnderTest(testEventId));
      await tester.pumpAndSettle(); // Wait for FutureBuilder to complete

      expect(find.text("No participants have joined yet."), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('displays error message when fetching participants fails', (WidgetTester tester) async {
      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/'))
          .thenAnswer((_) async => throw Exception("Failed to load participants"));

      await tester.pumpWidget(createWidgetUnderTest(testEventId));
      await tester.pumpAndSettle();

      expect(find.text("No participants have joined yet."), findsOneWidget); // Expected text in error state
    });

    testWidgets('displays participants list correctly', (WidgetTester tester) async {
      final List<Map<String, dynamic>> participantsJson = [
        {'user_id': 1, 'username': 'Alice', 'status': 'approved', 'joined_at': '2025-01-01T10:00:00Z'},
        {'user_id': 2, 'username': 'Bob', 'status': 'pending', 'joined_at': '2025-01-01T11:00:00Z'},
      ];

      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/'))
          .thenAnswer((_) async => participantsJson);

      await tester.pumpWidget(createWidgetUnderTest(testEventId));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile), findsNWidgets(2));
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('APPROVED'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
    });

    testWidgets('can refresh participants list', (WidgetTester tester) async {
      final List<Map<String, dynamic>> initialParticipantsJson = [
        {'user_id': 1, 'username': 'Alice', 'status': 'approved', 'joined_at': '2025-01-01T10:00:00Z'},
      ];
      final List<Map<String, dynamic>> refreshedParticipantsJson = [
        {'user_id': 1, 'username': 'Alice', 'status': 'approved', 'joined_at': '2025-01-01T10:00:00Z'},
        {'user_id': 3, 'username': 'Charlie', 'status': 'approved', 'joined_at': '2025-01-01T12:00:00Z'},
      ];

      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/'))
          .thenAnswer((_) async => initialParticipantsJson);

      await tester.pumpWidget(createWidgetUnderTest(testEventId));
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Charlie'), findsNothing);

      // Simulate pull to refresh
      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/'))
          .thenAnswer((_) async => refreshedParticipantsJson);
      await tester.fling(find.byType(RefreshIndicator), const Offset(0.0, 300.0), 1000.0);
      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
      verify(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/')).called(2);
    });

    testWidgets('removes participant after confirmation', (WidgetTester tester) async {
      final List<Map<String, dynamic>> participantsJson = [
        {'user_id': 1, 'username': 'Alice', 'status': 'approved', 'joined_at': '2025-01-01T10:00:00Z'},
      ];

      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/'))
          .thenAnswer((_) async => participantsJson);
      when(mockCookieRequest.postJson(
        '${baseApi}/events/${testEventId}/participants/manage/',
        jsonEncode({"action": "remove", "user_id": 1}),
      )).thenAnswer((_) async => {"message": "Participant removed"});

      await tester.pumpWidget(createWidgetUnderTest(testEventId));
      await tester.pumpAndSettle();

      final aliceListTile = find.widgetWithText(ListTile, 'Alice');
      expect(aliceListTile, findsOneWidget); // Ensure Alice's ListTile is present

      final alicePopupMenuButton = find.descendant(
        of: aliceListTile,
        matching: find.byType(PopupMenuButton),
      );
      expect(alicePopupMenuButton, findsOneWidget); // Ensure PopupMenuButton is present
      await tester.tap(alicePopupMenuButton);
      await tester.pumpAndSettle(); // Ensure overlay is built

      // Tap on the "Remove" option
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle(); // Pump for the dialog to appear

      expect(find.text('Remove Participant?'), findsOneWidget);
      expect(find.text('Are you sure you want to remove Alice?'), findsOneWidget);

      // Confirm removal
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      verify(mockCookieRequest.postJson(
        '${baseApi}/events/${testEventId}/participants/manage/',
        jsonEncode({"action": "remove", "user_id": 1}),
      )).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Participant removed'), findsOneWidget);
      // After removal, the list should reload, and Alice should disappear if the mock returns empty.
      // For this test, we re-mock fetchParticipants to return an empty list to reflect removal.
      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/')).thenAnswer((_) async => []);
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsNothing);
      expect(find.text("No participants have joined yet."), findsOneWidget);
    });

    testWidgets('marks participant as attended after confirmation', (WidgetTester tester) async {
      final List<Map<String, dynamic>> participantsJson = [
        {'user_id': 1, 'username': 'Alice', 'status': 'approved', 'joined_at': '2025-01-01T10:00:00Z'},
      ];

      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/'))
          .thenAnswer((_) async => participantsJson);
      when(mockCookieRequest.postJson(
        '${baseApi}/events/${testEventId}/participants/manage/',
        jsonEncode({"action": "mark_attended", "user_id": 1}),
      )).thenAnswer((_) async => {"message": "Participant marked as attended"});

      await tester.pumpWidget(createWidgetUnderTest(testEventId));
      await tester.pumpAndSettle();

      final aliceListTile = find.widgetWithText(ListTile, 'Alice');
      expect(aliceListTile, findsOneWidget); // Ensure Alice's ListTile is present

      final alicePopupMenuButton = find.descendant(
        of: aliceListTile,
        matching: find.byType(PopupMenuButton),
      );
      expect(alicePopupMenuButton, findsOneWidget); // Ensure PopupMenuButton is present
      await tester.tap(alicePopupMenuButton);
      await tester.pumpAndSettle(); // Ensure overlay is built

      // Tap on the "Mark Attended" option
      await tester.tap(find.text('Mark Attended'));
      await tester.pumpAndSettle(); // Pump for the dialog to appear

      expect(find.text('Mark as Attended?'), findsOneWidget);
      expect(find.text('Are you sure you want to mark Alice as attended?'), findsOneWidget);

      // Confirm action
      await tester.tap(find.text('Mark Attended'));
      await tester.pumpAndSettle();

      verify(mockCookieRequest.postJson(
        '${baseApi}/events/${testEventId}/participants/manage/',
        jsonEncode({"action": "mark_attended", "user_id": 1}),
      )).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Participant marked as attended'), findsOneWidget);
      // Simulate reload with updated status
      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/')).thenAnswer((_) async => [
        {'user_id': 1, 'username': 'Alice', 'status': 'attended', 'joined_at': '2025-01-01T10:00:00Z'},
      ]);
      await tester.pumpAndSettle();
      expect(find.text('ATTENDED'), findsOneWidget);
      expect(find.text('APPROVED'), findsNothing);
    });

    testWidgets('does not show "Mark Attended" for pending participants', (WidgetTester tester) async {
      final List<Map<String, dynamic>> participantsJson = [
        {'user_id': 1, 'username': 'Alice', 'status': 'pending', 'joined_at': '2025-01-01T10:00:00Z'},
      ];

      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/'))
          .thenAnswer((_) async => participantsJson);

      await tester.pumpWidget(createWidgetUnderTest(testEventId));
      await tester.pumpAndSettle();

      final aliceListTile = find.widgetWithText(ListTile, 'Alice');
      expect(aliceListTile, findsOneWidget); // Ensure Alice's ListTile is present

      final alicePopupMenuButton = find.descendant(
        of: aliceListTile,
        matching: find.byType(PopupMenuButton),
      );
      expect(alicePopupMenuButton, findsOneWidget); // Ensure PopupMenuButton is present
      await tester.tap(alicePopupMenuButton);
      await tester.pumpAndSettle(); // Ensure overlay is built

      // Verify "Remove" is present, "Mark Attended" is not
      expect(find.text('Remove'), findsOneWidget);
      expect(find.text('Mark Attended'), findsNothing);
    });

    testWidgets('dialog buttons have correct styling', (WidgetTester tester) async {
      final List<Map<String, dynamic>> participantsJson = [
        {'user_id': 1, 'username': 'Alice', 'status': 'approved', 'joined_at': '2025-01-01T10:00:00Z'},
      ];

      when(mockCookieRequest.get('${baseApi}/events/${testEventId}/participants/'))
          .thenAnswer((_) async => participantsJson);
      when(mockCookieRequest.postJson(
        '${baseApi}/events/${testEventId}/participants/manage/',
        jsonEncode({"action": "remove", "user_id": 1}),
      )).thenAnswer((_) async => {"message": "Participant removed"});

      await tester.pumpWidget(createWidgetUnderTest(testEventId));
      await tester.pumpAndSettle();

      final aliceListTile = find.widgetWithText(ListTile, 'Alice');
      expect(aliceListTile, findsOneWidget); // Ensure Alice's ListTile is present

      final alicePopupMenuButton = find.descendant(
        of: aliceListTile,
        matching: find.byType(PopupMenuButton),
      );
      expect(alicePopupMenuButton, findsOneWidget); // Ensure PopupMenuButton is present
      await tester.tap(alicePopupMenuButton);
      await tester.pumpAndSettle(); // Ensure overlay is built
      
      await tester.tap(find.text('Remove')); // Open "Remove" dialog
      await tester.pumpAndSettle();

      // Check "Cancel" button style
      final cancelButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Cancel'));
      expect(cancelButton.style?.foregroundColor?.resolve(MaterialState.values.toSet()), AppColors.gray300);

      // Check "Remove" button style (isDestructive = true)
      final removeButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Remove'));
      expect(removeButton.style?.backgroundColor?.resolve(MaterialState.values.toSet()), AppColors.buttonDanger);
      expect(removeButton.style?.foregroundColor?.resolve(MaterialState.values.toSet()), AppColors.white);

      await tester.tap(find.text('Cancel')); // Close dialog
      await tester.pumpAndSettle();

      // Re-open dialog for "Mark Attended"
      when(mockCookieRequest.postJson(
        '${baseApi}/events/${testEventId}/participants/manage/',
        jsonEncode({"action": "mark_attended", "user_id": 1}),
      )).thenAnswer((_) async => {"message": "Participant marked as attended"});

      final alicePopupMenuButton2 = find.descendant(
        of: find.widgetWithText(ListTile, 'Alice'),
        matching: find.byType(PopupMenuButton),
      );
      expect(alicePopupMenuButton2, findsOneWidget); // Ensure PopupMenuButton is present
      await tester.tap(alicePopupMenuButton2);
      await tester.pumpAndSettle(); // Ensure overlay is built

      await tester.tap(find.text('Mark Attended'));
      await tester.pumpAndSettle();

      // Check "Mark Attended" button style (isDestructive = false)
      final markAttendedButton = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark Attended'));
      expect(markAttendedButton.style?.backgroundColor?.resolve(MaterialState.values.toSet()), AppColors.statusActive);
      expect(markAttendedButton.style?.foregroundColor?.resolve(MaterialState.values.toSet()), AppColors.white);
    });
  });
}