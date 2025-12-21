import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/design_system.dart';

class EmptyLeaderboard extends StatelessWidget {
  final VoidCallback onRetry;

  const EmptyLeaderboard({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
            onPressed: onRetry,
            child: const Text(
              'Retry',
              style: TextStyle(color: AppColors.orangeSport),
            ),
          ),
        ],
      ),
    );
  }
}