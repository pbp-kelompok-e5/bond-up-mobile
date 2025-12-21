import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../../data/services/partner_matching_service.dart';
import '../../data/models/profile_detail_model.dart';
import '../../data/models/user_match_model.dart';
import 'package:bond_up_mobile/features/reviews/data/models/user_review.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/core/constants/api_constants.dart';

/// Public Profile Screen - View other users' profiles (Placeholder)
/// Features: Profile viewing, connection requests, sports preferences
/// 1. GET /api/profiles/{userId}/ - Fetch profile details
/// 2. POST /api/connections/{userId}/actions/ - Connection actions
/// Navigation: Diakses dari BrowseUsersScreen atau ConnectionsScreen
class UserProfileScreen extends StatefulWidget {
  final int userId; // ID user yang mau dilihat

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  ProfileDetailModel? _profile;
  bool _isLoading = true;
  bool _isActionLoading = false; // Loading khusus tombol connect/accept
  List<UserReview> _recentReviews = [];
  bool _isLoadingReviews = false;
  List<UserMatchModel> _recentConnections = [];
  bool _isLoadingConnections = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 1. Ambil Data Profil
  Future<void> _loadProfile() async {
    final request = context.read<CookieRequest>();
    final dataSource = PartnerMatchingService(request);

    try {
      final profile = await dataSource.fetchUserProfile(widget.userId);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error (menampilkan snackbar/text error)
      setState(() => _isLoading = false);
    }
  }

  /// Menangani aksi koneksi (connect/accept/reject/cancel).
  ///
  /// @param action - Jenis aksi: 'connect', 'accept', 'reject', atau 'cancel'
  ///
  /// Flow:
  /// 1. Tampilkan loading state pada tombol
  /// 2. Kirim request ke server melalui dataSource
  /// 3. Jika berhasil, refresh data profil
  /// 4. Tampilkan feedback kepada pengguna
  // 2. Handle Tombol Connect/Accept/Reject/Cancel
  Future<void> _handleAction(String action) async {
    setState(() => _isActionLoading = true);

    final request = context.read<CookieRequest>();
    final dataSource = PartnerMatchingService(request);

    // action: 'connect', 'accept', 'reject', 'cancel'
    final success = await dataSource.sendConnectionAction(
      action,
      widget.userId,
    );

    if (success) {
      await _loadProfile(); // Refresh data agar tombolnya berubah
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Action '$action' success!")));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Action failed, try again.")),
        );
      }
    }

    setState(() => _isActionLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Profile")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
          ? const Center(child: Text("User not found"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // --- BAGIAN 1: HEADER (Foto & Nama) ---
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_profile!.profilePictureUrl),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _profile!.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "@${_profile!.username}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    "📍 ${_profile!.city}",
                    style: const TextStyle(color: Colors.blue),
                  ),

                  const SizedBox(height: 24),

                  // --- BAGIAN 2: TOMBOL AKSI ---
                  if (_isActionLoading)
                    const CircularProgressIndicator()
                  else
                    _buildActionButtons(),

                  const SizedBox(height: 24),

                  // --- BAGIAN 3: INFO LAINNYA ---
                  // Tampilkan Bio
                  if (_profile!.bio.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "About Me",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(_profile!.bio),
                    const SizedBox(height: 16),
                  ],

                  // Tampilkan Sports
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sports",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: _profile!.sportPreferences.map((sport) {
                      return Chip(
                        label: Text(
                          "${sport['sport_type']} (${sport['skill_level']})",
                        ),
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }

  /// Logika untuk menampilkan tombol yang tepat berdasarkan status koneksi.
  ///
  /// Status yang didukung:
  /// - 'none': Belum terkoneksi, tampilkan tombol Connect
  /// - 'pending_sent': Request terkirim, tampilkan tombol Cancel
  /// - 'pending_received': Request diterima, tampilkan Accept/Reject
  /// - 'accepted': Sudah berteman, tampilkan status "Friends"
  // Logic Tombol Pintar
  Widget _buildActionButtons() {
    final status = _profile!.connectionStatus;

    if (status == 'accepted') {
      return ElevatedButton.icon(
        onPressed: null, // Disabled
        icon: const Icon(Icons.check),
        label: const Text("Friends"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
      );
    } else if (status == 'pending_sent') {
      return ElevatedButton.icon(
        onPressed: () => _handleAction('cancel'),
        icon: const Icon(Icons.close),
        label: const Text("Cancel Request"),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
      );
    } else if (status == 'pending_received') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _handleAction('accept'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Accept"),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => _handleAction('reject'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Reject"),
          ),
        ],
      );
    } else {
      // status == 'none'
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handleAction('connect'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text("Connect"),
        ),
      );
    }
  }
}
