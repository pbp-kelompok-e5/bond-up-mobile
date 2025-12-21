import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS UTILS & WIDGETS ---
import 'package:bond_up_mobile/core/design_system.dart'; // Pastikan DeepSeaCard, AppButton, AppColors ada di sini
import 'package:bond_up_mobile/core/constants/api_constants.dart';

// --- IMPORTS FEATURE PROFILE ---
import 'package:bond_up_mobile/features/profile/data/services/profile_service.dart';
import 'package:bond_up_mobile/features/profile/data/models/user_profile_model.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/user_stats_card.dart';
import 'package:bond_up_mobile/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/add_sport_preference_dialog.dart';
import 'package:bond_up_mobile/features/profile/presentation/widgets/upload_image_dialog.dart';

// --- IMPORTS FEATURE LAIN ---
import 'package:bond_up_mobile/features/reviews/data/models/user_review.dart';
import 'package:bond_up_mobile/features/reviews/data/models/user_written_review.dart';
import 'package:bond_up_mobile/features/reviews/presentation/screens/user_written_reviews_page.dart';
import 'package:bond_up_mobile/features/reviews/presentation/screens/user_reviews_page.dart';
import 'package:bond_up_mobile/features/partner_matching/data/models/user_match_model.dart';
import 'package:bond_up_mobile/features/partner_matching/presentation/screens/my_connections_screen.dart';

