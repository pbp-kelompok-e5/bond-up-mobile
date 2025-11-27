import 'package:bond_up_mobile/features/profile/data/models/sport_preference_model.dart';

/// User profile model
class UserProfileModel {
  final int userId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String bio;
  final String city;
  final String cityDisplay;
  final String profileImageUrl;
  final int totalPoints;
  final int totalEvents;
  final DateTime createdAt;
  final List<SportPreferenceModel> sportPreferences;
  final bool isOwnProfile;

  UserProfileModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.bio,
    required this.city,
    required this.cityDisplay,
    required this.profileImageUrl,
    required this.totalPoints,
    required this.totalEvents,
    required this.createdAt,
    required this.sportPreferences,
    required this.isOwnProfile,
  });

  /// Create UserProfileModel from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>;
    final profileData = json['profile'] as Map<String, dynamic>;
    final sportPrefsData = json['sport_preferences'] as List<dynamic>;

    return UserProfileModel(
      userId: userData['id'] as int,
      username: userData['username'] as String,
      email: userData['email'] as String? ?? '',
      firstName: userData['first_name'] as String? ?? '',
      lastName: userData['last_name'] as String? ?? '',
      fullName: profileData['full_name'] as String,
      bio: profileData['bio'] as String? ?? '',
      city: profileData['city'] as String? ?? '',
      cityDisplay: profileData['city_display'] as String? ?? '',
      profileImageUrl: profileData['profile_image_url'] as String? ?? '',
      totalPoints: profileData['total_points'] as int,
      totalEvents: profileData['total_events'] as int,
      createdAt: DateTime.parse(profileData['created_at'] as String),
      sportPreferences: sportPrefsData
          .map((pref) => SportPreferenceModel.fromJson(pref as Map<String, dynamic>))
          .toList(),
      isOwnProfile: json['is_own_profile'] as bool,
    );
  }

  /// Convert UserProfileModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': {
        'id': userId,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      },
      'profile': {
        'full_name': fullName,
        'bio': bio,
        'city': city,
        'city_display': cityDisplay,
        'profile_image_url': profileImageUrl,
        'total_points': totalPoints,
        'total_events': totalEvents,
        'created_at': createdAt.toIso8601String(),
      },
      'sport_preferences': sportPreferences.map((pref) => pref.toJson()).toList(),
      'is_own_profile': isOwnProfile,
    };
  }

  /// Get display name (full name or username)
  String get displayName {
    return fullName.isNotEmpty ? fullName : username;
  }

  /// Get initials for avatar
  String get initials {
    if (fullName.isNotEmpty) {
      final parts = fullName.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName[0].toUpperCase();
    }
    return username[0].toUpperCase();
  }

  @override
  String toString() {
    return 'UserProfileModel(userId: $userId, username: $username, fullName: $fullName)';
  }
}

