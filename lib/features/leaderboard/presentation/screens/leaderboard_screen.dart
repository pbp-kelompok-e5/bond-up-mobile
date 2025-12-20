import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/leaderboard/data/services/leaderboard_service.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/leaderboard_entry_model.dart';
import 'package:bond_up_mobile/features/leaderboard/presentation/widgets/ranking_tier_badge.dart';
import 'package:bond_up_mobile/features/profile/presentation/screens/public_profile_screen.dart';

/// Leaderboard screen showing ranked users by points
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
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
    if (resetPage) {
      _currentPage = 1;
    }

    setState(() {
      _isLoading = true;
    });

    final request = context.read<CookieRequest>();
    final leaderboardService = LeaderboardService(request);

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
  }

  void _goToNextPage() {
    if (_leaderboardData?.hasNext ?? false) {
      setState(() {
        _currentPage++;
      });
      _loadLeaderboard();
    }
  }

  void _goToPreviousPage() {
    if (_leaderboardData?.hasPrevious ?? false) {
      setState(() {
        _currentPage--;
      });
      _loadLeaderboard();
    }
  }

  void _goToPage(int page) {
    if (page >= 1 && page <= (_leaderboardData?.totalPages ?? 1)) {
      setState(() {
        _currentPage = page;
      });
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
      body: RefreshIndicator(
        onRefresh: () => _loadLeaderboard(resetPage: true),
        color: AppColors.orangeSport,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.orangeSport,
                ),
              )
            : _buildLeaderboardList(),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    if (_leaderboardData == null || _leaderboardData!.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.leaderboard_outlined,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'No leaderboard data available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _loadLeaderboard(resetPage: true),
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.orangeSport),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            itemCount: _leaderboardData!.users.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader();
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
                  child: _buildLeaderboardCard(user, isCurrentUser),
                ),
              );
            },
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  Widget _buildHeader() {
    return DeepSeaCard(
      body: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            size: 48,
            color: Color(0xFFFFD700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Top Players',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_leaderboardData!.totalUsers} players ranked',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (_leaderboardData!.currentUserRank != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.orangeSport.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.orangeSport),
              ),
              child: Text(
                'Your Rank: #${_leaderboardData!.currentUserRank}',
                style: const TextStyle(
                  color: AppColors.orangeSport,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntryModel user, bool isCurrentUser) {
    // Enhanced colors for top 3
    Color? cardGradientStart;
    Color? cardGradientEnd;

    if (user.rank == 1) {
      cardGradientStart = const Color(0xFFFFD700).withOpacity(0.15);
      cardGradientEnd = const Color(0xFFFFD700).withOpacity(0.05);
    } else if (user.rank == 2) {
      cardGradientStart = const Color(0xFFC0C0C0).withOpacity(0.15);
      cardGradientEnd = const Color(0xFFC0C0C0).withOpacity(0.05);
    } else if (user.rank == 3) {
      cardGradientStart = const Color(0xFFCD7F32).withOpacity(0.15);
      cardGradientEnd = const Color(0xFFCD7F32).withOpacity(0.05);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: cardGradientStart != null
            ? LinearGradient(
                colors: [cardGradientStart, cardGradientEnd!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: cardGradientStart == null
            ? (isCurrentUser
                ? AppColors.orangeSport.withOpacity(0.15)
                : AppColors.deepSeaLight)
            : null,
        borderRadius: BorderRadius.circular(16),
        border: isCurrentUser
            ? Border.all(color: AppColors.orangeSport, width: 2.5)
            : (user.rank <= 3
                ? Border.all(
                    color: user.rank == 1
                        ? const Color(0xFFFFD700)
                        : user.rank == 2
                            ? const Color(0xFFC0C0C0)
                            : const Color(0xFFCD7F32),
                    width: 2,
                  )
                : null),
        boxShadow: user.rank <= 3 || isCurrentUser
            ? [
                BoxShadow(
                  color: (user.rank == 1
                          ? const Color(0xFFFFD700)
                          : user.rank == 2
                              ? const Color(0xFFC0C0C0)
                              : user.rank == 3
                                  ? const Color(0xFFCD7F32)
                                  : AppColors.orangeSport)
                      .withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewUserProfile(user.userId),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Rank badge
                _buildRankBadge(user.rank),
                const SizedBox(width: 16),
                // Profile image with hero animation
                Hero(
                  tag: 'profile_${user.userId}',
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.deepSea,
                    backgroundImage: user.profileImageUrl.isNotEmpty
                        ? NetworkImage(user.profileImageUrl)
                        : null,
                    child: user.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white54, size: 32)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.fullName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                shadows: user.rank <= 3
                                    ? [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(0, 1),
                                          blurRadius: 2,
                                        ),
                                      ]
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orangeSport,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          RankingTierBadge(
                            tier: user.tier,
                            badge: user.badge,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${user.totalEvents} events',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Points and view button
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${user.totalPoints}',
                      style: TextStyle(
                        color: user.rank <= 3
                            ? (user.rank == 1
                                ? const Color(0xFFFFD700)
                                : user.rank == 2
                                    ? const Color(0xFFC0C0C0)
                                    : const Color(0xFFCD7F32))
                            : AppColors.orangeSport,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        shadows: user.rank <= 3
                            ? [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const Text(
                      'points',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    String badgeText;

    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700); // Gold
      badgeText = '🥇';
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0); // Silver
      badgeText = '🥈';
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // Bronze
      badgeText = '🥉';
    } else {
      badgeColor = Colors.white54;
      badgeText = '#$rank';
    }

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: badgeColor, width: 2.5),
        boxShadow: rank <= 3
            ? [
                BoxShadow(
                  color: badgeColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          badgeText,
          style: TextStyle(
            color: rank <= 3 ? badgeColor : Colors.white,
            fontSize: rank <= 3 ? 26 : 17,
            fontWeight: FontWeight.bold,
            shadows: rank <= 3
                ? [
                    Shadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    if (_leaderboardData == null) return const SizedBox.shrink();

    final totalPages = _leaderboardData!.totalPages;
    final currentPage = _leaderboardData!.currentPage;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.deepSeaLight,
        border: Border(
          top: BorderSide(color: AppColors.deepSea, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Page info
          Text(
            'Page $currentPage of $totalPages',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              _buildPageButton(
                icon: Icons.chevron_left,
                label: 'Previous',
                onPressed: _leaderboardData!.hasPrevious ? _goToPreviousPage : null,
              ),
              const SizedBox(width: 12),
              // Page numbers
              ..._buildPageNumbers(),
              const SizedBox(width: 12),
              // Next button
              _buildPageButton(
                icon: Icons.chevron_right,
                label: 'Next',
                onPressed: _leaderboardData!.hasNext ? _goToNextPage : null,
                iconOnRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool iconOnRight = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed != null ? AppColors.orangeSport : AppColors.deepSea,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: onPressed != null ? 2 : 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: iconOnRight
            ? [
                Text(label),
                const SizedBox(width: 4),
                Icon(icon, size: 18),
              ]
            : [
                Icon(icon, size: 18),
                const SizedBox(width: 4),
                Text(label),
              ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    if (_leaderboardData == null) return [];

    final currentPage = _leaderboardData!.currentPage;
    final totalPages = _leaderboardData!.totalPages;
    final List<Widget> pageButtons = [];

    // Show max 5 page numbers
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (currentPage + 2).clamp(1, totalPages);

    // Adjust if we're near the start or end
    if (endPage - startPage < 4) {
      if (startPage == 1) {
        endPage = (startPage + 4).clamp(1, totalPages);
      } else if (endPage == totalPages) {
        startPage = (endPage - 4).clamp(1, totalPages);
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageButtons.add(
        GestureDetector(
          onTap: i != currentPage ? () => _goToPage(i) : null,
          child: Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: i == currentPage ? AppColors.orangeSport : AppColors.deepSea,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: i == currentPage ? AppColors.orangeSport : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                '$i',
                style: TextStyle(
                  color: i == currentPage ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: i == currentPage ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return pageButtons;
  }
}
