import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bond_up_mobile/features/auth/data/models/auth_response.dart';
import 'package:bond_up_mobile/features/auth/data/models/user_model.dart';
import 'package:bond_up_mobile/core/constants/api_constants.dart';

/// Authentication service for handling login, register, and logout
class AuthService {
  /// Base URL for API requests - imported from centralized API constants
  static const String baseUrl = ApiConstants.baseUrl;

  final CookieRequest request;

  AuthService(this.request);

  /// Register new user using dedicated Flutter endpoint
  Future<AuthResponse> register(
    String username,
    String password1,
    String password2,
  ) async {
    try {
      final response = await request.postJson(
        '$baseUrl/auth/flutter/register/',  // Changed to Flutter endpoint
        jsonEncode({
          'username': username,
          'password1': password1,
          'password2': password2,
        }),
      );

      return AuthResponse.fromJson(response);
    } catch (e) {
      return AuthResponse(
        status: false,
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  /// Login user using dedicated Flutter endpoint
  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await request.postJson(
        '$baseUrl/auth/flutter/login/',  // Changed to Flutter endpoint
        jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final authResponse = AuthResponse.fromJson(response);

      // Save user data to SharedPreferences if login successful
      if (authResponse.status && authResponse.username != null) {
        await _saveUserData(authResponse.username!);
      }

      return authResponse;
    } catch (e) {
      return AuthResponse(
        status: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  /// Logout user using dedicated Flutter endpoint
  Future<bool> logout() async {
    try {
      final response = await request.postJson(
        '$baseUrl/auth/flutter/logout/',  // Changed to Flutter endpoint
        jsonEncode({}),
      );
      
      await _clearUserData();
      return response['status'] ?? true;
    } catch (e) {
      // Even if logout fails on server, clear local data
      await _clearUserData();
      return false;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    return username != null && request.loggedIn;
  }

  /// Get current user data
  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    
    if (username != null) {
      return UserModel(username: username);
    }
    return null;
  }

  /// Save user data to SharedPreferences
  Future<void> _saveUserData(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setBool('isLoggedIn', true);
  }

  /// Clear user data from SharedPreferences
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('isLoggedIn');
  }
}