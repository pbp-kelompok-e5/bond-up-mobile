import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/leaderboard_entry_model.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/points_dashboard_model.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/points_history_model.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';

/// Service for leaderboard and points-related API calls
class LeaderboardService {
  final CookieRequest request;

  LeaderboardService(this.request);

  /// Helper untuk menormalkan response Map dari backend / mock
  Map<String, dynamic> _safeMap(dynamic response) {
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return <String, dynamic>{};
  }

  /// Get leaderboard data
  Future<LeaderboardResponseModel> getLeaderboard({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await request.get(
        '${AuthService.baseUrl}/leaderboard/api/flutter/leaderboard/?page=$page&limit=$limit',
      );

      final json = _safeMap(response);
      return LeaderboardResponseModel.fromJson(json);
    } catch (e) {
      return LeaderboardResponseModel(
        status: false,
        message: 'Failed to fetch leaderboard: ${e.toString()}',
        users: [],
        totalUsers: 0,
      );
    }
  }

  /// Get authenticated user's points dashboard
  Future<PointsDashboardResponseModel> getPointsDashboard() async {
    try {
      final response = await request.get(
        '${AuthService.baseUrl}/leaderboard/api/flutter/points/dashboard/',
      );

      final json = _safeMap(response);
      return PointsDashboardResponseModel.fromJson(json);
    } catch (e) {
      return PointsDashboardResponseModel(
        status: false,
        message: 'Failed to fetch points dashboard: ${e.toString()}',
      );
    }
  }

  /// Get authenticated user's points transaction history
  Future<PointsHistoryResponseModel> getPointsHistory({
    int limit = 100,
    String? activityType,
  }) async {
    try {
      String url =
          '${AuthService.baseUrl}/leaderboard/api/flutter/points/history/?limit=$limit';

      if (activityType != null && activityType.isNotEmpty) {
        url += '&activity_type=$activityType';
      }

      final response = await request.get(url);

      final json = _safeMap(response);
      return PointsHistoryResponseModel.fromJson(json);
    } catch (e) {
      return PointsHistoryResponseModel(
        status: false,
        message: 'Failed to fetch points history: ${e.toString()}',
        transactions: [],
        totalTransactions: 0,
      );
    }
  }
}
