import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Import model dan service kamu
import 'package:bond_up_mobile/features/leaderboard/data/services/leaderboard_service.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/leaderboard_entry_model.dart'; // Untuk referensi tipe jika perlu
import 'package:bond_up_mobile/features/leaderboard/data/models/points_dashboard_model.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/points_history_model.dart';

// Annotation ini akan memerintahkan build_runner membuat file mock
@GenerateMocks([CookieRequest])
import 'leaderboard_service_test.mocks.dart';

void main() {
  late MockCookieRequest mockRequest;
  late LeaderboardService service;

  setUp(() {
    mockRequest = MockCookieRequest();
    service = LeaderboardService(mockRequest);
  });

  // --- Group: Get Leaderboard ---
  group('getLeaderboard', () {
    final tResponseJson = {
      'status': true,
      'message': 'Success',
      'data': {
        'users': [],
        'total_users': 0,
      }
    };

    test('should return LeaderboardResponseModel when API call is successful', () async {
      // Arrange
      // Kita menggunakan matcher 'contains' untuk URL agar tidak perlu hardcode base URL
      when(mockRequest.get(argThat(contains('/leaderboard/api/flutter/leaderboard/'))))
          .thenAnswer((_) async => tResponseJson);

      // Act
      final result = await service.getLeaderboard(page: 1, limit: 10);

      // Assert
      expect(result.status, true);
      // Verifikasi URL dipanggil dengan query param yang benar
      verify(mockRequest.get(argThat(contains('page=1&limit=10')))).called(1);
    });

    test('should return error model when API call throws exception', () async {
      // Arrange
      when(mockRequest.get(any))
          .thenThrow(Exception('Network Error'));

      // Act
      final result = await service.getLeaderboard();

      // Assert
      expect(result.status, false);
      expect(result.message, contains('Network Error'));
      expect(result.users, isEmpty);
    });
  });

  // --- Group: Get Points Dashboard ---
  group('getPointsDashboard', () {
    final tDashboardJson = {
      'status': true,
      'message': 'Success',
      'data': {
        'total_points': 100,
        'breakdown': {},
        'recent_achievements': []
      }
    };

    test('should return PointsDashboardResponseModel when API call is successful', () async {
      // Arrange
      when(mockRequest.get(argThat(contains('/points/dashboard/'))))
          .thenAnswer((_) async => tDashboardJson);

      // Act
      final result = await service.getPointsDashboard();

      // Assert
      expect(result.status, true);
      expect(result.data?.totalPoints, 100);
      verify(mockRequest.get(argThat(contains('/points/dashboard/')))).called(1);
    });

    test('should return error model when API call throws exception', () async {
      // Arrange
      when(mockRequest.get(any)).thenThrow(Exception('Server Error'));

      // Act
      final result = await service.getPointsDashboard();

      // Assert
      expect(result.status, false);
      expect(result.message, contains('Server Error'));
      expect(result.data, isNull);
    });
  });

  // --- Group: Get Points History ---
  group('getPointsHistory', () {
    final tHistoryJson = {
      'status': true,
      'message': 'Success',
      'data': {
        'transactions': [],
        'total_transactions': 0
      }
    };

    test('should call API correctly WITHOUT filter (activityType null)', () async {
      // Arrange
      when(mockRequest.get(any)).thenAnswer((_) async => tHistoryJson);

      // Act
      final result = await service.getPointsHistory(limit: 50);

      // Assert
      expect(result.status, true);
      
      // Verifikasi URL hanya mengandung limit, TANPA activity_type
      // Kita capture argumen URL untuk diperiksa
      final verifyResult = verify(mockRequest.get(captureAny));
      final capturedUrl = verifyResult.captured.single as String;
      
      expect(capturedUrl, contains('limit=50'));
      expect(capturedUrl, isNot(contains('activity_type=')));
    });

    test('should call API correctly WITH filter (activityType present)', () async {
      // Arrange
      when(mockRequest.get(any)).thenAnswer((_) async => tHistoryJson);

      // Act
      await service.getPointsHistory(limit: 20, activityType: 'event_join');

      // Assert
      // Verifikasi URL mengandung limit DAN activity_type
      final verifyResult = verify(mockRequest.get(captureAny));
      final capturedUrl = verifyResult.captured.single as String;

      expect(capturedUrl, contains('limit=20'));
      expect(capturedUrl, contains('&activity_type=event_join'));
    });

    test('should return error model when API call throws exception', () async {
      // Arrange
      when(mockRequest.get(any)).thenThrow(Exception('Database Fail'));

      // Act
      final result = await service.getPointsHistory();

      // Assert
      expect(result.status, false);
      expect(result.message, contains('Database Fail'));
      expect(result.transactions, isEmpty);
    });
  });
}