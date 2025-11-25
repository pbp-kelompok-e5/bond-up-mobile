import 'dart:convert';

/// User model for authentication
class UserModel {
  final String username;
  final String? email;

  UserModel({
    required this.username,
    this.email,
  });

  /// Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String,
      email: json['email'] as String?,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }

  /// Create UserModel from JSON string
  factory UserModel.fromJsonString(String str) {
    return UserModel.fromJson(json.decode(str));
  }

  /// Convert UserModel to JSON string
  String toJsonString() {
    return json.encode(toJson());
  }

  @override
  String toString() {
    return 'UserModel(username: $username, email: $email)';
  }
}

