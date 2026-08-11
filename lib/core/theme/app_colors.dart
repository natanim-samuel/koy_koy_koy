import 'package:flutter/material.dart';

/// Central color palette for the app.
///
/// Mirrors the dual-tone design used across the UI mockups:
/// - Dark teal canvas for forms / detail / auth screens.
/// - White canvas for data-dense screens (dashboard, lists, budget,
///   analytics, goals), with a dark teal "brand" card bridging the two.
/// - A fixed categorical palette so a given expense category always
///   renders in the same color everywhere in the app.
class AppColors {
  AppColors._();

  // ---- Dark-canvas palette ----
  static const Color bg = Color(0xFF10352E);
  static const Color bgDeep = Color(0xFF0A2620);
  static const Color card = Color(0xFF163D31);
  static const Color mint = Color(0xFF2FDCC0);
  static const Color mintDark = Color(0xFF154238);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color textOnDark = Color(0xFFF5F8F6);
  static const Color textOnDarkSecondary = Color(0xFF9FB8AE);
  static const Color textOnDarkMuted = Color(0xFF5C7A70);

  // ---- Light-canvas palette ----
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFF123028); // dark teal brand card
  static const Color textOnLight = Color(0xFF16332D);
  static const Color textOnLightSecondary = Color(0xFF7C948C);
  static const Color trackGray = Color(0xFFE7ECEA);

  // ---- Categorical accents ----
  static const Color catRed = Color(0xFFE14C4C); // Entertainment
  static const Color catTeal = Color(0xFF1FAE8E); // Food & Drinks
  static const Color catAmber = Color(0xFFF0A93A); // Transport
  static const Color catGreen = Color(0xFF2FDCC0); // Income
  static const Color catPurple = Color(0xFF8B6FE0); // Bills & Utilities / Shopping

  /// Maps a category's canonical name to its accent color.
  /// Falls back to [catTeal] for anything unrecognized so new
  /// categories never render invisibly.
  static Color forCategory(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'entertainment':
        return catRed;
      case 'food & drinks':
      case 'food and drinks':
      case 'groceries':
        return catTeal;
      case 'transport':
      case 'transportation':
      case 'fuel':
        return catAmber;
      case 'income':
      case 'salary':
      case 'freelance':
        return catGreen;
      case 'bills & utilities':
      case 'bills and utilities':
      case 'shopping':
        return catPurple;
      default:
        return catTeal;
    }
  }
}
