/// Sport preference model
class SportPreferenceModel {
  final int id;
  final String sportType;
  final String sportTypeDisplay;
  final String skillLevel;
  final String skillLevelDisplay;
  final DateTime createdAt;

  SportPreferenceModel({
    required this.id,
    required this.sportType,
    required this.sportTypeDisplay,
    required this.skillLevel,
    required this.skillLevelDisplay,
    required this.createdAt,
  });

  /// Create SportPreferenceModel from JSON
  factory SportPreferenceModel.fromJson(Map<String, dynamic> json) {
    return SportPreferenceModel(
      id: json['id'] as int,
      sportType: json['sport_type'] as String,
      sportTypeDisplay: json['sport_type_display'] as String,
      skillLevel: json['skill_level'] as String,
      skillLevelDisplay: json['skill_level_display'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert SportPreferenceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sport_type': sportType,
      'sport_type_display': sportTypeDisplay,
      'skill_level': skillLevel,
      'skill_level_display': skillLevelDisplay,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get emoji for sport type
  String get sportEmoji {
    switch (sportType) {
      case 'football':
        return '⚽';
      case 'basketball':
        return '🏀';
      case 'badminton':
        return '🏸';
      case 'tennis':
        return '🎾';
      case 'running':
        return '🏃';
      case 'cycling':
        return '🚴';
      case 'swimming':
        return '🏊';
      case 'volleyball':
        return '🏐';
      default:
        return '⚡';
    }
  }

  /// Get emoji for skill level
  String get skillEmoji {
    switch (skillLevel) {
      case 'beginner':
        return '🌱';
      case 'intermediate':
        return '⭐';
      case 'advanced':
        return '🏆';
      default:
        return '⚡';
    }
  }

  @override
  String toString() {
    return 'SportPreferenceModel(id: $id, sportType: $sportType, skillLevel: $skillLevel)';
  }
}

