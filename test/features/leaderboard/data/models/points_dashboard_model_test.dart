import 'package:flutter_test/flutter_test.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/points_dashboard_model.dart'; 

void main() {
  // --- 1. Data Dummy untuk ActivityBreakdownModel ---
  final tBreakdownJson = {
    'label': 'Event Participation',
    'total': 100,
    'count': 5,
  };

  final tBreakdownModel = ActivityBreakdownModel(
    label: 'Event Participation',
    total: 100,
    count: 5,
  );

  // --- 2. Data Dummy untuk AchievementModel ---
  final tDateStr = '2025-01-01T10:00:00.000';
  final tDate = DateTime.parse(tDateStr);
  
  final tAchievementJson = {
    'id': 1,
    'achievement_code': 'FIRST_LOGIN',
    'title': 'Welcome',
    'description': 'First time logging in',
    'bonus_points': 50,
    'earned_at': tDateStr,
  };

  final tAchievementModel = AchievementModel(
    id: 1,
    achievementCode: 'FIRST_LOGIN',
    title: 'Welcome',
    description: 'First time logging in',
    bonusPoints: 50,
    earnedAt: tDate,
  );

  // --- Tests untuk ActivityBreakdownModel ---
  group('ActivityBreakdownModel', () {
    test('fromJson should return valid model', () {
      final result = ActivityBreakdownModel.fromJson(tBreakdownJson);
      expect(result.label, 'Event Participation');
      expect(result.total, 100);
      expect(result.count, 5);
    });

    test('toJson should return valid map', () {
      final result = tBreakdownModel.toJson();
      expect(result, tBreakdownJson);
    });
  });

  // --- Tests untuk AchievementModel ---
  group('AchievementModel', () {
    test('fromJson should parse DateTime correctly', () {
      final result = AchievementModel.fromJson(tAchievementJson);
      expect(result.id, 1);
      expect(result.earnedAt, tDate);
    });

    test('toJson should convert DateTime to ISO string', () {
      final result = tAchievementModel.toJson();
      expect(result['earned_at'], tDateStr);
      expect(result['achievement_code'], 'FIRST_LOGIN');
    });
  });

  // --- Tests untuk PointsDashboardModel ---
  group('PointsDashboardModel', () {
    // Struktur JSON lengkap (Happy Path)
    final tDashboardDataJson = {
      'data': {
        'total_points': 1000,
        'total_events': 20,
        'current_rank': 5,
        'tier': 'Gold',
        'badge': 'Sultan',
        'breakdown': {
          'participation': tBreakdownJson,
        },
        'recent_achievements': [tAchievementJson]
      }
    };

    test('fromJson should return valid model with populated lists and maps', () {
      // Act
      final result = PointsDashboardModel.fromJson(tDashboardDataJson);

      // Assert
      expect(result.totalPoints, 1000);
      expect(result.currentRank, 5);
      expect(result.tier, 'Gold');
      // Cek apakah breakdown map terisi
      expect(result.breakdown.length, 1);
      expect(result.breakdown['participation']?.label, 'Event Participation');
      // Cek apakah achievements list terisi
      expect(result.recentAchievements.length, 1);
      expect(result.recentAchievements.first.achievementCode, 'FIRST_LOGIN');
    });

    test('fromJson should handle null fields with default values', () {
      // Arrange: JSON dengan field 'data' kosong untuk memicu default values
      final tEmptyDataJson = {
        'data': <String, dynamic>{}
      };

      // Act
      final result = PointsDashboardModel.fromJson(tEmptyDataJson);

      // Assert
      // Menguji: totalPoints: data['total_points'] as int? ?? 0
      expect(result.totalPoints, 0);
      
      // Menguji: totalEvents: data['total_events'] as int? ?? 0
      expect(result.totalEvents, 0);
      
      // Menguji: currentRank (nullable)
      expect(result.currentRank, isNull);
      
      // Menguji: tier: data['tier'] as String? ?? 'Beginner'
      expect(result.tier, 'Beginner');
      
      // Menguji: badge: data['badge'] as String? ?? '🔰'
      expect(result.badge, '🔰');
      
      // Menguji: breakdown map kosong
      expect(result.breakdown, isEmpty);
      
      // Menguji: recentAchievements list kosong
      expect(result.recentAchievements, isEmpty);
    });

    test('fromJson should handle null "data" key entirely', () {
      // Arrange: JSON tanpa key 'data' sama sekali
      final tNoDataKeyJson = <String, dynamic>{};

      // Act
      final result = PointsDashboardModel.fromJson(tNoDataKeyJson);

      // Assert
      // Memastikan: final data = json['data'] as Map<String, dynamic>? ?? {}; berjalan
      expect(result.totalPoints, 0);
      expect(result.tier, 'Beginner');
    });

    test('fromJson should handle breakdown being present but empty', () {
      // Arrange
      final jsonWithEmptyBreakdown = {
        'data': {
          'breakdown': {},
        }
      };

      // Act
      final result = PointsDashboardModel.fromJson(jsonWithEmptyBreakdown);

      // Assert
      expect(result.breakdown, isEmpty);
    });
  });

  // --- Tests untuk PointsDashboardResponseModel ---
  group('PointsDashboardResponseModel', () {
    test('fromJson should parse correctly when data is present', () {
      // Arrange
      final fullResponseJson = {
        'status': true,
        'message': 'Success',
        'data': { // Perhatikan struktur ini sesuai dengan PointsDashboardModel.fromJson
          'total_points': 500,
          'tier': 'Silver'
        }
      };

      // Act
      final result = PointsDashboardResponseModel.fromJson(fullResponseJson);

      // Assert
      expect(result.status, true);
      expect(result.message, 'Success');
      expect(result.data, isNotNull);
      expect(result.data?.totalPoints, 500);
    });

    test('fromJson should parse correctly when data is null', () {
      // Arrange
      final nullDataResponseJson = {
        'status': false,
        'message': 'Error',
        'data': null
      };

      // Act
      final result = PointsDashboardResponseModel.fromJson(nullDataResponseJson);

      // Assert
      expect(result.status, false);
      expect(result.message, 'Error');
      // Menguji: data: json['data'] != null ? ... : null
      expect(result.data, isNull);
    });

    test('fromJson should handle missing status/message fields', () {
      // Arrange
      final emptyJson = <String, dynamic>{};

      // Act
      final result = PointsDashboardResponseModel.fromJson(emptyJson);

      // Assert
      // Menguji default values untuk status dan message
      expect(result.status, false);
      expect(result.message, '');
      expect(result.data, isNull);
    });
  });
}