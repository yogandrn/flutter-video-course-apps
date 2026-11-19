// lib/cores/widgets/app_alert.dart
import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../themes/fontstyles.dart';

enum AlertType { success, error, warning, info }

abstract final class AppAlert {
  static void show(
    BuildContext context,
    String message, {
    AlertType type = AlertType.info,
  }) {
    final color = switch (type) {
      AlertType.success => AppColors.success,
      AlertType.error => AppColors.error,
      AlertType.warning => AppColors.warning,
      AlertType.info => AppColors.info,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppFontStyles.body.copyWith(color: Colors.white),
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}
