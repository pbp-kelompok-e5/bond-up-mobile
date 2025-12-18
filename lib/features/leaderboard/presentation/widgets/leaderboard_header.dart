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
            '$totalUsers players ranked',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          if (currentUserRank != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.orangeSport.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.orangeSport),
              ),
              child: Text(
                'Your Rank: #$currentUserRank',
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
}