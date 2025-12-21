import 'package:flutter/material.dart';
import 'package:bond_up_mobile/core/theme/app_colors.dart';

/// Widget Custom Text Field untuk BondUp
/// Didesain agar sesuai dengan style guide global (warna orangeSport)
/// dan mendukung validasi serta state error.
class AppTextField extends StatefulWidget {
  // --- Data & Controller ---
  final String? label;                  // Label di atas input field
  final String? hint;                   // Teks petunjuk di dalam field (placeholder)
  final TextEditingController? controller; // Pengontrol teks (wajib jika ingin memproses value)
  final String? errorText;              // Pesan error (jika ada, border jadi merah)

  // --- Konfigurasi Input ---
  final bool obscureText;               // Untuk password (teks tersembunyi)
  final bool enablePasswordToggle;      // Menampilkan ikon mata untuk toggle password visibility
  final TextInputType? keyboardType;    // Tipe keyboard (angka, email, text, dll)
  final int? maxLines;                  // Jumlah baris maksimal
  final int? minLines;                  // Jumlah baris minimal
  final bool readOnly;                  // Jika true, user tidak bisa ngetik manual
  final bool enabled;                   // Jika false, field terlihat mati (abu-abu/disabled)

  // --- Aksi & Event ---
  final ValueChanged<String>? onChanged; // Callback saat teks berubah
  final VoidCallback? onTap;             // Callback saat field diklik
  final String? Function(String?)? validator; // Fungsi validasi form
  final TextInputAction? textInputAction; // Tombol aksi di keyboard (Next/Done/Search)
  final ValueChanged<String>? onFieldSubmitted; // Aksi saat tombol enter ditekan
  final FocusNode? focusNode;            // Untuk mengontrol fokus secara programatikal

  // --- Ikon ---
  final Widget? prefixIcon;             // Ikon di kiri teks
  final Widget? suffixIcon;             // Ikon di kanan teks (misal: mata toggle password)

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.enablePasswordToggle = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.validator,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine the effective suffix icon
    Widget? effectiveSuffixIcon = widget.suffixIcon;

    // If password toggle is enabled and obscureText is true, show eye icon
    if (widget.enablePasswordToggle && widget.obscureText) {
      effectiveSuffixIcon = IconButton(
        icon: Icon(
          _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.orangeSport,
        ),
        onPressed: _togglePasswordVisibility,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Render Label jika ada
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              color: AppColors.orangeSport,
              fontSize: 16,
              fontWeight: FontWeight.w600, // Semi-bold agar terbaca jelas sebagai header
            ),
          ),
          const SizedBox(height: 8), // Jarak manis antara label dan kotak input
        ],

        // 2. Input Field Utama
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,

          // Konfigurasi Teks
          obscureText: _isObscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction, // UX: Mengatur tombol enter di keyboard
          onFieldSubmitted: widget.onFieldSubmitted, // UX: Pindah ke field berikutnya otomatis

          // Layout Baris
          // Logika: Jika password (obscure), paksa 1 baris. Jika tidak, ikuti maxLines.
          maxLines: _isObscured ? 1 : widget.maxLines,
          minLines: widget.minLines,

          // Event Handlers
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          validator: widget.validator,

          // Style Teks Input
          style: const TextStyle(
            color: AppColors.orangeSport,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),

          // Style Dekorasi (Border, Ikon, Hint)
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              // Opacity 0.5 agar hint tidak setebal teks asli (hierarki visual)
              color: AppColors.orangeSportWithOpacity(0.5),
              fontSize: 16,
            ),

            prefixIcon: widget.prefixIcon,
            suffixIcon: effectiveSuffixIcon,

            // Konfigurasi Error Text
            errorText: widget.errorText,
            errorStyle: const TextStyle(
              color: AppColors.buttonDanger,
              fontSize: 14,
            ),

            // Background
            filled: false, // Transparan sesuai request
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12, // Padding vertikal yang nyaman untuk jari
            ),

            // --- Manajemen Border (Menggunakan Helper Function) ---
            // Border default saat tidak aktif
            border: _buildBorder(
              color: widget.errorText != null ? AppColors.buttonDanger : AppColors.orangeSport
            ),
            // Border saat aktif tapi belum diklik
            enabledBorder: _buildBorder(
              color: widget.errorText != null ? AppColors.buttonDanger : AppColors.orangeSport
            ),
            // Border saat diklik (Fokus)
            focusedBorder: _buildBorder(
              color: widget.errorText != null ? AppColors.buttonDanger : AppColors.orangeSportHover,
              width: 2.0, // Sedikit lebih tebal saat fokus agar user sadar
            ),
            // Border saat error
            errorBorder: _buildBorder(color: AppColors.buttonDanger),
            // Border saat error dan sedang diklik
            focusedErrorBorder: _buildBorder(color: AppColors.buttonDanger, width: 2.0),
            // Border saat disabled
            disabledBorder: _buildBorder(
              color: AppColors.orangeSportWithOpacity(0.5)
            ),
          ),
        ),
      ],
    );
  }

  /// Helper function: Membuat OutlineInputBorder secara dinamis.
  OutlineInputBorder _buildBorder({required Color color, double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8), // Radius sudut kotak
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}