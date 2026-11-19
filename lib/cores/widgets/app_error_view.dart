// lib/cores/widgets/app_error_view.dart
import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../themes/fontstyles.dart';
import 'app_button.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: AppColors.error.withValues(alpha: 0.8)),
          const SizedBox(height: 16),
          const Text('Oops, something went wrong', style: AppFontStyles.h3),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppFontStyles.bodySmall,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            AppButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    ),
  );
}
