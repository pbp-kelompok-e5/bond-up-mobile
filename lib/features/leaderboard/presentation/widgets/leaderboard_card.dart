import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/leaderboard_entry_model.dart';
import 'package:bond_up_mobile/features/leaderboard/presentation/widgets/ranking_tier_badge.dart';
import 'rank_badge.dart';

class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntryModel user;
  final bool isCurrentUser;
  final VoidCallback onTap;

  const LeaderboardCard({
    super.key,
    required this.user,
    required this.isCurrentUser,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color rankColor = _getRankColor(user.rank);
    final bool isTopThree = user.rank <= 3;

    // Gradient Background Logic
    LinearGradient? backgroundGradient;
    if (isTopThree) {
      backgroundGradient = LinearGradient(
        colors: [
          rankColor.withValues(alpha: 0.15),
          rankColor.withValues(alpha: 0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }

    // Border Logic
    Color borderColor = Colors.transparent;
    if (isCurrentUser) {
      borderColor = AppColors.orangeSport;
    } else if (isTopThree) {
      borderColor = rankColor.withValues(alpha: 0.3);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.orangeSport.withValues(alpha: 0.1)
            : AppColors.deepSeaLight,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isCurrentUser ? 2 : 1,
        ),
        boxShadow: isTopThree || isCurrentUser
            ? [
                BoxShadow(
                  color: (isCurrentUser ? AppColors.orangeSport : rankColor)
                      .withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // 1. RANK BADGE
                RankBadge(rank: user.rank),
                
                const SizedBox(width: 14),

                // 2. AVATAR (Dengan Ring untuk Top 3)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isTopThree
                        ? Border.all(color: rankColor, width: 2)
                        : null,
                  ),
                  child: Hero(
                    tag: 'profile_${user.userId}',
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.deepSea,
                      backgroundImage: user.profileImageUrl.isNotEmpty
                          ? NetworkImage(user.profileImageUrl)
                          : null,
                      child: user.profileImageUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.white54, size: 24)
                          : null,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // 3. USER INFO (Hanya Nama & Tier)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nama User
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Label YOU
                          if (isCurrentUser) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orangeSport,
                                borderRadius: BorderRadius.circular(6),
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
                      
                      const SizedBox(height: 6), // Spasi sedikit diperbesar

                      // Tier Badge (Sekarang sendiri di baris kedua)
                      RankingTierBadge(
                        tier: user.tier,
                        badge: user.badge,
                        size: 14,
                      ),
                    ],
                  ),
                ),

                // 4. POINTS DISPLAY
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${user.totalPoints}',
                      style: TextStyle(
                        color: isTopThree ? rankColor : AppColors.orangeSport,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'PTS',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700); // Gold
      case 2: return const Color(0xFFC0C0C0); // Silver
      case 3: return const Color(0xFFCD7F32); // Bronze
      default: return AppColors.orangeSport;
    }
  }
}