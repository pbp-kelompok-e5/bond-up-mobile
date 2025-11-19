import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// Chip size variants
enum ChipSize { small, medium, large }

/// Chip style variants
enum ChipVariant { primary, secondary, filled }

/// BondUp Custom Chip Widget
/// Based on .global.css chip design system
class AppChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final ChipSize size;
  final ChipVariant variant;
  final bool isActive;
  final bool isDisabled;
  final Widget? icon;

  const AppChip({
    super.key,
    required this.label,
    this.onTap,
    this.onDelete,
    this.size = ChipSize.medium,
    this.variant = ChipVariant.primary,
    this.isActive = false,
    this.isDisabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: _getPadding(),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: Border.all(
            color: _getBorderColor(),
            width: _getBorderWidth(),
          ),
          borderRadius: BorderRadius.circular(360),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              SizedBox(
                width: _getIconSize(),
                height: _getIconSize(),
                child: icon,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: _getFontSize(),
                fontWeight: _getFontWeight(),
                color: _getTextColor(),
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: isDisabled ? null : onDelete,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getCloseButtonColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: _getTextColor(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ChipSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 6);
      case ChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 8);
      case ChipSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ChipSize.small:
        return 12;
      case ChipSize.medium:
        return 14;
      case ChipSize.large:
        return 16;
    }
  }

  double _getIconSize() {
    if (size == ChipSize.large) {
      return 20;
    }
    return 16;
  }

  FontWeight _getFontWeight() {
    if (variant == ChipVariant.primary) {
      return FontWeight.w600;
    }
    return FontWeight.w500;
  }

  double _getBorderWidth() {
    if (variant == ChipVariant.primary) {
      return 4;
    }
    return 2;
  }

  Color _getBackgroundColor() {
    if (isDisabled) {
      return _getBaseBackgroundColor().withValues(alpha: 0.5);
    }
    if (isActive) {
      return AppColors.orangeSport;
    }
    return _getBaseBackgroundColor();
  }

  Color _getBaseBackgroundColor() {
    switch (variant) {
      case ChipVariant.primary:
        return Colors.transparent;
      case ChipVariant.secondary:
        return AppColors.whiteWithOpacity(0.1);
      case ChipVariant.filled:
        return AppColors.orangeSport;
    }
  }

  Color _getBorderColor() {
    if (isDisabled) {
      return _getBaseBorderColor().withValues(alpha: 0.5);
    }
    if (isActive) {
      return AppColors.orangeSport;
    }
    return _getBaseBorderColor();
  }

  Color _getBaseBorderColor() {
    switch (variant) {
      case ChipVariant.primary:
        return AppColors.orangeSport;
      case ChipVariant.secondary:
        return AppColors.whiteWithOpacity(0.3);
      case ChipVariant.filled:
        return AppColors.orangeSport;
    }
  }

  Color _getTextColor() {
    if (isActive || variant == ChipVariant.filled) {
      return AppColors.white;
    }
    switch (variant) {
      case ChipVariant.primary:
        return AppColors.orangeSport;
      case ChipVariant.secondary:
        return AppColors.white;
      case ChipVariant.filled:
        return AppColors.white;
    }
  }

  Color _getCloseButtonColor() {
    if (variant == ChipVariant.primary) {
      return AppColors.orangeSportWithOpacity(0.2);
    }
    return AppColors.blackWithOpacity(0.1);
  }
}

