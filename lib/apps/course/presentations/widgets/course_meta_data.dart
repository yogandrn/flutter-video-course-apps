// apps/course/presentations/widgets/course_meta_data.dart
import 'package:flutter/material.dart';
import '../../../../cores/extensions/ext_double.dart';
import '../../../../cores/themes/colors.dart';
import '../../../../cores/themes/fontstyles.dart';

class RatingPill extends StatelessWidget {
  const RatingPill({super.key, required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
        const SizedBox(width: 4),
        Text(
          rating.ratingText,
          style: AppFontStyles.label.copyWith(color: AppColors.textPrimary),
        ),
      ],
    ),
  );
}

class AuthorLabel extends StatelessWidget {
  const AuthorLabel({super.key, required this.author});
  final String author;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        radius: 9,
        backgroundColor: AppColors.primaryLight,
        child: Text(
          author.isEmpty ? '?' : author[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
      ),
      const SizedBox(width: 6),
      Flexible(
        child: Text(
          author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFontStyles.bodySmall,
        ),
      ),
    ],
  );
}
