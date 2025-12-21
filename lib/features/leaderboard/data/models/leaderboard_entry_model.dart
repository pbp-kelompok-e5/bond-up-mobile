/// Model for a single leaderboard entry
class LeaderboardEntryModel {
  final int rank;
  final int userId;
  final String username;
  final String fullName;
  final String profileImageUrl;
  final int totalPoints;
  final int totalEvents;
  final String tier;
  final String badge;

  LeaderboardEntryModel({
    required this.rank,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.profileImageUrl,
    required this.totalPoints,
    required this.totalEvents,
    required this.tier,
    required this.badge,
  });

  /// Create LeaderboardEntryModel from JSON
  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: int.parse(json['rank'].toString()),
      userId: int.parse(json['user_id'].toString()),
      username: json['username']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      profileImageUrl: json['profile_image_url']?.toString() ?? '',
      totalPoints: int.parse(json['total_points'].toString()),
      totalEvents: int.parse(json['total_events'].toString()),
      tier: json['tier']?.toString() ?? '',
      badge: json['badge']?.toString() ?? '',
    );
  }

  /// Convert LeaderboardEntryModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'user_id': userId,
      'username': username,
      'full_name': fullName,
      'profile_image_url': profileImageUrl,
      'total_points': totalPoints,
      'total_events': totalEvents,
      'tier': tier,
      'badge': badge,
    };
  }
}

/// Model for leaderboard response
class LeaderboardResponseModel {
  final bool status;
  final String message;
  final List<LeaderboardEntryModel> users;
  final int? currentUserRank;
  final int totalUsers;
  final int currentPage;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  LeaderboardResponseModel({
    required this.status,
    required this.message,
    required this.users,
    this.currentUserRank,
    required this.totalUsers,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasNext = false,
    this.hasPrevious = false,
  });

  /// Create LeaderboardResponseModel from JSON
  factory LeaderboardResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final usersList = data['users'] as List<dynamic>? ?? [];

    return LeaderboardResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      users: usersList
          .map((user) => LeaderboardEntryModel.fromJson(user as Map<String, dynamic>))
          .toList(),
      currentUserRank: data['current_user_rank'] as int?,
      totalUsers: data['total_users'] as int? ?? 0,
      currentPage: data['current_page'] as int? ?? 1,
      totalPages: data['total_pages'] as int? ?? 1,
      hasNext: data['has_next'] as bool? ?? false,
      hasPrevious: data['has_previous'] as bool? ?? false,
    );
  }
}