/// Screen untuk menampilkan profil pengguna saat ini (My Profile).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // State Data
  UserProfileModel? _profile;
  List<UserReview> _recentReceivedReviews = [];
  List<UserWrittenReview> _recentWrittenReviews = [];
  List<UserMatchModel> _recentConnections = [];

  // State UI Loading & Error
  bool _isLoading = true;
  bool _isLoadingReviews = false;
  bool _isLoadingConnections = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Muat data profil saat widget pertama kali dibuat
    _loadProfile();
  }

  /// Fungsi utama untuk memuat data profil
  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final request = context.read<CookieRequest>();
    final profileService = ProfileService(request);

    try {
      final response = await profileService.getOwnProfile();

      if (!mounted) return;

      if (response.status && response.data != null) {
        setState(() {
          _profile = response.data;
          _isLoading = false;
        });
        // Setelah profil berhasil dimuat, muat data pendukung secara paralel
        _loadReviews();
        _loadConnections();
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Terjadi kesalahan jaringan.";
        _isLoading = false;
      });
    }
  }

  /// Memuat review (Diterima & Ditulis)
  Future<void> _loadReviews() async {
    if (_profile == null) return;
    setState(() => _isLoadingReviews = true);

    final request = context.read<CookieRequest>();

    try {
      // Fetch concurrent (bersamaan) agar lebih cepat
      final results = await Future.wait([
        request.get('${ApiConstants.baseUrl}/reviews/api/user/${_profile!.userId}/'),
        request.get('${ApiConstants.baseUrl}/reviews/api/my-reviews/'),
      ]);

      final receivedResponse = results[0];
      final writtenResponse = results[1];

      if (!mounted) return;

      setState(() {
        // Parsing Review Diterima
        if (receivedResponse['status'] == 'success') {
          final list = (receivedResponse['data'] as List)
              .map((d) => UserReview.fromJson(d))
              .toList();
          _recentReceivedReviews = list.take(3).toList(); // Ambil 3 teratas
        }

        // Parsing Review Ditulis
        if (writtenResponse['status'] == 'success') {
          final list = (writtenResponse['data'] as List)
              .map((d) => UserWrittenReview.fromJson(d))
              .toList();
          _recentWrittenReviews = list.take(3).toList(); // Ambil 3 teratas
        }
        _isLoadingReviews = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  /// Memuat koneksi/teman
  Future<void> _loadConnections() async {
    setState(() => _isLoadingConnections = true);
    final request = context.read<CookieRequest>();

    try {
      final response = await request.get(
        '${ApiConstants.baseUrl}/partner-matching/connections/api/',
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

  // --- LOGIKA ACTIONS (ADD, DELETE, UPLOAD) ---

  Future<void> _addSportPreference() async {
    // Tampilkan Dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddSportPreferenceDialog(
        existingPreferences: _profile?.sportPreferences ?? [],
      ),
    );

    if (result == null || !mounted) return;

    final request = context.read<CookieRequest>();
    final profileService = ProfileService(request);

    // Panggil API
    final response = await profileService.addSportPreference(
      sportType: result['sport_type'],
      skillLevel: result['skill_level'],
    );

    if (!mounted) return;

    if (response['status'] == true) {
      ToastUtils.showSuccess(context, response['message'] ?? 'Sport Added');
      _loadProfile(); // Refresh UI
    } else {
      ToastUtils.showError(context, response['message'] ?? 'Failed to add');
    }
  }

  Future<void> _deleteSportPreference(int preferenceId) async {
    // Konfirmasi User
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepSeaLighter,
        title: const Text('Remove Sport?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to remove this preference?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.buttonDanger),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final request = context.read<CookieRequest>();
    final profileService = ProfileService(request);

    final response = await profileService.deleteSportPreference(preferenceId);

    if (!mounted) return;

    if (response['status'] == true) {
      ToastUtils.showSuccess(context, 'Sport removed');
      _loadProfile();
    } else {
      ToastUtils.showError(context, response['message'] ?? 'Failed to remove');
    }
  }

  Future<void> _uploadProfileImage() async {
    // Dialog Upload
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
      ToastUtils.showSuccess(context, 'Profile picture updated');
      _loadProfile();
    } else {
      ToastUtils.showError(context, 'Failed to update picture');
    }
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Tombol Edit Profile
          if (_profile != null)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppColors.white),
              tooltip: 'Edit Profile',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(profile: _profile!),
                  ),
                );
                if (result == true) _loadProfile();
              },
            ),
          // Tombol Refresh Manual
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
            tooltip: 'Refresh',
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Tampilan Loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.orangeSport));
    }

    // 2. Tampilan Error
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.gray400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            AppButton(text: 'Try Again', onPressed: _loadProfile, size: ButtonSize.small),
          ],
        ),
      );
    }

    if (_profile == null) return const SizedBox.shrink();

    // 3. Konten Utama
    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppColors.orangeSport,
      backgroundColor: AppColors.deepSeaLight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), // Agar bisa di-refresh meski konten sedikit
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            
            // Kartu Statistik (Points & Events)
            UserStatsCard(
              totalPoints: _profile!.totalPoints,
              totalEvents: _profile!.totalEvents,
            ),
            const SizedBox(height: 24),
            
            _buildBioSection(),
            const SizedBox(height: 24),
            
            _buildSportPreferencesSection(),
            const SizedBox(height: 24),
            
            _buildConnectionsSection(),
            const SizedBox(height: 24),
            
            _buildReviewsSection(),
          ],
        ),
      ),
    );
  }

  // --- WIDGET SECTIONS ---

  /// Header: Avatar, Nama, Username, Lokasi
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            // Lingkaran Avatar dengan Border
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
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                      )
                    : null,
              ),
            ),
            // Tombol Kamera Kecil (Floating)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _uploadProfileImage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.orangeSport,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _profile!.displayName,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          textAlign: TextAlign.center,
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

  /// Section Bio (Deskripsi Diri)
  Widget _buildBioSection() {
    if (_profile!.bio.isEmpty) return const SizedBox.shrink();
    
    return DeepSeaCard(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "About Me",
            style: TextStyle(color: AppColors.gray400, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _profile!.bio,
            style: const TextStyle(color: AppColors.white, height: 1.5),
          ),
        ],
      ),
    );
  }

  /// Section Preferensi Olahraga (Chips)
  Widget _buildSportPreferencesSection() {
    return DeepSeaCard(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Sports Interest', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
            onPressed: _addSportPreference,
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.orangeSport),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      body: _profile!.sportPreferences.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text("No sports added yet.", style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic)),
            )
          // Menggunakan Wrap agar chip responsif
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profile!.sportPreferences.map((pref) {
                // Widget Chip Kustom (disederhanakan untuk contoh)
                return InputChip(
                  label: Text("${pref.sportType} (${pref.skillLevel})"),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  backgroundColor: AppColors.deepSeaLighter,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppColors.orangeSport),
                  ),
                  onDeleted: () => _deleteSportPreference(pref.id),
                  deleteIcon: const Icon(Icons.close, size: 16, color: AppColors.buttonDanger),
                );
              }).toList(),
            ),
    );
  }

  /// Section Koneksi Teman
  Widget _buildConnectionsSection() {
    return DeepSeaCard(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Connections', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const MyConnectionsScreen()));
            },
            child: const Text('See All', style: TextStyle(color: AppColors.orangeSport, fontSize: 14)),
          ),
        ],
      ),
      body: _isLoadingConnections
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : _recentConnections.isEmpty
              ? _buildEmptyState("No connections yet.")
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

  /// Section Reviews (Received & Written)
  Widget _buildReviewsSection() {
    return Column(
      children: [
        // Tab Reviews Received
        DeepSeaCard(
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reviews Received', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  if (_profile != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => UserReviewsPage(userId: _profile!.userId)));
                  }
                },
                child: const Text('See All', style: TextStyle(color: AppColors.orangeSport, fontSize: 14)),
              ),
            ],
          ),
          body: _isLoadingReviews
              ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
              : _recentReceivedReviews.isEmpty
                  ? _buildEmptyState("No reviews received yet.")
                  : Column(
                      children: _recentReceivedReviews.map((r) => _buildReviewItem(
                        title: r.eventTitle,
                        name: r.reviewerName,
                        rating: r.rating,
                        comment: r.comment,
                        isReceived: true,
                      )).toList(),
                    ),
        ),
        const SizedBox(height: 24),
        // Tab Reviews Written
        DeepSeaCard(
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reviews Written', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => const UserWrittenReviewsPage()));
                },
                child: const Text('See All', style: TextStyle(color: AppColors.orangeSport, fontSize: 14)),
              ),
            ],
          ),
          body: _isLoadingReviews
              ? const SizedBox(height: 50, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
              : _recentWrittenReviews.isEmpty
                  ? _buildEmptyState("You haven't written any reviews.")
                  : Column(
                      children: _recentWrittenReviews.map((r) => _buildReviewItem(
                        title: r.eventTitle,
                        name: r.revieweeName,
                        rating: r.rating,
                        comment: r.comment,
                        isReceived: false,
                      )).toList(),
                    ),
        ),
      ],
    );
  }

  /// Helper Widget untuk Item Review
  Widget _buildReviewItem({
    required String title,
    required String name,
    required int rating,
    required String comment,
    required bool isReceived,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: isReceived ? AppColors.statusCompleted : AppColors.orangeSport, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: Colors.amber, size: 16,
                )),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isReceived ? "From: $name" : "To: $name",
            style: TextStyle(color: AppColors.gray400, fontSize: 12, fontStyle: FontStyle.italic),
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(comment, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  /// Helper untuk tampilan data kosong
  Widget _buildEmptyState(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            const Icon(Icons.bubble_chart_outlined, color: Colors.white24, size: 32),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}