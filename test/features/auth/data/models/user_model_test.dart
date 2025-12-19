import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:bond_up_mobile/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    group('fromJson', () {
      test('should create UserModel from valid JSON with all fields', () {
        // Arrange
        final json = {
          'username': 'testuser',
          'email': 'test@example.com',
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.username, 'testuser');
        expect(result.email, 'test@example.com');
      });

      test('should create UserModel from JSON with null email', () {
        // Arrange
        final json = {
          'username': 'testuser',
          'email': null,
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.username, 'testuser');
        expect(result.email, isNull);
      });

      test('should create UserModel from JSON without email field', () {
        // Arrange
        final json = {
          'username': 'testuser',
        };

        // Act
        final result = UserModel.fromJson(json);

        // Assert
        expect(result.username, 'testuser');
        expect(result.email, isNull);
      });

      test('should throw when username is missing', () {
        // Arrange
        final json = {
          'email': 'test@example.com',
        };

        // Act & Assert
        expect(
          () => UserModel.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toJson', () {
      test('should convert UserModel to JSON with all fields', () {
        // Arrange
        final userModel = UserModel(
          username: 'testuser',
          email: 'test@example.com',
        );

        // Act
        final result = userModel.toJson();

        // Assert
        expect(result, {
          'username': 'testuser',
          'email': 'test@example.com',
        });
      });

      test('should convert UserModel to JSON with null email', () {
        // Arrange
        final userModel = UserModel(
          username: 'testuser',
          email: null,
        );

        // Act
        final result = userModel.toJson();

        // Assert
        expect(result, {
          'username': 'testuser',
          'email': null,
        });
      });
    });

    group('fromJsonString', () {
      test('should create UserModel from valid JSON string', () {
        // Arrange
        final jsonString = '{"username":"testuser","email":"test@example.com"}';

        // Act
        final result = UserModel.fromJsonString(jsonString);

        // Assert
        expect(result.username, 'testuser');
        expect(result.email, 'test@example.com');
      });

      test('should throw FormatException for invalid JSON string', () {
        // Arrange
        final invalidJsonString = 'invalid json';

        // Act & Assert
        expect(
          () => UserModel.fromJsonString(invalidJsonString),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('toJsonString', () {
      test('should convert UserModel to JSON string', () {
        // Arrange
        final userModel = UserModel(
          username: 'testuser',
          email: 'test@example.com',
        );

        // Act
        final result = userModel.toJsonString();

        // Assert
        final decoded = json.decode(result);
        expect(decoded['username'], 'testuser');
        expect(decoded['email'], 'test@example.com');
      });
    });

    group('toString', () {
      test('should return string representation of UserModel', () {
        // Arrange
        final userModel = UserModel(
          username: 'testuser',
          email: 'test@example.com',
        );

        // Act
        final result = userModel.toString();

        // Assert
        expect(result, 'UserModel(username: testuser, email: test@example.com)');
      });
    });
  });
}

