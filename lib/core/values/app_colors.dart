import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFFC8F53C);        // lime 
  static const onPrimary = Color(0xFF14160F);      // text/icons on lime
  static const primaryDark = Color(0xFF3F4A12);    // secondary text on lime cards

  // Backgrounds and surfaces
  static const background = Color(0xFF17181D);
  static const surface = Color(0xFF23252D);        // cards, inputs
  static const surfaceHigh = Color(0xFF2C2F38);    // nav bar, sheets, secondary buttons
  static const border = Color(0xFF353844);
  static const bg_splash = Color(0xFF0D0D16);

  // Text
  static const textPrimary = Color(0xFFF4F5F7);
  static const textSecondary = Color(0xFFA3A9B8);
  static const textSoft = Color(0xFFC9CEDA);       // chips, body text

  // Feedback
  static const error = Color(0xFFFF9A90);
  static const warning = Color(0xFFFFD866);
  static const warningBg = Color(0xFF3A3217);
  static const success = Color(0xFF8BE0A4);
  static const successBg = Color(0xFF173A28);

  // Priority (background, text)
  static const urgentBg = Color(0xFF3D2121);
  static const urgentFg = Color(0xFFFF9A90);
  static const highBg = Color(0xFF3D2E18);
  static const highFg = Color(0xFFFFC078);
  static const mediumBg = Color(0xFF1E2B44);
  static const mediumFg = Color(0xFF9DBFFF);
  static const lowBg = Color(0xFF2F323C);
  static const lowFg = Color(0xFFC3C8D4);

  // transparent
  static const clear = Colors.transparent;

  static (Color bg, Color fg) priority(String p) => switch (p) {
        'urgent' => (urgentBg, urgentFg),
        'high' => (highBg, highFg),
        'low' => (lowBg, lowFg),
        _ => (mediumBg, mediumFg),
      };

  // Status colour (for dots, chips)
  static Color status(String s) => switch (s) {
        'in_progress' => mediumFg,
        'in_review' => highFg,
        'blocked' => urgentFg,
        'done' => success,
        'cancelled' => lowFg,
        _ => textSecondary, // todo
      };

  // Names used in the earlier code, kept so nothing breaks
  static const bg = background;
  static const card = surface;
  static const card2 = surfaceHigh;
  static const lime = primary;
  static const ink = onPrimary;
  static const muted = textSecondary;
  static const danger = error;
}