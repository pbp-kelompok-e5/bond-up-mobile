import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/profile/data/services/profile_service.dart';
import 'package:bond_up_mobile/features/profile/data/models/user_profile_model.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/sport_preference_chip.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/user_stats_card.dart';

/// Screen for viewing another user's public profile
class PublicProfileScreen extends StatefulWidget {
  final int userId;

  const PublicProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
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

    final response = await profileService.getUserProfile(widget.userId);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea,
      appBar: AppBar(
        title: Text(_profile?.displayName ?? 'User Profile'),
        backgroundColor: AppColors.deepSea,
        actions: [
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
              const Text(
                'Error',
                style: TextStyle(
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
          // Avatar
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
      header: const Row(
        children: [
          Text(
            '🏃',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 8),
          Text(
            'Sport Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SportPreferencesGrid(
        preferences: _profile!.sportPreferences,
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

