/// Model for activity breakdown in points dashboard
class ActivityBreakdownModel {
  final String label;
  final int total;
  final int count;

  ActivityBreakdownModel({
    required this.label,
    required this.total,
    required this.count,
  });

  /// Create ActivityBreakdownModel from JSON
  factory ActivityBreakdownModel.fromJson(Map<String, dynamic> json) {
    return ActivityBreakdownModel(
      label: json['label'] as String,
      total: json['total'] as int,
      count: json['count'] as int,
    );
  }

  /// Convert ActivityBreakdownModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'total': total,
      'count': count,
    };
  }
}

/// Model for achievement in points dashboard
class AchievementModel {
  final int id;
  final String achievementCode;
  final String title;
  final String description;
  final int bonusPoints;
  final DateTime earnedAt;

  AchievementModel({
    required this.id,
    required this.achievementCode,
    required this.title,
    required this.description,
    required this.bonusPoints,
    required this.earnedAt,
  });

  /// Create AchievementModel from JSON
  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as int,
      achievementCode: json['achievement_code'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      bonusPoints: json['bonus_points'] as int,
      earnedAt: DateTime.parse(json['earned_at'] as String),
    );
  }

  /// Convert AchievementModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'achievement_code': achievementCode,
      'title': title,
      'description': description,
      'bonus_points': bonusPoints,
      'earned_at': earnedAt.toIso8601String(),
    };
  }
}

/// Model for points dashboard data
class PointsDashboardModel {
  final int totalPoints;
  final int totalEvents;
  final int? currentRank;
  final String tier;
  final String badge;
  final Map<String, ActivityBreakdownModel> breakdown;
  final List<AchievementModel> recentAchievements;

  PointsDashboardModel({
    required this.totalPoints,
    required this.totalEvents,
    this.currentRank,
    required this.tier,
    required this.badge,
    required this.breakdown,
    required this.recentAchievements,
  });

  /// Create PointsDashboardModel from JSON
  factory PointsDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'])
        : <String, dynamic>{};

    final rawBreakdown = data['breakdown'];
    final achievementsList =
        data['recent_achievements'] as List<dynamic>? ?? [];

    final Map<String, ActivityBreakdownModel> breakdown = {};

    if (rawBreakdown is Map) {
      final breakdownMap = Map<String, dynamic>.from(rawBreakdown);

      breakdownMap.forEach((key, value) {
        if (value is Map) {
          breakdown[key] = ActivityBreakdownModel.fromJson(
            Map<String, dynamic>.from(value),
          );
        }
      });
    }

    return PointsDashboardModel(
      totalPoints: data['total_points'] as int? ?? 0,
      totalEvents: data['total_events'] as int? ?? 0,
      currentRank: data['current_rank'] as int?,
      tier: data['tier'] as String? ?? 'Beginner',
      badge: data['badge'] as String? ?? '🔰',
      breakdown: breakdown,
      recentAchievements: achievementsList
          .whereType<Map>()
          .map(
            (achievement) => AchievementModel.fromJson(
              Map<String, dynamic>.from(achievement),
            ),
          )
          .toList(),
    );
  }
}

/// Model for points dashboard response
class PointsDashboardResponseModel {
  final bool status;
  final String message;
  final PointsDashboardModel? data;

  PointsDashboardResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  /// Create PointsDashboardResponseModel from JSON
  factory PointsDashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return PointsDashboardResponseModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? PointsDashboardModel.fromJson(json) : null,
    );
  }
}