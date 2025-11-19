import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// Button size variants
enum ButtonSize { small, medium, large }

/// Button style variants
enum ButtonVariant { primary, secondary, outline, danger, success }

/// BondUp Custom Button Widget
/// Based on .global.css button design system
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final ButtonVariant variant;
  final bool isFullWidth;
  final Widget? icon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
    this.isFullWidth = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: Padding(
          padding: _getPadding(),
          child: Row(
            mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                SizedBox(
                  width: _getIconSize(),
                  height: _getIconSize(),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getTextColor(),
                    ),
                    color: _getTextColor(),
                  ),
                )
              else if (icon != null) ...[
                SizedBox(
                  width: _getIconSize(),
                  height: _getIconSize(),
                  child: icon,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: _getFontSize(),
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: _getBackgroundColor(),
      foregroundColor: _getTextColor(),
      disabledBackgroundColor: _getBackgroundColor().withValues(alpha: 0.5),
      disabledForegroundColor: _getTextColor().withValues(alpha: 0.5),
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: _getBorderSide(),
      ),
      padding: EdgeInsets.zero,
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return _getPressedColor();
          }
          if (states.contains(WidgetState.hovered)) {
            return _getHoverColor();
          }
          return null;
        },
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 16);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 48, vertical: 20);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.medium:
        return 16;
      case ButtonSize.large:
        return 18;
    }
  }

  double _getIconSize() {
    return 20;
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.orangeSport;
      case ButtonVariant.secondary:
        return AppColors.buttonSecondary;
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.danger:
        return AppColors.buttonDanger;
      case ButtonVariant.success:
        return AppColors.buttonSuccess;
    }
  }

  Color _getTextColor() {
    if (variant == ButtonVariant.outline) {
      return AppColors.orangeSport;
    }
    return AppColors.white;
  }

  Color _getHoverColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.orangeSportHover;
      case ButtonVariant.secondary:
        return AppColors.buttonSecondaryHover;
      case ButtonVariant.outline:
        return AppColors.orangeSportWithOpacity(0.1);
      case ButtonVariant.danger:
        return AppColors.buttonDangerHover;
      case ButtonVariant.success:
        return AppColors.buttonSuccessHover;
    }
  }

  Color _getPressedColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.orangeSportActive;
      case ButtonVariant.secondary:
        return AppColors.buttonSecondaryHover;
      case ButtonVariant.outline:
        return AppColors.orangeSportWithOpacity(0.15);
      case ButtonVariant.danger:
        return AppColors.buttonDangerHover;
      case ButtonVariant.success:
        return AppColors.buttonSuccessHover;
    }
  }

  BorderSide _getBorderSide() {
    if (variant == ButtonVariant.outline) {
      return const BorderSide(
        color: AppColors.orangeSport,
        width: 2,
      );
    }
    return BorderSide.none;
  }
}

