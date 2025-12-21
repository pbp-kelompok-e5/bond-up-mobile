/// Authentication response model
class AuthResponse {
  final bool status;
  final String message;
  final String? username;

  AuthResponse({
    required this.status,
    required this.message,
    this.username,
  });

  /// Create AuthResponse from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] == true || json['status'] == 'success',
      message: json['message'] as String? ?? '',
      username: json['username'] as String?,
    );
  }

  /// Convert AuthResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'username': username,
    };
  }

  @override
  String toString() {
    return 'AuthResponse(status: $status, message: $message, username: $username)';
  }
}

