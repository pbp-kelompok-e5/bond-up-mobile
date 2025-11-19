import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// Status types for badge
enum StatusType { active, cancelled, completed }

/// BondUp Status Badge Widget
/// Based on .global.css status-badge design system
class StatusBadge extends StatelessWidget {
  final StatusType status;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getBorderColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            customLabel ?? _getLabel(),
            style: TextStyle(
              color: _getBorderColor(),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getLabel() {
    switch (status) {
      case StatusType.active:
        return 'ACTIVE';
      case StatusType.cancelled:
        return 'CANCELLED';
      case StatusType.completed:
        return 'COMPLETED';
    }
  }

  Color _getBackgroundColor() {
    switch (status) {
      case StatusType.active:
        return AppColors.statusActiveBackground;
      case StatusType.cancelled:
        return AppColors.statusCancelledBackground;
      case StatusType.completed:
        return AppColors.statusCompletedBackground;
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case StatusType.active:
        return AppColors.statusActive;
      case StatusType.cancelled:
        return AppColors.statusCancelled;
      case StatusType.completed:
        return AppColors.statusCompleted;
    }
  }
}

