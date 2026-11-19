// lib/cores/themes/colors.dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary: calm tosca
  static const primary = Color(0xFF2E9E9A);
  static const primaryDark = Color(0xFF1F7A77);
  static const primaryLight = Color(0xFFD6F0EE);

  // Accent: soft coral
  static const accent = Color(0xFFFF8A65);

  // Semantic
  static const secondary = Color(0xFF6C7A9C);
  static const error = Color(0xFFD64545);
  static const warning = Color(0xFFD98E04);
  static const info = Color(0xFF3B82C4);
  static const success = Color(0xFF2E9E6B);

  // Neutral
  static const background = Color(0xFFF6FAFA);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1B2B2B);
  static const textSecondary = Color(0xFF5E7070);
  static const border = Color(0xFFDDE8E8);

  // Shimmer
  static const shimmerBase = Color(0xFFE3ECEC);
  static const shimmerHighlight = Color(0xFFF5FAFA);
}
