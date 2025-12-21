import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/profile/data/services/profile_service.dart';
import 'package:bond_up_mobile/features/profile/data/models/user_profile_model.dart';
import 'package:bond_up_mobile/features/profile/data/models/sport_preference_model.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/sport_preference_chip.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/user_stats_card.dart';
import 'package:bond_up_mobile/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/add_sport_preference_dialog.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/upload_image_dialog.dart';
import 'package:bond_up_mobile/features/reviews/data/models/user_review.dart';
import 'package:bond_up_mobile/features/reviews/data/models/user_written_review.dart';
import 'package:bond_up_mobile/features/reviews/presentation/screens/user_written_reviews_page.dart';
import 'package:bond_up_mobile/features/partner_matching/data/models/user_match_model.dart';
import 'package:bond_up_mobile/features/partner_matching/presentation/screens/my_connections_screen.dart';
import 'package:bond_up_mobile/core/constants/api_constants.dart';

/// Screen for viewing the current user's own profile
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;
  List<UserReview> _recentReceivedReviews = [];
  List<UserWrittenReview> _recentWrittenReviews = [];
  bool _isLoadingReviews = false;
  List<UserMatchModel> _recentConnections = [];
  bool _isLoadingConnections = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final request = context.read<CookieRequest>();
    final profileService = ProfileService(request);

    final response = await profileService.getOwnProfile();

    if (!mounted) return;

    if (response.status && response.data != null) {
      setState(() {
        _profile = response.data;
        _isLoading = false;
      });
      // Load reviews and connections after profile is loaded
      _loadReviews();
      _loadConnections();
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReviews() async {
    if (_profile == null) return;

    setState(() {
      _isLoadingReviews = true;
    });

    final request = context.read<CookieRequest>();

    try {
      // Fetch received reviews
      final receivedResponse = await request.get(
        '${ApiConstants.baseUrl}/reviews/api/user/${_profile!.userId}/',
      );

      // Fetch written reviews
      final writtenResponse = await request.get(
        '${ApiConstants.baseUrl}/reviews/api/my-reviews/',
      );

      if (!mounted) return;

      setState(() {
        // Parse received reviews (limit to 3 most recent)
        if (receivedResponse['status'] == 'success') {
          final receivedList = <UserReview>[];
          for (var d in receivedResponse['data']) {
            if (d != null) {
              receivedList.add(UserReview.fromJson(d));
            }
          }
          _recentReceivedReviews = receivedList.take(3).toList();
        }

        // Parse written reviews (limit to 3 most recent)
        if (writtenResponse['status'] == 'success') {
          final writtenList = <UserWrittenReview>[];
          for (var d in writtenResponse['data']) {
            if (d != null) {
              writtenList.add(UserWrittenReview.fromJson(d));
            }
          }
          _recentWrittenReviews = writtenList.take(3).toList();
        }

        _isLoadingReviews = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _loadConnections() async {
    setState(() {
      _isLoadingConnections = true;
    });

    final request = context.read<CookieRequest>();

    try {
      // Fetch connections
      final response = await request.get(
        '${ApiConstants.baseUrl}/partner-matching/connections/api/',
      );

      if (!mounted) return;

      setState(() {
        // Parse connections (limit to 3 most recent friends)
        if (response['status'] == 'success' && response['my_friends'] != null) {
          final connectionsList = <UserMatchModel>[];
          for (var d in response['my_friends']) {
            if (d != null) {
              connectionsList.add(UserMatchModel.fromJson(d));
            }
          }
          _recentConnections = connectionsList.take(3).toList();
        }

        _isLoadingConnections = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingConnections = false;
        });
      }
    }
  }

  Future<void> _addSportPreference() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddSportPreferenceDialog(
        existingPreferences: _profile?.sportPreferences ?? [],
      ),
    );

    if (result == null || !mounted) return;

    final request = context.read<CookieRequest>();
    final profileService = ProfileService(request);

    final response = await profileService.addSportPreference(
      sportType: result['sport_type'],
      skillLevel: result['skill_level'],
    );

    if (!mounted) return;

    if (response['status'] == true) {
      ToastUtils.showSuccess(
        context,
        response['message'] ?? 'Sport preference added successfully',
      );
      _loadProfile(); // Reload profile to show new preference
    } else {
      ToastUtils.showError(
        context,
        response['message'] ?? 'Failed to add sport preference',
      );
    }
  }

  Future<void> _deleteSportPreference(SportPreferenceModel preference) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepSeaLight,
        title: const Text(
          'Delete Sport Preference',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to remove this sport preference?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final request = context.read<CookieRequest>();
    final profileService = ProfileService(request);

    final response = await profileService.deleteSportPreference(preference.id);

    if (!mounted) return;

    if (response['status'] == true) {
      ToastUtils.showSuccess(
        context,
        response['message'] ?? 'Sport preference deleted successfully',
      );
      _loadProfile(); // Reload profile to update list
    } else {
      ToastUtils.showError(
        context,
        response['message'] ?? 'Failed to delete sport preference',
      );
    }
  }

  Future<void> _uploadProfileImage() async {
    final imageUrl = await showDialog<String>(
      context: context,
      builder: (context) => const UploadImageDialog(),
    );

    if (imageUrl == null || !mounted) return;

    final request = context.read<CookieRequest>();
    final profileService = ProfileService(request);

    final response = await profileService.uploadProfileImage(imageUrl);

    if (!mounted) return;

    if (response['status'] == true) {
      ToastUtils.showSuccess(
        context,
        response['message'] ?? 'Profile image updated successfully',
      );
      _loadProfile(); // Reload profile to show new image
    } else {
      ToastUtils.showError(
        context,
        response['message'] ?? 'Failed to upload profile image',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.deepSea,
        actions: [
          if (_profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(profile: _profile!),
                  ),
                );
                // Reload profile if edit was successful
                if (result == true) {
                  _loadProfile();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.orangeSport,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Retry',
                onPressed: _loadProfile,
                size: ButtonSize.medium,
              ),
            ],
          ),
        ),
      );
    }

    if (_profile == null) {
      return const Center(
        child: Text(
          'No profile data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppColors.orangeSport,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            UserStatsCard(
              totalPoints: _profile!.totalPoints,
              totalEvents: _profile!.totalEvents,
            ),
            const SizedBox(height: 24),
            _buildSportPreferencesSection(),
            const SizedBox(height: 24),
            _buildConnectionsSection(),
            const SizedBox(height: 24),
            _buildReviewsSection(),
            if (_profile!.bio.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildBioSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return DeepSeaCard(
      body: Column(
        children: [
          // Avatar with upload button
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.orangeSport,
                backgroundImage: _profile!.profileImageUrl.isNotEmpty
                    ? NetworkImage(_profile!.profileImageUrl)
                    : null,
                child: _profile!.profileImageUrl.isEmpty
                    ? Text(
                        _profile!.initials,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _uploadProfileImage,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.orangeSport,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Full Name
          Text(
            _profile!.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // Username
          Text(
            '@${_profile!.username}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          if (_profile!.cityDisplay.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.orangeSport,
                ),
                const SizedBox(width: 4),
                Text(
                  _profile!.cityDisplay,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSportPreferencesSection() {
    return DeepSeaCard(
      header: Row(
        children: [
          const Text(
            '🏃',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          const Text(
            'Sport Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.orangeSport),
            onPressed: _addSportPreference,
            tooltip: 'Add Sport Preference',
          ),
        ],
      ),
      body: SportPreferencesGrid(
        preferences: _profile!.sportPreferences,
        onDelete: _deleteSportPreference,
      ),
    );
  }

  Widget _buildBioSection() {
    return DeepSeaCard(
      header: const Row(
        children: [
          Text(
            '📝',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 8),
          Text(
            'Bio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Text(
        _profile!.bio,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white70,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildConnectionsSection() {
    return DeepSeaCard(
      header: Row(
        children: [
          const Text(
            '👥',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          const Text(
            'Connections',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyConnectionsScreen(),
                ),
              );
            },
            child: const Text(
              'View All',
              style: TextStyle(
                color: AppColors.orangeSport,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: _isLoadingConnections
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.orangeSport,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_recentConnections.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No connections yet.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  )
                else
                  ..._recentConnections.map((connection) => _buildConnectionItem(connection)),
              ],
            ),
    );
  }

  Widget _buildConnectionItem(UserMatchModel connection) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepSeaLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.orangeSport,
            backgroundImage: connection.profilePictureUrl.isNotEmpty
                ? NetworkImage(connection.profilePictureUrl)
                : null,
            child: connection.profilePictureUrl.isEmpty
                ? Text(
                    connection.fullName.isNotEmpty
                        ? connection.fullName[0].toUpperCase()
                        : connection.username[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  connection.fullName.isNotEmpty
                      ? connection.fullName
                      : connection.username,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                if (connection.city.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    connection.city,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (connection.sports.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    connection.sports,
                    style: const TextStyle(
                      color: AppColors.orangeSport,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return DeepSeaCard(
      header: Row(
        children: [
          const Text(
            '⭐',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 8),
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserWrittenReviewsPage(),
                ),
              );
            },
            child: const Text(
              'My Written Reviews',
              style: TextStyle(
                color: AppColors.orangeSport,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: _isLoadingReviews
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  color: AppColors.orangeSport,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Received Reviews Section
                const Text(
                  'Recent Reviews Received',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orangeSport,
                  ),
                ),
                const SizedBox(height: 12),
                if (_recentReceivedReviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No reviews received yet.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  )
                else
                  ..._recentReceivedReviews.map((review) => _buildReceivedReviewItem(review)),

                const SizedBox(height: 20),
                const Divider(color: Colors.white24),
                const SizedBox(height: 20),

                // Written Reviews Section
                const Text(
                  'Recent Reviews Written',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.orangeSport,
                  ),
                ),
                const SizedBox(height: 12),
                if (_recentWrittenReviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No reviews written yet.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  )
                else
                  ..._recentWrittenReviews.map((review) => _buildWrittenReviewItem(review)),
              ],
            ),
    );
  }

  Widget _buildReceivedReviewItem(UserReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepSeaLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.eventTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              _buildStarRating(review.rating),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'From: ${review.reviewerName}',
            style: const TextStyle(
              color: AppColors.orangeSport,
              fontSize: 12,
            ),
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.comment,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWrittenReviewItem(UserWrittenReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.deepSeaLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.eventTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              _buildStarRating(review.rating),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'To: ${review.revieweeName}',
            style: const TextStyle(
              color: AppColors.orangeSport,
              fontSize: 12,
            ),
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.comment,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star : Icons.star_border,
          color: AppColors.orangeSport,
          size: 16,
        ),
      ),
    );
  }
}
