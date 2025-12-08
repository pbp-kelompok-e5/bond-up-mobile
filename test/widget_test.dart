import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

import 'package:bond_up_mobile/app/app_theme.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:bond_up_mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:bond_up_mobile/features/home/presentation/screens/home_page.dart';

// Create a mock for AuthService and CookieRequest
class MockAuthService extends Mock implements AuthService {}
class MockCookieRequest extends Mock implements CookieRequest {}

void main() {
  late MockAuthService mockAuthService;
  late MockCookieRequest mockCookieRequest;

  setUp(() {
    // Initialize the mocks before each test
    mockCookieRequest = MockCookieRequest();
    mockAuthService = MockAuthService();
    
    // Provide a default implementation for isLoggedIn to avoid null exceptions
    when(mockAuthService.isLoggedIn()).thenAnswer((_) async => false);
    when(mockAuthService.logout()).thenAnswer((_) async => true);
    // Link the mock AuthService to the mock CookieRequest
    when(mockAuthService.request).thenReturn(mockCookieRequest);
  });

  testWidgets('App starts and shows LoginScreen when not logged in', (WidgetTester tester) async {
    // Define the mock behavior for this specific test
    when(mockAuthService.isLoggedIn()).thenAnswer((_) async => false);

    // Build our app with the mocked services
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<CookieRequest>(create: (_) => mockCookieRequest),
          Provider<AuthService>(create: (_) => mockAuthService),
        ],
        child: MaterialApp(
          title: 'BondUp Mobile',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      ),
    );

    // Wait for the splash screen animations and auth check to complete
    await tester.pumpAndSettle();

    // Verify that LoginScreen is now shown
    expect(find.byType(LoginScreen), findsOneWidget);
    // Verify that MyHomePage is not shown
    expect(find.byType(MyHomePage), findsNothing);
  });
}
