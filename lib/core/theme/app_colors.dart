import 'package:flutter/material.dart';

/// BondUp App Color Palette
/// Translated from .global.css design system
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ===== BRAND COLORS =====
  
  /// Orange Sport - Primary Brand Color
  static const Color orangeSport = Color(0xFFF26419);
  static const Color orangeSportHover = Color(0xFFD94F0F);
  static const Color orangeSportActive = Color(0xFFC0430D);
  
  /// Deep Sea - Secondary Brand Color
  static const Color deepSea = Color(0xFF00063D);
  static const Color deepSeaLight = Color(0xFF1A1F5C);
  static const Color deepSeaLighter = Color(0xFF2A2F6C);

  // ===== BUTTON COLORS =====
  
  /// Secondary button color
  static const Color buttonSecondary = Color(0xFF6B7280);
  static const Color buttonSecondaryHover = Color(0xFF4B5563);
  
  /// Danger button color
  static const Color buttonDanger = Color(0xFFDC2626);
  static const Color buttonDangerHover = Color(0xFFB91C1C);
  
  /// Success button color
  static const Color buttonSuccess = Color(0xFF16A34A);
  static const Color buttonSuccessHover = Color(0xFF15803D);

  // ===== STATUS COLORS =====
  
  /// Active status
  static const Color statusActive = Color(0xFF22C55E);
  static const Color statusActiveBackground = Color(0x3322C55E); // 20% opacity
  
  /// Cancelled status
  static const Color statusCancelled = Color(0xFFEF4444);
  static const Color statusCancelledBackground = Color(0x33EF4444); // 20% opacity
  
  /// Completed status
  static const Color statusCompleted = Color(0xFF3B82F6);
  static const Color statusCompletedBackground = Color(0x333B82F6); // 20% opacity

  // ===== TOAST COLORS =====
  
  /// Success toast
  static const Color toastSuccessStart = Color(0xFF10B981);
  static const Color toastSuccessEnd = Color(0xFF059669);
  static const Color toastSuccessBorder = Color(0xFF047857);
  
  /// Error toast
  static const Color toastErrorStart = Color(0xFFEF4444);
  static const Color toastErrorEnd = Color(0xFFDC2626);
  static const Color toastErrorBorder = Color(0xFF991B1B);
  
  /// Warning toast
  static const Color toastWarningStart = Color(0xFFF59E0B);
  static const Color toastWarningEnd = Color(0xFFD97706);
  static const Color toastWarningBorder = Color(0xFFB45309);
  
  /// Info toast
  static const Color toastInfoStart = Color(0xFF3B82F6);
  static const Color toastInfoEnd = Color(0xFF2563EB);
  static const Color toastInfoBorder = Color(0xFF1E40AF);

  // ===== NEUTRAL COLORS =====
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // ===== UTILITY COLORS =====

  /// Light cyan for dropdown items
  static const Color lightCyan = Color(0xFFE0F7FA);

  /// Transparent colors with specific opacity
  static Color orangeSportWithOpacity(double opacity) =>
      orangeSport.withValues(alpha: opacity);

  static Color whiteWithOpacity(double opacity) =>
      white.withValues(alpha: opacity);

  static Color blackWithOpacity(double opacity) =>
      black.withValues(alpha: opacity);
}

