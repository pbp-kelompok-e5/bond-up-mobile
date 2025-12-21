import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// Variasi ukuran tombol
enum ButtonSize { small, medium, large }

/// Variasi gaya visual tombol
enum ButtonVariant { primary, secondary, outline, danger, success }

/// Widget Custom Button BondUp
/// Komponen tombol utama yang mendukung variasi warna, ukuran,
/// ikon, dan status loading sesuai design system.
class AppButton extends StatelessWidget {
  final String text;                  // Teks label tombol
  final VoidCallback? onPressed;      // Fungsi yang dijalankan saat ditekan
  final ButtonSize size;              // Ukuran tombol
  final ButtonVariant variant;        // Gaya warna tombol
  final bool isFullWidth;             // Jika true, lebar tombol akan mentok (expand)
  final Widget? icon;                 // Ikon opsional di kiri teks
  final bool isLoading;               // Menampilkan indikator loading

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
    // Menentukan apakah tombol bisa diklik
    // Tombol non-aktif jika: onPressed null ATAU sedang loading
    final bool isEnabled = onPressed != null && !isLoading;

    return SizedBox(
      // Mengatur lebar: Infinity jika fullWidth, null jika mengikuti konten
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: _getButtonStyle(),
        child: Padding(
          padding: _getPadding(),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Agar Row tidak memakan tempat berlebih
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Menangani Status Loading
              if (isLoading) ...[
                SizedBox(
                  width: _getIconSize(),
                  height: _getIconSize(),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5, // Sedikit ditebalkan agar jelas
                    valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                  ),
                ),
                const SizedBox(width: 12), // Jarak antara loader dan teks
              ] 
              // 2. Menangani Ikon (Hanya muncul jika TIDAK loading)
              else if (icon != null) ...[
                SizedBox(
                  width: _getIconSize(),
                  height: _getIconSize(),
                  child: IconTheme(
                    // Memastikan warna ikon mengikuti teks
                    data: IconThemeData(color: _getTextColor(), size: _getIconSize()),
                    child: icon!,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              // 3. Label Teks
              Text(
                text,
                style: TextStyle(
                  fontSize: _getFontSize(),
                  fontWeight: FontWeight.w600, // Sedikit lebih tebal untuk keterbacaan
                  color: _getTextColor(),
                  letterSpacing: 0.5, // Memberi kesan elegan
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Mengelola style tombol secara keseluruhan (Warna, Bentuk, Overlay)
  ButtonStyle _getButtonStyle() {
    return ButtonStyle(
      // Warna Latar Belakang (Normal & Disabled)
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          // Warna saat mati/loading
          return _getBackgroundColor().withValues(alpha: 0.5); 
        }
        return _getBackgroundColor();
      }),
      
      // Warna Teks/Ikon (Normal & Disabled)
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return _getTextColor().withValues(alpha: 0.6);
        }
        return _getTextColor();
      }),
      
      // Efek Overlay (Saat ditekan atau di-hover)
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return _getPressedColor();
        }
        if (states.contains(WidgetState.hovered)) {
          return _getHoverColor();
        }
        return null;
      }),
      
      // Menghilangkan bayangan default (Flat Design)
      elevation: const WidgetStatePropertyAll(0),
      
      // Bentuk Tombol (Pill Shape / Rounded)
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Lebih bulat (Pill shape)
          side: _getBorderSide(),
        ),
      ),

      // Minimum Size untuk aksesibilitas (Target sentuh aman)
      minimumSize: WidgetStatePropertyAll(
        _getMinimumSize(),
      ),
      
      // Reset padding bawaan ElevatedButton agar padding custom kita bekerja
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
    );
  }

  // --- Helper Methods untuk Logika Desain ---

  /// Padding internal tombol berdasarkan ukuran
  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 14);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  /// Ukuran minimum area sentuh (penting untuk mobile)
  Size _getMinimumSize() {
    switch (size) {
      case ButtonSize.small: return const Size(0, 36);
      case ButtonSize.medium: return const Size(0, 48);
      case ButtonSize.large: return const Size(0, 56);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ButtonSize.small: return 12;
      case ButtonSize.medium: return 14;
      case ButtonSize.large: return 16;
    }
  }

  double _getIconSize() {
    // Ikon sedikit lebih besar dari teks agar seimbang
    return _getFontSize() + 4;
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case ButtonVariant.primary:
        return AppColors.orangeSport;
      case ButtonVariant.secondary:
        return AppColors.buttonSecondary; // Pastikan warna ini kontras
      case ButtonVariant.outline:
        return Colors.transparent;
      case ButtonVariant.danger:
        return AppColors.buttonDanger;
      case ButtonVariant.success:
        return AppColors.buttonSuccess;
    }
  }

  Color _getTextColor() {
    // Tombol Outline biasanya teksnya berwarna (bukan putih)
    if (variant == ButtonVariant.outline) {
      return AppColors.orangeSport;
    }
    // Variant Secondary mungkin butuh teks hitam jika background terang
    // Sesuaikan logika ini dengan palet warna Anda
    if (variant == ButtonVariant.secondary) {
      return AppColors.white; 
    }
    return AppColors.white;
  }

  /// Warna overlay saat di-hover (Mouse)
  Color _getHoverColor() {
    if (variant == ButtonVariant.outline) {
      return AppColors.orangeSport.withValues(alpha: 0.1);
    }
    // Menggunakan warna putih transparan untuk efek "lighten" universal
    return Colors.white.withValues(alpha: 0.1);
  }

  /// Warna overlay saat ditekan (Tap)
  Color _getPressedColor() {
    if (variant == ButtonVariant.outline) {
      return AppColors.orangeSport.withValues(alpha: 0.2);
    }
    // Menggunakan warna hitam transparan untuk efek "darken" universal
    return Colors.black.withValues(alpha: 0.1);
  }

  BorderSide _getBorderSide() {
    if (variant == ButtonVariant.outline) {
      return const BorderSide(
        color: AppColors.orangeSport,
        width: 1.5, // Ketebalan border outline
      );
    }
    // Jika tombol disabled, border harus transparan/hilang
    return BorderSide.none;
  }
}