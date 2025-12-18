import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';
import 'package:bond_up_mobile/features/leaderboard/data/models/leaderboard_entry_model.dart';
import 'package:bond_up_mobile/features/leaderboard/presentation/widgets/ranking_tier_badge.dart'; // Pastikan path ini benar
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
    // Logic warna dipindah ke sini agar build method bersih
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

    Color pointsColor = user.rank <= 3
        ? (user.rank == 1
            ? const Color(0xFFFFD700)
            : user.rank == 2
                ? const Color(0xFFC0C0C0)
                : const Color(0xFFCD7F32))
        : AppColors.orangeSport;

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
                    color: pointsColor,
                    width: 2,
                  )
                : null),
        boxShadow: user.rank <= 3 || isCurrentUser
            ? [
                BoxShadow(
                  color: pointsColor.withOpacity(0.3),
                  blurRadius: 8,
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
            padding: const EdgeInsets.all(12), // Padding sedikit dikecilkan untuk layar sempit
            child: Row(
              children: [
                RankBadge(rank: user.rank),
                const SizedBox(width: 12),
                
                // Avatar
                Hero(
                  tag: 'profile_${user.userId}',
                  child: CircleAvatar(
                    radius: 28, // Sedikit dikecilkan agar muat di layar kecil
                    backgroundColor: AppColors.deepSea,
                    backgroundImage: user.profileImageUrl.isNotEmpty
                        ? NetworkImage(user.profileImageUrl)
                        : null,
                    child: user.profileImageUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white54, size: 28)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                
                // User Info - Menggunakan Expanded agar mengisi ruang sisa
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible( // Flexible penting untuk nama panjang
                            child: Text(
                              user.fullName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16, // Font size responsif
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
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orangeSport,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '@${user.username}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          RankingTierBadge(
                            tier: user.tier,
                            badge: user.badge,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${user.totalEvents} events',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Points Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${user.totalPoints}',
                      style: TextStyle(
                        color: pointsColor,
                        fontSize: 22, // Ukuran font disesuaikan
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'pts', // Disingkat agar hemat tempat
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
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
}