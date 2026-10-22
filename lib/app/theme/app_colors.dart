import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background & Surfaces
  static const Color background = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF131926);
  static const Color surfaceElevated = Color(0xFF1C2538);
  static const Color surfaceBorder = Color(0xFF2E3A52);

  // Royal Indian Accent Colors
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF3D279);
  static const Color goldDark = Color(0xFF9E7C1D);

  static const Color crimson = Color(0xFF9E1B32);
  static const Color crimsonLight = Color(0xFFCF284A);

  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);

  static const Color sapphire = Color(0xFF3B82F6);
  static const Color sapphireLight = Color(0xFF60A5FA);

  static const Color ivory = Color(0xFFF8F9FA);
  static const Color textMuted = Color(0xFF94A3B8);

  // Player Marker Colors (up to 8 players)
  static const List<Color> playerColors = [
    Color(0xFFE11D48), // P0: Royal Crimson
    Color(0xFFF59E0B), // P1: Imperial Amber
    Color(0xFF10B981), // P2: Temple Emerald
    Color(0xFF3B82F6), // P3: Sacred Sapphire
    Color(0xFFA855F7), // P4: Divine Amethyst
    Color(0xFFEA580C), // P5: Sunset Saffron
    Color(0xFF06B6D4), // P6: Jewel Peacock
    Color(0xFF854D0E), // P7: Antique Bronze
  ];

  static Color getPlayerColor(int playerIndex) {
    return playerColors[playerIndex % playerColors.length];
  }
}
