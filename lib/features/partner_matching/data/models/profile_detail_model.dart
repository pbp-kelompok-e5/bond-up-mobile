class ProfileDetailModel {
  final int id;
  final String username;
  final String fullName;
  final String city;
  final String bio;
  final String profilePictureUrl;
  final String connectionStatus; // 'none', 'accepted', 'pending_sent', 'pending_received'
  final List<Map<String, dynamic>> sportPreferences;

  ProfileDetailModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.city,
    required this.bio,
    required this.profilePictureUrl,
    required this.connectionStatus,
    required this.sportPreferences,
  });

  factory ProfileDetailModel.fromJson(Map<String, dynamic> json) {
    var data = json['data']; // Karena JSON kamu dibungkus key 'data'
    return ProfileDetailModel(
      id: data['id'],
      username: data['username'],
      fullName: data['full_name'],
      city: data['city'],
      bio: data['bio'],
      profilePictureUrl: data['profile_picture_url'],
      connectionStatus: data['connection_status'],
      sportPreferences: List<Map<String, dynamic>>.from(data['sport_preferences']),
    );
  }
}