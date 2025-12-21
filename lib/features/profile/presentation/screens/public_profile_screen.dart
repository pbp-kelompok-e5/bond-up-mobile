import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/profile/data/services/profile_service.dart';
import 'package:bond_up_mobile/features/profile/data/models/user_profile_model.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/sport_preference_chip.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/user_stats_card.dart';
import 'package:bond_up_mobile/features/reviews/data/models/user_review.dart';
import 'package:bond_up_mobile/features/partner_matching/data/models/user_match_model.dart';
import 'package:bond_up_mobile/features/partner_matching/data/services/partner_matching_service.dart';
import 'package:bond_up_mobile/core/constants/api_constants.dart';

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
  List<UserReview> _recentReviews = [];
  bool _isLoadingReviews = false;
  List<UserMatchModel> _recentConnections = [];
  bool _isLoadingConnections = false;
  String _connectionStatus = 'none'; // 'none', 'accepted', 'pending_sent', 'pending_received'
  bool _isActionLoading = false;

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
      // Load additional data after profile is loaded
      _loadReviews();
      _loadConnections();
      _loadConnectionStatus();
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
      // Fetch reviews received by this user
      final response = await request.get(
        '${ApiConstants.baseUrl}/reviews/api/user/${widget.userId}/',
      );

      if (!mounted) return;

      setState(() {
        // Parse reviews (limit to 3 most recent)
        if (response['status'] == 'success') {
          final reviewsList = <UserReview>[];
          for (var d in response['data']) {
            if (d != null) {
              reviewsList.add(UserReview.fromJson(d));
            }
          }
          _recentReviews = reviewsList.take(3).toList();
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
      // Fetch public connections for this specific user
      final response = await request.get(
        '${ApiConstants.baseUrl}/partner-matching/profile/${widget.userId}/connections/api/',
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

  Future<void> _loadConnectionStatus() async {
    final request = context.read<CookieRequest>();

    try {
      // Fetch connection status from partner-matching profile endpoint
      final partnerMatchingService = PartnerMatchingService(request);
      final profileDetail = await partnerMatchingService.fetchUserProfile(widget.userId);

      if (!mounted) return;

      setState(() {
        _connectionStatus = profileDetail.connectionStatus;
      });
    } catch (e) {
      // If error, keep default 'none' status
    }
  }

  Future<void> _handleConnectionAction(String action) async {
    setState(() {
      _isActionLoading = true;
    });

    final request = context.read<CookieRequest>();
    final partnerMatchingService = PartnerMatchingService(request);

    final success = await partnerMatchingService.sendConnectionAction(
      action,
      widget.userId,
    );

    if (success) {
      await _loadConnectionStatus(); // Refresh connection status
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Action '$action' successful!"),
            backgroundColor: AppColors.orangeSport,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Action failed, please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isActionLoading = false;
    });
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
            const SizedBox(height: 16),
            _buildConnectionButton(),
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

  Widget _buildConnectionButton() {
    if (_isActionLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.orangeSport,
        ),
      );
    }

    if (_connectionStatus == 'accepted') {
      return AppButton(
        text: 'Friends ✓',
        onPressed: () {},
        variant: ButtonVariant.success,
        isFullWidth: true,
        size: ButtonSize.medium,
      );
    } else if (_connectionStatus == 'pending_sent') {
      return AppButton(
        text: 'Cancel Request',
        onPressed: () => _handleConnectionAction('cancel'),
        variant: ButtonVariant.danger,
        isFullWidth: true,
        size: ButtonSize.medium,
      );
    } else if (_connectionStatus == 'pending_received') {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Accept',
              onPressed: () => _handleConnectionAction('accept'),
              variant: ButtonVariant.success,
              isFullWidth: true,
              size: ButtonSize.medium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: 'Reject',
              onPressed: () => _handleConnectionAction('reject'),
              variant: ButtonVariant.danger,
              isFullWidth: true,
              size: ButtonSize.medium,
            ),
          ),
        ],
      );
    } else {
      // status == 'none'
      return AppButton(
        text: 'Connect',
        onPressed: () => _handleConnectionAction('connect'),
        variant: ButtonVariant.primary,
        isFullWidth: true,
        size: ButtonSize.medium,
      );
    }
  }

  Widget _buildConnectionsSection() {
    return DeepSeaCard(
      header: const Row(
        children: [
          Text(
            '👥',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 8),
          Text(
            'Connections',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                      'No public connections to display.',
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
      header: const Row(
        children: [
          Text(
            '⭐',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 8),
          Text(
            'Reviews Received',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                if (_recentReviews.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'No reviews yet.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  )
                else
                  ..._recentReviews.map((review) => _buildReviewItem(review)),
              ],
            ),
    );
  }

  Widget _buildReviewItem(UserReview review) {
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
          // Event title
          Text(
            review.eventTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.orangeSport,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          // Rating
          Row(
            children: [
              ...List.generate(
                5,
                (index) => Icon(
                  index < review.rating ? Icons.star : Icons.star_border,
                  color: AppColors.orangeSport,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'From: ${review.reviewerName}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              review.comment,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

