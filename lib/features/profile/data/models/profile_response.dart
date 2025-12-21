import 'package:bond_up_mobile/features/profile/data/models/user_profile_model.dart';

/// Profile API response model
class ProfileResponse {
  final bool status;
  final String message;
  final UserProfileModel? data;

  ProfileResponse({
    required this.status,
    required this.message,
    this.data,
  });

  /// Create ProfileResponse from JSON
  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] == true || json['status'] == 'success',
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? UserProfileModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert ProfileResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  @override
  String toString() {
    return 'ProfileResponse(status: $status, message: $message, data: $data)';
  }
}

