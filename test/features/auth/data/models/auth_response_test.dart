import 'package:flutter_test/flutter_test.dart';
import 'package:bond_up_mobile/features/auth/data/models/auth_response.dart';

void main() {
  group('AuthResponse', () {
    group('fromJson', () {
      test('should create AuthResponse from JSON with status as boolean true', () {
        // Arrange
        final json = {
          'status': true,
          'message': 'Login successful!',
          'username': 'testuser',
        };

        // Act
        final result = AuthResponse.fromJson(json);

        // Assert
        expect(result.status, true);
        expect(result.message, 'Login successful!');
        expect(result.username, 'testuser');
      });

      test('should create AuthResponse from JSON with status as boolean false', () {
        // Arrange
        final json = {
          'status': false,
          'message': 'Login failed',
        };

        // Act
        final result = AuthResponse.fromJson(json);

        // Assert
        expect(result.status, false);
        expect(result.message, 'Login failed');
        expect(result.username, isNull);
      });

      test('should create AuthResponse from JSON with status as string "success"', () {
        // Arrange
        final json = {
          'status': 'success',
          'message': 'Registration successful!',
          'username': 'newuser',
        };

        // Act
        final result = AuthResponse.fromJson(json);

        // Assert
        expect(result.status, true);
        expect(result.message, 'Registration successful!');
        expect(result.username, 'newuser');
      });

      test('should create AuthResponse from JSON with status as other string', () {
        // Arrange
        final json = {
          'status': 'failed',
          'message': 'Error occurred',
        };

        // Act
        final result = AuthResponse.fromJson(json);

        // Assert
        expect(result.status, false);
        expect(result.message, 'Error occurred');
      });

      test('should handle missing message field with empty string', () {
        // Arrange
        final json = {
          'status': true,
        };

        // Act
        final result = AuthResponse.fromJson(json);

        // Assert
        expect(result.status, true);
        expect(result.message, '');
        expect(result.username, isNull);
      });

      test('should handle null username', () {
        // Arrange
        final json = {
          'status': true,
          'message': 'Success',
          'username': null,
        };

        // Act
        final result = AuthResponse.fromJson(json);

        // Assert
        expect(result.status, true);
        expect(result.message, 'Success');
        expect(result.username, isNull);
      });

      test('should handle missing username field', () {
        // Arrange
        final json = {
          'status': true,
          'message': 'Success',
        };

        // Act
        final result = AuthResponse.fromJson(json);

        // Assert
        expect(result.status, true);
        expect(result.message, 'Success');
        expect(result.username, isNull);
      });
    });

    group('toJson', () {
      test('should convert AuthResponse to JSON with all fields', () {
        // Arrange
        final authResponse = AuthResponse(
          status: true,
          message: 'Login successful!',
          username: 'testuser',
        );

        // Act
        final result = authResponse.toJson();

        // Assert
        expect(result, {
          'status': true,
          'message': 'Login successful!',
          'username': 'testuser',
        });
      });

      test('should convert AuthResponse to JSON with null username', () {
        // Arrange
        final authResponse = AuthResponse(
          status: false,
          message: 'Login failed',
        );

        // Act
        final result = authResponse.toJson();

        // Assert
        expect(result, {
          'status': false,
          'message': 'Login failed',
          'username': null,
        });
      });
    });

    group('toString', () {
      test('should return string representation of AuthResponse', () {
        // Arrange
        final authResponse = AuthResponse(
          status: true,
          message: 'Login successful!',
          username: 'testuser',
        );

        // Act
        final result = authResponse.toString();

        // Assert
        expect(
          result,
          'AuthResponse(status: true, message: Login successful!, username: testuser)',
        );
      });
    });
  });
}

