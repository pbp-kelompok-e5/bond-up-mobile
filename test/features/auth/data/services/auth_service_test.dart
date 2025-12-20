import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';

// Generate mocks for CookieRequest
@GenerateMocks([CookieRequest])
import 'auth_service_test.mocks.dart';

void main() {
  late MockCookieRequest mockCookieRequest;
  late AuthService authService;

  setUp(() {
    mockCookieRequest = MockCookieRequest();
    authService = AuthService(mockCookieRequest);
    // Initialize SharedPreferences with empty values for testing
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService - register', () {
    const testUsername = 'testuser';
    const testPassword1 = 'testpass123';
    const testPassword2 = 'testpass123';

    test('should return successful AuthResponse when registration succeeds', () async {
      // Arrange
      final expectedResponse = {
        'status': true,
        'message': 'User created successfully!',
        'username': testUsername,
      };

      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await authService.register(
        testUsername,
        testPassword1,
        testPassword2,
      );

      // Assert
      expect(result.status, true);
      expect(result.message, 'User created successfully!');
      expect(result.username, testUsername);

      // Verify the correct endpoint was called
      verify(mockCookieRequest.postJson(
        '${AuthService.baseUrl}/auth/flutter/register/',
        jsonEncode({
          'username': testUsername,
          'password1': testPassword1,
          'password2': testPassword2,
        }),
      )).called(1);
    });

    test('should return failed AuthResponse when registration fails', () async {
      // Arrange
      final expectedResponse = {
        'status': false,
        'message': 'Username already exists.',
      };

      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await authService.register(
        testUsername,
        testPassword1,
        testPassword2,
      );

      // Assert
      expect(result.status, false);
      expect(result.message, 'Username already exists.');
      expect(result.username, isNull);
    });

    test('should return failed AuthResponse when exception occurs', () async {
      // Arrange
      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenThrow(Exception('Network error'));

      // Act
      final result = await authService.register(
        testUsername,
        testPassword1,
        testPassword2,
      );

      // Assert
      expect(result.status, false);
      expect(result.message, contains('Registration failed'));
      expect(result.message, contains('Network error'));
    });

    test('should send correct JSON payload to register endpoint', () async {
      // Arrange
      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => {
            'status': true,
            'message': 'Success',
            'username': testUsername,
          });

      // Act
      await authService.register(testUsername, testPassword1, testPassword2);

      // Assert
      final captured = verify(mockCookieRequest.postJson(
        captureAny,
        captureAny,
      )).captured;

      expect(captured[0], '${AuthService.baseUrl}/auth/flutter/register/');
      final payload = json.decode(captured[1]);
      expect(payload['username'], testUsername);
      expect(payload['password1'], testPassword1);
      expect(payload['password2'], testPassword2);
    });
  });

  group('AuthService - login', () {
    const testUsername = 'testuser';
    const testPassword = 'testpass123';

    test('should return successful AuthResponse and save user data when login succeeds', () async {
      // Arrange
      final expectedResponse = {
        'status': true,
        'message': 'Login successful!',
        'username': testUsername,
      };

      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await authService.login(testUsername, testPassword);

      // Assert
      expect(result.status, true);
      expect(result.message, 'Login successful!');
      expect(result.username, testUsername);

      // Verify user data was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('username'), testUsername);
      expect(prefs.getBool('isLoggedIn'), true);

      // Verify the correct endpoint was called
      verify(mockCookieRequest.postJson(
        '${AuthService.baseUrl}/auth/flutter/login/',
        jsonEncode({
          'username': testUsername,
          'password': testPassword,
        }),
      )).called(1);
    });

    test('should return failed AuthResponse when login fails', () async {
      // Arrange
      final expectedResponse = {
        'status': false,
        'message': 'Invalid username or password.',
      };

      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await authService.login(testUsername, testPassword);

      // Assert
      expect(result.status, false);
      expect(result.message, 'Invalid username or password.');
      expect(result.username, isNull);

      // Verify user data was NOT saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('username'), isNull);
      expect(prefs.getBool('isLoggedIn'), isNull);
    });

    test('should return failed AuthResponse when exception occurs during login', () async {
      // Arrange
      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenThrow(Exception('Connection timeout'));

      // Act
      final result = await authService.login(testUsername, testPassword);

      // Assert
      expect(result.status, false);
      expect(result.message, contains('Login failed'));
      expect(result.message, contains('Connection timeout'));
    });

    test('should send correct JSON payload to login endpoint', () async {
      // Arrange
      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => {
            'status': true,
            'message': 'Success',
            'username': testUsername,
          });

      // Act
      await authService.login(testUsername, testPassword);

      // Assert
      final captured = verify(mockCookieRequest.postJson(
        captureAny,
        captureAny,
      )).captured;

      expect(captured[0], '${AuthService.baseUrl}/auth/flutter/login/');
      final payload = json.decode(captured[1]);
      expect(payload['username'], testUsername);
      expect(payload['password'], testPassword);
    });

    test('should not save user data when login response has no username', () async {
      // Arrange
      final expectedResponse = {
        'status': true,
        'message': 'Login successful!',
        // username is missing
      };

      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await authService.login(testUsername, testPassword);

      // Assert
      expect(result.status, true);
      expect(result.username, isNull);

      // Verify user data was NOT saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('username'), isNull);
    });
  });

  group('AuthService - logout', () {
    test('should return true and clear user data when logout succeeds', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', 'testuser');
      await prefs.setBool('isLoggedIn', true);

      final expectedResponse = {
        'status': true,
        'message': 'Logout successful!',
      };

      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await authService.logout();

      // Assert
      expect(result, true);

      // Verify user data was cleared
      expect(prefs.getString('username'), isNull);
      expect(prefs.getBool('isLoggedIn'), isNull);

      // Verify the correct endpoint was called
      verify(mockCookieRequest.postJson(
        '${AuthService.baseUrl}/auth/flutter/logout/',
        jsonEncode({}),
      )).called(1);
    });

    test('should clear user data even when logout request fails', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', 'testuser');
      await prefs.setBool('isLoggedIn', true);

      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenThrow(Exception('Network error'));

      // Act
      final result = await authService.logout();

      // Assert
      expect(result, false);

      // Verify user data was still cleared
      expect(prefs.getString('username'), isNull);
      expect(prefs.getBool('isLoggedIn'), isNull);
    });

    test('should handle response without status field', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', 'testuser');
      await prefs.setBool('isLoggedIn', true);

      final expectedResponse = {
        'message': 'Logout successful!',
        // status field is missing
      };

      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await authService.logout();

      // Assert
      expect(result, true); // Should default to true

      // Verify user data was cleared
      expect(prefs.getString('username'), isNull);
      expect(prefs.getBool('isLoggedIn'), isNull);
    });
  });

  group('AuthService - isLoggedIn', () {
    test('should return true when username exists and request.loggedIn is true', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', 'testuser');

      when(mockCookieRequest.loggedIn).thenReturn(true);

      // Act
      final result = await authService.isLoggedIn();

      // Assert
      expect(result, true);
    });

    test('should return false when username exists but request.loggedIn is false', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', 'testuser');

      when(mockCookieRequest.loggedIn).thenReturn(false);

      // Act
      final result = await authService.isLoggedIn();

      // Assert
      expect(result, false);
    });

    test('should return false when username does not exist', () async {
      // Arrange
      when(mockCookieRequest.loggedIn).thenReturn(true);

      // Act
      final result = await authService.isLoggedIn();

      // Assert
      expect(result, false);
    });

    test('should return false when both username and request.loggedIn are false', () async {
      // Arrange
      when(mockCookieRequest.loggedIn).thenReturn(false);

      // Act
      final result = await authService.isLoggedIn();

      // Assert
      expect(result, false);
    });
  });

  group('AuthService - getCurrentUser', () {
    test('should return UserModel when username exists in SharedPreferences', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', 'testuser');

      // Act
      final result = await authService.getCurrentUser();

      // Assert
      expect(result, isNotNull);
      expect(result!.username, 'testuser');
      expect(result.email, isNull);
    });

    test('should return null when username does not exist in SharedPreferences', () async {
      // Act
      final result = await authService.getCurrentUser();

      // Assert
      expect(result, isNull);
    });

    test('should return null when SharedPreferences is empty', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Act
      final result = await authService.getCurrentUser();

      // Assert
      expect(result, isNull);
    });
  });

  group('AuthService - edge cases', () {
    test('should handle empty username in register', () async {
      // Arrange
      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => {
            'status': false,
            'message': 'Username is required.',
          });

      // Act
      final result = await authService.register('', 'pass123', 'pass123');

      // Assert
      expect(result.status, false);
    });

    test('should handle empty password in login', () async {
      // Arrange
      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => {
            'status': false,
            'message': 'Password is required.',
          });

      // Act
      final result = await authService.login('testuser', '');

      // Assert
      expect(result.status, false);
    });

    test('should handle special characters in username', () async {
      // Arrange
      const specialUsername = 'test@user#123';
      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => {
            'status': true,
            'message': 'Success',
            'username': specialUsername,
          });

      // Act
      final result = await authService.login(specialUsername, 'password');

      // Assert
      expect(result.status, true);
      expect(result.username, specialUsername);
    });

    test('should handle very long error messages', () async {
      // Arrange
      final longMessage = 'Error: ${'x' * 1000}';
      when(mockCookieRequest.postJson(
        any,
        any,
      )).thenAnswer((_) async => {
            'status': false,
            'message': longMessage,
          });

      // Act
      final result = await authService.login('testuser', 'password');

      // Assert
      expect(result.status, false);
      expect(result.message, longMessage);
    });
  });
}

