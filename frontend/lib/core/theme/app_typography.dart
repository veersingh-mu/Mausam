import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// IMD "Mausam Precision" Typography Tokens
class AppTypography {
  static TextStyle displayTemp = GoogleFonts.inter(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    height: 72 / 64,
    letterSpacing: -1.2,
    color: AppColors.primaryContainer,
  );

  static TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSm = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: AppColors.onSurface,
  );

  static TextStyle titleMd = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    color: AppColors.onSurface,
  );

  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28 / 18,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle labelCaps = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    letterSpacing: 0.6,
    color: AppColors.outline,
  );

  static TextStyle dataMono = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: -0.2,
    color: AppColors.primaryContainer,
  );

  /// Scales any text style modestly depending on the active breakpoint
  /// (+4% on Medium tablet, +10% on Expanded desktop)
  static TextStyle scaled(BuildContext context, TextStyle baseStyle) {
    final width = MediaQuery.of(context).size.width;
    double factor = 1.0;
    if (width > 1024) {
      factor = 1.10;
    } else if (width >= 600) {
      factor = 1.04;
    }
    if (factor == 1.0 || baseStyle.fontSize == null) return baseStyle;
    return baseStyle.copyWith(fontSize: baseStyle.fontSize! * factor);
  }
