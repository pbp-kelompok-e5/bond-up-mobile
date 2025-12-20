import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/leaderboard_entry_model.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/points_dashboard_model.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/points_history_model.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';

/// Service for leaderboard and points-related API calls
class LeaderboardService {
  final CookieRequest request;

  LeaderboardService(this.request);

  /// Get leaderboard data
  ///
  /// Returns a ranked list of users based on total points
  ///
  /// Parameters:
  /// - [page]: Page number (default: 1)
  /// - [limit]: Number of users per page (default: 10)
  Future<LeaderboardResponseModel> getLeaderboard({int page = 1, int limit = 10}) async {
    try {
      final response = await request.get(
        '${AuthService.baseUrl}/leaderboard/api/flutter/leaderboard/?page=$page&limit=$limit',
      );

      return LeaderboardResponseModel.fromJson(response);
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
  /// 
  /// Returns the user's points summary, breakdown, and recent achievements
  Future<PointsDashboardResponseModel> getPointsDashboard() async {
    try {
      final response = await request.get(
        '${AuthService.baseUrl}/leaderboard/api/flutter/points/dashboard/',
      );

      return PointsDashboardResponseModel.fromJson(response);
    } catch (e) {
      return PointsDashboardResponseModel(
        status: false,
        message: 'Failed to fetch points dashboard: ${e.toString()}',
      );
    }
  }

  /// Get authenticated user's points transaction history
  /// 
  /// Returns a list of all points transactions for the user
  /// 
  /// Parameters:
  /// - [limit]: Maximum number of transactions to return (default: 100)
  /// - [activityType]: Filter by activity type (optional)
  Future<PointsHistoryResponseModel> getPointsHistory({
    int limit = 100,
    String? activityType,
  }) async {
    try {
      String url = '${AuthService.baseUrl}/leaderboard/api/flutter/points/history/?limit=$limit';
      
      if (activityType != null && activityType.isNotEmpty) {
        url += '&activity_type=$activityType';
      }

      final response = await request.get(url);

      return PointsHistoryResponseModel.fromJson(response);
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

