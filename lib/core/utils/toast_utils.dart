import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// Tipe notifikasi toast
enum ToastType { success, error, warning, info }

/// Utilitas Toast Global BondUp
/// Menggunakan OverlayEntry untuk menampilkan pesan di atas semua widget.
class ToastUtils {
  // Private constructor agar class ini tidak bisa di-instansiasi
  ToastUtils._();

  /// Menampilkan toast message
  static void showToast(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Validasi: Pastikan context masih valid dan memiliki Overlay
    final overlayState = Overlay.maybeOf(context);
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;

    // Fungsi untuk menghapus overlay (digunakan di dalam widget dan timer)
    void removeOverlay() {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    }

    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: removeOverlay,
      ),
    );

    overlayState.insert(overlayEntry);
  }

  /// Helper: Tampilkan Sukses
  static void showSuccess(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.success);
  }

  /// Helper: Tampilkan Error
  static void showError(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.error);
  }

  /// Helper: Tampilkan Peringatan
  static void showWarning(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.warning);
  }

  /// Helper: Tampilkan Info
  static void showInfo(BuildContext context, String message) {
    showToast(context, message: message, type: ToastType.info);
  }
}

/// Widget internal untuk menampilkan UI Toast
class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  // Timer untuk auto-dismiss
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400), // Sedikit diperlambat agar smooth
      vsync: this,
    );

    // Animasi Slide: Dari bawah sedikit ke posisi normal
    // Menggunakan easeOutBack untuk efek "membal" (pop) yang elegan
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5), 
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    ));

    // Animasi Fade
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Mulai animasi masuk
    _controller.forward();

    // Set timer untuk menghilangkan toast otomatis
    Future.delayed(widget.duration, () {
      _dismissToast();
    });
  }

  /// Fungsi aman untuk memulai animasi keluar lalu menghapus overlay
  void _dismissToast() {
    if (_isDismissed || !mounted) return;
    _isDismissed = true;
    
    _controller.reverse().then((_) {
      widget.onDismiss();
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
      bottom: 0, // Posisi dasar 0, tapi diatur padding oleh SafeArea
      left: 0,
      right: 0,
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                // Wrap dengan Material agar text style normal (tidak garis bawah kuning/merah)
                child: Material(
                  color: Colors.transparent,
                  // Fitur Swipe-to-Dismiss: Geser toast untuk menutup instan
                  child: Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.horizontal,
                    onDismissed: (_) => widget.onDismiss(),
                    child: GestureDetector(
                      onTap: _dismissToast, // Tap juga bisa menutup toast
                      child: Container(
                        // Batasi lebar agar tidak terlalu lebar di tablet/web
                        constraints: const BoxConstraints(maxWidth: 400),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: _getGradient(),
                          borderRadius: BorderRadius.circular(12), // Radius lebih modern
                          boxShadow: [
                            BoxShadow(
                              color: _getShadowColor().withValues(alpha: 0.3),
                              blurRadius: 16, // Shadow lebih lembut (diffused)
                              offset: const Offset(0, 6),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min, // Agar container fit content
                          children: [
                            // Ikon Status
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIcon(),
                                color: AppColors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Pesan Toast
                            Flexible(
                              child: Text(
                                widget.message,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4, // Keterbacaan yang baik
                                ),
                                maxLines: 2, // Batasi maksimal 2 baris
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Methods untuk Styling ---

  LinearGradient _getGradient() {
    switch (widget.type) {
      case ToastType.success:
        return const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)], // Green Dark -> Light
        );
      case ToastType.error:
        return const LinearGradient(
          colors: [Color(0xFFC62828), Color(0xFFEF5350)], // Red Dark -> Light
        );
      case ToastType.warning:
        return const LinearGradient(
          colors: [Color(0xFFF57F17), Color(0xFFFFB74D)], // Amber Dark -> Light
        );
      case ToastType.info:
        return const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)], // Blue Dark -> Light
        );
    }
  }

  Color _getShadowColor() {
    switch (widget.type) {
      case ToastType.success: return Colors.green.shade900;
      case ToastType.error: return Colors.red.shade900;
      case ToastType.warning: return Colors.orange.shade900;
      case ToastType.info: return Colors.blue.shade900;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success: return Icons.check_rounded;
      case ToastType.error: return Icons.close_rounded;
      case ToastType.warning: return Icons.priority_high_rounded;
      case ToastType.info: return Icons.info_outline_rounded;
    }
  }
}