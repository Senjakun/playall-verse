import 'package:flutter/material.dart';

class AppColors {
  // Background
  static const background = Color(0xFF0A0A0A);
  static const surface = Color(0xFF141414);
  static const surfaceHover = Color(0xFF1F1F1F);
  static const card = Color(0xFF141414);

  // Primary - Vivid Red (matching web)
  static const primary = Color(0xFFF5392A);
  static const primaryDark = Color(0xFFD42E1C);
  static const primaryGlow = Color(0xFFFF5540);

  // Text
  static const textPrimary = Color(0xFFFAFAFA);
  static const textSecondary = Color(0xFFA3A3A3);
  static const textMuted = Color(0xFF737373);

  // Border
  static const border = Color(0xFF242424);
  static const borderLight = Color(0xFF2E2E2E);

  // Purple accent (for comments/badges)
  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFA78BFA);

  // Glass
  static const glassBg = Color(0x0DFFFFFF);
  static const glassBorder = Color(0x1AFFFFFF);

  // Gradients
  static const gradientBrand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5392A), Color(0xFFD42E1C)],
  );

  static const gradientCard = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1C1C1C), Color(0xFF141414)],
  );

  static const gradientHero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x26F5392A), Colors.transparent],
  );

  static const gradientOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xE60A0A0A)],
  );
}
