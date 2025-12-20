import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/leaderboard/data/services/leaderboard_service.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/points_dashboard_model.dart';
import 'package:bond_up_mobile/features/leaderboard/presentation/widgets/ranking_tier_badge.dart';
import 'package:bond_up_mobile/features/leaderboard/presentation/screens/points_history_screen.dart';

/// Points dashboard screen showing user's points summary and statistics
class PointsDashboardScreen extends StatefulWidget {
  const PointsDashboardScreen({super.key});

  @override
  State<PointsDashboardScreen> createState() => _PointsDashboardScreenState();
}

class _PointsDashboardScreenState extends State<PointsDashboardScreen> {
  PointsDashboardModel? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
    });

    final request = context.read<CookieRequest>();
    final leaderboardService = LeaderboardService(request);

    final response = await leaderboardService.getPointsDashboard();

    if (mounted) {
      setState(() {
        _dashboardData = response.data;
        _isLoading = false;
      });

      if (!response.status) {
        ToastUtils.showError(context, response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepSea,
      appBar: AppBar(
        title: const Text(
          'Points Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.deepSeaLight,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PointsHistoryScreen(),
                ),
              );
            },
            tooltip: 'View Points History',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: AppColors.orangeSport,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.orangeSport,
                ),
              )
            : _buildDashboard(),
      ),
    );
  }

  Widget _buildDashboard() {
    if (_dashboardData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load dashboard',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadDashboard,
              child: const Text(
                'Retry',
                style: TextStyle(color: AppColors.orangeSport),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          _buildBreakdownSection(),
          const SizedBox(height: 16),
          _buildAchievementsSection(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return DeepSeaCard(
      body: Column(
        children: [
          // Tier badge
          RankingTierBadge(
            tier: _dashboardData!.tier,
            badge: _dashboardData!.badge,
            size: 32,
          ),
          const SizedBox(height: 16),
          // Total points
          Text(
            '${_dashboardData!.totalPoints}',
            style: const TextStyle(
              color: AppColors.orangeSport,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Total Points',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.emoji_events,
                label: 'Rank',
                value: _dashboardData!.currentRank != null
                    ? '#${_dashboardData!.currentRank}'
                    : 'N/A',
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white24,
              ),
              _buildStatItem(
                icon: Icons.event,
                label: 'Events',
                value: '${_dashboardData!.totalEvents}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.orangeSport, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Points Breakdown',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        DeepSeaCard(
          body: Column(
            children: _dashboardData!.breakdown.entries.map((entry) {
              final breakdown = entry.value;
              if (breakdown.count == 0) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            breakdown.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${breakdown.count} activities',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${breakdown.total}',
                      style: const TextStyle(
                        color: AppColors.orangeSport,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    if (_dashboardData!.recentAchievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Achievements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._dashboardData!.recentAchievements.map((achievement) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: DeepSeaCard(
              body: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.orangeSport.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '🏆',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          achievement.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+${achievement.bonusPoints}',
                    style: const TextStyle(
                      color: AppColors.orangeSport,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

