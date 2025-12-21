import 'package:flutter/material.dart';

class RankBadge extends StatelessWidget {
  final int rank;

  const RankBadge({super.key, required this.rank});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String badgeText;
    double size = 52.0;
    double fontSize;

    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700); // Gold
      badgeText = '🥇';
      fontSize = 26;
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0); // Silver
      badgeText = '🥈';
      fontSize = 26;
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // Bronze
      badgeText = '🥉';
      fontSize = 26;
    } else {
      badgeColor = Colors.white54;
      badgeText = '#$rank';
      fontSize = 17;
    }

    // Wrap dengan ConstrainedBox agar tidak layout break di layar sangat kecil
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: badgeColor, width: 2.5),
        boxShadow: rank <= 3
            ? [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.4),
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
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            shadows: rank <= 3
                ? [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
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
}