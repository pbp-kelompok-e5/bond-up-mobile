import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// --- IMPORTS UTILS & WIDGETS ---
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/core/constants/api_constants.dart';

// --- IMPORTS FEATURE PROFILE ---
import 'package:bond_up_mobile/features/profile/data/services/profile_service.dart';
import 'package:bond_up_mobile/features/profile/data/models/user_profile_model.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/user_stats_card.dart';

// --- IMPORTS FEATURE LAIN ---
import 'package:bond_up_mobile/features/reviews/data/models/user_review.dart';
import 'package:bond_up_mobile/features/partner_matching/data/models/user_match_model.dart';
import 'package:bond_up_mobile/features/partner_matching/data/services/partner_matching_service.dart';

/// Screen untuk melihat profil pengguna LAIN (Public Profile)
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
  // State Data
  UserProfileModel? _profile;
  List<UserReview> _recentReviews = [];
  List<UserMatchModel> _recentConnections = [];
  
  // State Status Koneksi
  String _connectionStatus = 'none'; // 'none', 'accepted', 'pending_sent', 'pending_received'

  // State Loading & Error
  bool _isLoading = true;
  String? _errorMessage;
  bool _isLoadingReviews = false;
  bool _isLoadingConnections = false;
  bool _isActionLoading = false; // Loading saat tekan tombol connect/accept

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Memuat profil utama
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
      // Load data pendukung
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

  /// Memuat review user tersebut
  Future<void> _loadReviews() async {
    if (_profile == null) return;
    setState(() => _isLoadingReviews = true);

    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        '${ApiConstants.baseUrl}/reviews/api/user/${widget.userId}/',
      );

      if (!mounted) return;

      setState(() {
        if (response['status'] == 'success') {
          final list = (response['data'] as List)
              .map((d) => UserReview.fromJson(d))
              .toList();
          _recentReviews = list.take(3).toList();
        }
        _isLoadingReviews = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  /// Memuat koneksi publik user tersebut
  Future<void> _loadConnections() async {
    setState(() => _isLoadingConnections = true);
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        '${ApiConstants.baseUrl}/partner-matching/profile/${widget.userId}/connections/api/',
      );

      if (!mounted) return;

      setState(() {
        if (response['status'] == 'success' && response['my_friends'] != null) {
          final list = (response['my_friends'] as List)
              .map((d) => UserMatchModel.fromJson(d))
              .toList();
          _recentConnections = list.take(3).toList();
        }
        _isLoadingConnections = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingConnections = false);
    }
  }

  /// Cek status hubungan (Teman/Pending/None)
  Future<void> _loadConnectionStatus() async {
    final request = context.read<CookieRequest>();
    try {
      final partnerMatchingService = PartnerMatchingService(request);
      final profileDetail = await partnerMatchingService.fetchUserProfile(widget.userId);

      if (!mounted) return;
      setState(() {
        _connectionStatus = profileDetail.connectionStatus;
      });
    } catch (e) {
      // Ignore error, keep default
    }
  }

  /// Handler aksi tombol (Connect, Accept, Reject, Cancel)
  Future<void> _handleConnectionAction(String action) async {
  setState(() => _isActionLoading = true);

  // 1. Simpan referensi ScaffoldMessenger atau Navigator SEBELUM await jika perlu,
  // atau cukup gunakan check 'mounted' seperti di bawah.
  final request = context.read<CookieRequest>();
  final partnerMatchingService = PartnerMatchingService(request);

  final success = await partnerMatchingService.sendConnectionAction(
    action,
    widget.userId,
  );

  // 2. CHECK ASYNC GAP: Pastikan widget masih ada di layar sebelum lanjut
  if (!mounted) return;

  if (success) {
    await _loadConnectionStatus(); 
    
    // Pastikan cek mounted lagi jika _loadConnectionStatus juga async
    if (!mounted) return; 
    
    ToastUtils.showSuccess(context, "Action '$action' successful!");
  } else {
    ToastUtils.showError(context, "Action failed, please try again.");
  }

  setState(() => _isActionLoading = false);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea,
      appBar: AppBar(
        title: Text(
          _profile?.displayName ?? 'User Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Loading State
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.orangeSport));
    }

    // 2. Error State
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.buttonDanger),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(text: 'Retry', onPressed: _loadProfile, size: ButtonSize.medium),
          ],
        ),
      );
    }

    if (_profile == null) return const SizedBox.shrink();

    // 3. Main Content
    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppColors.orangeSport,
      backgroundColor: AppColors.deepSeaLighter,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            
            // Tombol Aksi (Connect/Friend)
            _buildConnectionButton(),
            const SizedBox(height: 24),
            
            // Statistik
            UserStatsCard(
              totalPoints: _profile!.totalPoints,
              totalEvents: _profile!.totalEvents,
            ),
            const SizedBox(height: 24),
            
            // Bio (Jika ada)
            _buildBioSection(),
            const SizedBox(height: 24),
            
            // Sport Preferences
            _buildSportPreferencesSection(),
            const SizedBox(height: 24),
            
            // Connections
            _buildConnectionsSection(),
            const SizedBox(height: 24),
            
            // Reviews
            _buildReviewsSection(),
          ],
        ),
      ),
    );
  }

  /// Header Avatar & Info Dasar
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.orangeSport, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: AppColors.deepSeaLighter,
            backgroundImage: _profile!.profileImageUrl.isNotEmpty
                ? NetworkImage(_profile!.profileImageUrl)
                : null,
            child: _profile!.profileImageUrl.isEmpty
                ? Text(
                    _profile!.initials,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _profile!.displayName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@${_profile!.username}',
          style: const TextStyle(fontSize: 14, color: AppColors.gray400),
        ),
        if (_profile!.cityDisplay.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, size: 14, color: AppColors.orangeSport),
                const SizedBox(width: 4),
                Text(
                  _profile!.cityDisplay,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray200),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Tombol Status Hubungan (Logika connect/accept/pending)
  Widget _buildConnectionButton() {
    if (_isActionLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.orangeSport));
    }

    if (_connectionStatus == 'accepted') {
      return AppButton(
        text: 'Friends',
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
        onPressed: null, // Disabled, just info
        variant: ButtonVariant.success,
        isFullWidth: true,
        size: ButtonSize.medium,
      );
    } else if (_connectionStatus == 'pending_sent') {
      return AppButton(
        text: 'Cancel Request',
        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
        onPressed: () => _handleConnectionAction('cancel'),
        variant: ButtonVariant.danger, // Danger untuk cancel
        isFullWidth: true,
        size: ButtonSize.medium,
      );
    } else if (_connectionStatus == 'pending_received') {
      // Jika ada request masuk, tampilkan 2 tombol
      return Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Accept',
              onPressed: () => _handleConnectionAction('accept'),
              variant: ButtonVariant.success,
              size: ButtonSize.medium,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              text: 'Reject',
              onPressed: () => _handleConnectionAction('reject'),
              variant: ButtonVariant.danger,
              size: ButtonSize.medium,
            ),
          ),
        ],
      );
    } else {
      // 'none' -> Tombol Connect Normal
      return AppButton(
        text: 'Connect',
        icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
        onPressed: () => _handleConnectionAction('connect'),
        variant: ButtonVariant.primary,
        isFullWidth: true,
        size: ButtonSize.medium,
      );
    }
  }

  /// Section Bio
  Widget _buildBioSection() {
    if (_profile!.bio.isEmpty) return const SizedBox.shrink();
    return DeepSeaCard(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("About", style: TextStyle(color: AppColors.gray400, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_profile!.bio, style: const TextStyle(color: Colors.white, height: 1.5)),
        ],
      ),
    );
  }

  /// Section Sport Preferences
  Widget _buildSportPreferencesSection() {
    return DeepSeaCard(
      header: const Text('Sports Interest', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      body: _profile!.sportPreferences.isEmpty
          ? const Text("No sports added.", style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic))
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profile!.sportPreferences.map((pref) {
                return Chip(
                  label: Text("${pref.sportType} (${pref.skillLevel})"),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  backgroundColor: AppColors.deepSeaLighter,
                  side: const BorderSide(color: AppColors.orangeSport),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              }).toList(),
            ),
    );
  }

  /// Section Public Connections
  Widget _buildConnectionsSection() {
    return DeepSeaCard(
      header: const Text('Public Connections', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      body: _isLoadingConnections
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orangeSport))
          : _recentConnections.isEmpty
              ? _buildEmptyState("No public connections.")
              : Column(
                  children: _recentConnections.map((conn) => _buildConnectionItem(conn)).toList(),
                ),
    );
  }

  Widget _buildConnectionItem(UserMatchModel conn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.orangeSport,
            backgroundImage: conn.profilePictureUrl.isNotEmpty ? NetworkImage(conn.profilePictureUrl) : null,
            child: conn.profilePictureUrl.isEmpty 
                ? Text(conn.username[0].toUpperCase(), style: const TextStyle(color: Colors.white)) 
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conn.fullName.isNotEmpty ? conn.fullName : conn.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                if (conn.city.isNotEmpty)
                  Text(conn.city, style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Section Reviews
  Widget _buildReviewsSection() {
    return DeepSeaCard(
      header: const Text('Reviews Received', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      body: _isLoadingReviews
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orangeSport))
          : _recentReviews.isEmpty
              ? _buildEmptyState("No reviews received yet.")
              : Column(
                  children: _recentReviews.map((r) => _buildReviewItem(r)).toList(),
                ),
    );
  }

  Widget _buildReviewItem(UserReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.orangeSport, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(review.eventTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber, size: 16,
                )),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "From: ${review.reviewerName}",
            style: const TextStyle(color: AppColors.gray400, fontSize: 12, fontStyle: FontStyle.italic),
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.comment, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.white24, size: 28),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}