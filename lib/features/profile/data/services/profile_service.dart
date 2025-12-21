import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/features/profile/data/models/profile_response.dart';
import 'package:bond_up_mobile/features/auth/data/services/auth_service.dart';

/// Profile service for handling profile-related API calls
class ProfileService {
  final CookieRequest request;

  ProfileService(this.request);

  /// Get authenticated user's own profile
  Future<ProfileResponse> getOwnProfile() async {
    try {
      final response = await request.get(
        '${AuthService.baseUrl}/auth/flutter/profile/',
      );

      return ProfileResponse.fromJson(response);
    } catch (e) {
      return ProfileResponse(
        status: false,
        message: 'Failed to fetch profile: ${e.toString()}',
      );
    }
  }

  /// Get another user's profile by user ID
  Future<ProfileResponse> getUserProfile(int userId) async {
    try {
      final response = await request.get(
        '${AuthService.baseUrl}/auth/flutter/profile/$userId/',
      );

      return ProfileResponse.fromJson(response);
    } catch (e) {
      return ProfileResponse(
        status: false,
        message: 'Failed to fetch user profile: ${e.toString()}',
      );
    }
  }

  /// Refresh profile data (alias for getOwnProfile)
  Future<ProfileResponse> refreshProfile() async {
    return getOwnProfile();
  }

  /// Update authenticated user's profile
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String bio,
    required String city,
  }) async {
    try {
      final response = await request.postJson(
        '${AuthService.baseUrl}/auth/flutter/profile/update/',
        jsonEncode({
          'full_name': fullName,
          'bio': bio,
          'city': city,
        }),
      );

      return response;
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to update profile: ${e.toString()}',
      };
    }
  }

  /// Add a new sport preference
  Future<Map<String, dynamic>> addSportPreference({
    required String sportType,
    required String skillLevel,
  }) async {
    try {
      final response = await request.postJson(
        '${AuthService.baseUrl}/auth/flutter/profile/sport-preferences/add/',
        jsonEncode({
          'sport_type': sportType,
          'skill_level': skillLevel,
        }),
      );

      return response;
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to add sport preference: ${e.toString()}',
      };
    }
  }

  /// Delete a sport preference
  Future<Map<String, dynamic>> deleteSportPreference(int preferenceId) async {
    try {
      // Using POST since pbp_django_auth doesn't have a delete method
      final response = await request.postJson(
        '${AuthService.baseUrl}/auth/flutter/profile/sport-preferences/$preferenceId/delete/',
        jsonEncode({}),
      );

      return response;
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to delete sport preference: ${e.toString()}',
      };
    }
  }

  /// Upload profile image URL
  Future<Map<String, dynamic>> uploadProfileImage(String imageUrl) async {
    try {
      final response = await request.postJson(
        '${AuthService.baseUrl}/auth/flutter/profile/upload-image/',
        jsonEncode({
          'profile_image_url': imageUrl,
        }),
      );

      return response;
    } catch (e) {
      return {
        'status': false,
        'message': 'Failed to upload profile image: ${e.toString()}',
      };
    }
  }
}

