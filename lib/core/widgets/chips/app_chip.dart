import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// Variasi ukuran Chip: kecil, sedang, besar
enum ChipSize { small, medium, large }

/// Variasi gaya visual Chip:
/// - Primary: Outline tebal (khas BondUp)
/// - Secondary: Soft background, border tipis
/// - Filled: Background penuh warna solid
enum ChipVariant { primary, secondary, filled }

/// Widget Custom Chip BondUp
/// Digunakan untuk filter, tag, atau pilihan kategori.
class AppChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;       // Aksi saat chip ditekan
  final VoidCallback? onDelete;    // Aksi saat tombol 'X' (jika ada) ditekan
  final ChipSize size;
  final ChipVariant variant;
  final bool isActive;             // State aktif (misal: kategori terpilih)
  final bool isDisabled;           // State mati (tidak bisa diklik)
  final Widget? icon;              // Ikon opsional di sebelah kiri teks

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
    // Menghitung opacity dasar jika state disabled
    final double opacity = isDisabled ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut, // Animasi transisi warna yang lebih smooth
          padding: _getPadding(),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            border: Border.all(
              color: _getBorderColor(),
              width: _getBorderWidth(),
            ),
            // Menggunakan capsule shape (360) agar sudut melengkung sempurna
            borderRadius: BorderRadius.circular(360),
            boxShadow: isActive && !isDisabled
                ? [
                    BoxShadow(
                      color: AppColors.orangeSport.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Render Ikon (jika disediakan)
              if (icon != null) ...[
                IconTheme(
                  data: IconThemeData(
                    size: _getIconSize(),
                    color: _getTextColor(),
                  ),
                  child: icon!,
                ),
                const SizedBox(width: 8),
              ],

              // 2. Label Teks
              Text(
                label,
                style: TextStyle(
                  fontSize: _getFontSize(),
                  fontWeight: _getFontWeight(),
                  color: _getTextColor(),
                  letterSpacing: 0.2, // Sedikit spasi agar teks lebih modern
                ),
              ),

              // 3. Tombol Hapus (jika onDelete disediakan)
              if (onDelete != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: isDisabled ? null : onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: _getCloseButtonColor(),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: _getIconSize() * 0.75, // Ukuran proporsional dengan font
                      color: _getTextColor(),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Methods untuk Styling ---

  EdgeInsets _getPadding() {
    switch (size) {
      case ChipSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 4);
      case ChipSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ChipSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }

  double _getFontSize() {
    switch (size) {
      case ChipSize.small: return 12;
      case ChipSize.medium: return 14;
      case ChipSize.large: return 16;
    }
  }

  double _getIconSize() => _getFontSize() + 2;

  FontWeight _getFontWeight() {
    // Variant primary dan state aktif menggunakan font lebih tebal
    return (variant == ChipVariant.primary || isActive) 
        ? FontWeight.w600 
        : FontWeight.w500;
  }

  double _getBorderWidth() {
    if (isActive) return 2.0; // Konsistensi border saat aktif
    return variant == ChipVariant.primary ? 1.5 : 1.0;
  }

  Color _getBackgroundColor() {
    if (isActive || variant == ChipVariant.filled) {
      return AppColors.orangeSport;
    }
    switch (variant) {
      case ChipVariant.secondary:
        return AppColors.whiteWithOpacity(0.05);
      default:
        return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    if (isActive) return AppColors.orangeSport;
    
    switch (variant) {
      case ChipVariant.primary:
        return AppColors.orangeSport;
      case ChipVariant.secondary:
        return AppColors.whiteWithOpacity(0.2);
      case ChipVariant.filled:
        return AppColors.orangeSport;
    }
  }

  Color _getTextColor() {
    // Jika background gelap (orange), teks harus putih
    if (isActive || variant == ChipVariant.filled) {
      return Colors.white;
    }
    
    if (variant == ChipVariant.primary) {
      return AppColors.orangeSport;
    }
    
    return Colors.white; // Default untuk secondary
  }

  Color _getCloseButtonColor() {
    // Warna background lingkaran kecil pada tombol 'X'
    return _getTextColor().withValues(alpha: 0.15);
  }
}