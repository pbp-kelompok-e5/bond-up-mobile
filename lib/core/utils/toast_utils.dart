import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// Toast types
enum ToastType { success, error, warning, info }

/// BondUp Toast Utility
/// Based on .global.css toast design system
class ToastUtils {
  ToastUtils._();

  /// Show a toast message
  static void showToast(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration + const Duration(milliseconds: 300), () {
      overlayEntry.remove();
    });
  }

  /// Show success toast
  static void showSuccess(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.success);
  }

  /// Show error toast
  static void showError(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.error);
  }

  /// Show warning toast
  static void showWarning(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.warning);
  }

  /// Show info toast
  static void showInfo(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.info);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      right: 16,
      left: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: _getGradient(),
                borderRadius: BorderRadius.circular(8),
                border: Border(
                  left: BorderSide(
                    color: _getBorderColor(),
                    width: 4,
                  ),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getIcon(),
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradient() {
    switch (widget.type) {
      case ToastType.success:
        return const LinearGradient(
          colors: [AppColors.toastSuccessStart, AppColors.toastSuccessEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ToastType.error:
        return const LinearGradient(
          colors: [AppColors.toastErrorStart, AppColors.toastErrorEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ToastType.warning:
        return const LinearGradient(
          colors: [AppColors.toastWarningStart, AppColors.toastWarningEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case ToastType.info:
        return const LinearGradient(
          colors: [AppColors.toastInfoStart, AppColors.toastInfoEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Color _getBorderColor() {
    switch (widget.type) {
      case ToastType.success:
        return AppColors.toastSuccessBorder;
      case ToastType.error:
        return AppColors.toastErrorBorder;
      case ToastType.warning:
        return AppColors.toastWarningBorder;
      case ToastType.info:
        return AppColors.toastInfoBorder;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }
}

