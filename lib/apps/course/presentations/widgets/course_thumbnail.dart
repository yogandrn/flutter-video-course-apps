// apps/course/presentations/widgets/course_thumbnail.dart
import 'package:flutter/material.dart';
import '../../../../cores/themes/colors.dart';
import '../../../../cores/widgets/app_shimmer.dart';

class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({
    super.key,
    required this.url,
    required this.heroTag,
    this.radius = 12,
  });
  final String url;
  final String heroTag;
  final double radius;

  @override
  Widget build(BuildContext context) => Hero(
    tag: heroTag,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const Shimmer(child: ShimmerBox(radius: 0)),
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: AppColors.primaryLight,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    ),
  );
}
