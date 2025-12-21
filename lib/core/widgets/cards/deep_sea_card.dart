import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// Widget Kartu Tema 'Deep Sea' (Laut Dalam) BondUp
/// Mengadopsi desain dark-themed dengan efek elevasi saat hover.
class DeepSeaCard extends StatefulWidget {
  // --- Konten ---
  final Widget? header;   // Judul atau elemen atas
  final Widget body;      // Konten utama kartu
  final Widget? footer;   // Aksi atau info tambahan di bawah
  
  // --- Styling & Layout ---
  final EdgeInsets? padding;
  final MainAxisAlignment footerAlignment; // Mengatur posisi footer (kiri/kanan)
  
  // --- Interaksi ---
  final VoidCallback? onTap;
  final bool enableHoverEffect; // Opsi mematikan animasi naik saat hover

  const DeepSeaCard({
    super.key,
    this.header,
    required this.body,
    this.footer,
    this.padding,
    this.footerAlignment = MainAxisAlignment.end, // Default rata kanan
    this.onTap,
    this.enableHoverEffect = true,
  });

  @override
  State<DeepSeaCard> createState() => _DeepSeaCardState();
}

class _DeepSeaCardState extends State<DeepSeaCard> {
  // State untuk melacak apakah mouse sedang berada di atas kartu
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Menentukan apakah efek hover harus aktif
    final bool isHoverActive = widget.enableHoverEffect && _isHovered;

    return MouseRegion(
      // Event saat mouse masuk area widget
      onEnter: (_) => setState(() => _isHovered = true),
      // Event saat mouse keluar area widget
      onExit: (_) => setState(() => _isHovered = false),
      
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          // Durasi animasi transisi (naik/turun, bayangan menipis/menebal)
          duration: const Duration(milliseconds: 200),
          // Curve membuat animasi terasa lebih natural (fisika)
          curve: Curves.easeOutCubic, 
          
          padding: widget.padding ?? const EdgeInsets.all(24),
          
          // --- Transformasi Posisi (Efek Melayang) ---
          transform: isHoverActive
              ? Matrix4.translationValues(0, -6, 0) // Naik 6 pixel
              : Matrix4.identity(), // Posisi normal
              
          decoration: BoxDecoration(
            color: AppColors.deepSea,
            borderRadius: BorderRadius.circular(16),
            
            // Border tipis agar kartu tidak 'tenggelam' di background gelap
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            
            // --- Efek Bayangan ---
            boxShadow: [
              BoxShadow(
                color: AppColors.deepSea.withValues(alpha: isHoverActive ? 0.6 : 0.4),
                blurRadius: isHoverActive ? 24 : 12, // Bayangan makin kabur saat naik
                offset: Offset(0, isHoverActive ? 12 : 4), // Bayangan makin jauh saat naik
                spreadRadius: isHoverActive ? 2 : 0,
              ),
            ],
          ),
          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Agar kartu tidak memanjang sembarangan
            children: [
              // 1. Bagian Header (Jika ada)
              if (widget.header != null) ...[
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                    letterSpacing: -0.5, // Sedikit rapat agar terlihat modern
                  ),
                  child: widget.header!,
                ),
                const SizedBox(height: 12),
              ],
              
              // 2. Bagian Body (Wajib)
              DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white, // Menggunakan warna white yg mungkin sedikit dimming
                  height: 1.5, // Line height untuk keterbacaan paragraf
                ),
                child: widget.body,
              ),
              
              // 3. Bagian Footer (Jika ada)
              if (widget.footer != null) ...[
                const SizedBox(height: 20), // Jarak lebih lega ke footer
                Row(
                  mainAxisAlignment: widget.footerAlignment,
                  children: [
                    // Menggunakan Flexible agar footer tidak overflow jika terlalu panjang
                    Flexible(child: widget.footer!),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}