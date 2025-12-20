import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';

/// Widget to display ranking tier badge based on points
/// 
/// Tier levels:
/// - Master: >= 1000 points (Gold)
/// - Expert: >= 500 points (Silver)
/// - Advanced: >= 200 points (Bronze)
/// - Intermediate: >= 50 points (Star)
/// - Beginner: < 50 points (Shield)
class RankingTierBadge extends StatelessWidget {
  final String tier;
  final String badge;
  final double size;
  final bool showLabel;

  const RankingTierBadge({
    super.key,
    required this.tier,
    required this.badge,
    this.size = 24,
    this.showLabel = true,
  });

  /// Get tier color based on tier name
  Color get tierColor {
    switch (tier.toLowerCase()) {
      case 'master':
        return const Color(0xFFFFD700); // Gold
      case 'expert':
        return const Color(0xFFC0C0C0); // Silver
      case 'advanced':
        return const Color(0xFFCD7F32); // Bronze
      case 'intermediate':
        return AppColors.orangeSport;
      case 'beginner':
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!showLabel) {
      // Badge only
      return Text(
        badge,
        style: TextStyle(fontSize: size),
      );
    }

    // Badge with label
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tierColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tierColor,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            badge,
            style: TextStyle(fontSize: size),
          ),
          const SizedBox(width: 6),
          Text(
            tier,
            style: TextStyle(
              color: tierColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to get tier from points
String getTierFromPoints(int points) {
  if (points >= 1000) {
    return 'Master';
  } else if (points >= 500) {
    return 'Expert';
  } else if (points >= 200) {
    return 'Advanced';
  } else if (points >= 50) {
    return 'Intermediate';
  } else {
    return 'Beginner';
  }
}

/// Helper function to get badge emoji from points
String getBadgeFromPoints(int points) {
  if (points >= 1000) {
    return '🥇';
  } else if (points >= 500) {
    return '🥈';
  } else if (points >= 200) {
    return '🥉';
  } else if (points >= 50) {
    return '⭐';
  } else {
    return '🔰';
  }
}

