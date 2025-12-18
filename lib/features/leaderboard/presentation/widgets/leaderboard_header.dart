import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';

class LeaderboardHeader extends StatelessWidget {
  final int totalUsers;
  final int? currentUserRank;

  const LeaderboardHeader({
    super.key,
    required this.totalUsers,
    this.currentUserRank,
  });

  @override
  Widget build(BuildContext context) {
    return DeepSeaCard(
      body: SizedBox(
        width: double.infinity, 
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. TROPHY DENGAN EFEK GLOW
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.emoji_events_rounded,
                  size: 64,
                  color: Color(0xFFFFD700),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'LEADERBOARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              'Competing against $totalUsers players',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),

            if (currentUserRank != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.orangeSport.withValues(alpha: 0.2),
                      AppColors.orangeSport.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.orangeSport.withValues(alpha: 0.5), 
                    width: 1.5
                  ),
                  boxShadow: [
                     BoxShadow(
                        color: AppColors.orangeSport.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ]
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star, 
                      size: 16, 
                      color: AppColors.orangeSport
                    ),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Your Rank: ',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: '#$currentUserRank',
                            style: const TextStyle(
                              color: AppColors.orangeSport,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}