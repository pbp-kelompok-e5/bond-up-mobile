import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/leaderboard/data/services/leaderboard_service.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/leaderboard_entry_model.dart';
import 'package:bond_up_mobile/features/profile/presentation/screens/public_profile_screen.dart';

import '../widgets/leaderboard_header.dart';
import '../widgets/leaderboard_card.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/empty_leaderboard.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  LeaderboardResponseModel? _leaderboardData;
  bool _isLoading = true;
  int _currentPage = 1;
  static const int _usersPerPage = 10;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;

    setState(() => _isLoading = true);

    final request = context.read<CookieRequest>();
    final leaderboardService = LeaderboardService(request);

    try {
      final response = await leaderboardService.getLeaderboard(
        page: _currentPage,
        limit: _usersPerPage,
      );

      if (mounted) {
        setState(() {
          _leaderboardData = response;
          _isLoading = false;
        });

        if (!response.status) {
          ToastUtils.showError(context, response.message);
        } else {
          _animationController.forward(from: 0);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastUtils.showError(context, "Failed to load leaderboard");
      }
    }
  }

  void _goToNextPage() {
    if (_leaderboardData?.hasNext ?? false) {
      setState(() => _currentPage++);
      _loadLeaderboard();
    }
  }

  void _goToPreviousPage() {
    if (_leaderboardData?.hasPrevious ?? false) {
      setState(() => _currentPage--);
      _loadLeaderboard();
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= (_leaderboardData?.totalPages ?? 1)) {
      setState(() => _currentPage = page);
      _loadLeaderboard();
    }
  }

  void _viewUserProfile(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PublicProfileScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea,
      appBar: AppBar(
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.deepSeaLight,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadLeaderboard(resetPage: true),
              color: AppColors.orangeSport,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.orangeSport,
                      ),
                    )
                  : (_leaderboardData == null || _leaderboardData!.users.isEmpty)
                      ? EmptyLeaderboard(onRetry: () => _loadLeaderboard(resetPage: true))
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          // +1 untuk header
                          itemCount: _leaderboardData!.users.length + 1, 
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: LeaderboardHeader(
                                  totalUsers: _leaderboardData!.totalUsers,
                                  currentUserRank: _leaderboardData!.currentUserRank,
                                ),
                              );
                            }

                            final user = _leaderboardData!.users[index - 1];
                            final isCurrentUser = _leaderboardData!.currentUserRank == user.rank;

                            return FadeTransition(
                              opacity: _animationController,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(
                                  parent: _animationController,
                                  curve: Curves.easeOut,
                                )),
                                child: LeaderboardCard(
                                  user: user,
                                  isCurrentUser: isCurrentUser,
                                  onTap: () => _viewUserProfile(user.userId),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
          
          // Pagination Controls di luar ListView agar tetap fixed di bawah
          if (!_isLoading &&
              _leaderboardData != null &&
              _leaderboardData!.users.isNotEmpty)
            PaginationControls(
              currentPage: _leaderboardData!.currentPage,
              totalPages: _leaderboardData!.totalPages,
              hasNext: _leaderboardData!.hasNext,
              hasPrevious: _leaderboardData!.hasPrevious,
              onNext: _goToNextPage,
              onPrevious: _goToPreviousPage,
              onPageSelected: _goToPage,
            ),
        ],
      ),
    );
  }
}