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
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
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
}
