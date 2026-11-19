// apps/course/presentations/widgets/course_placeholders.dart
import 'package:flutter/material.dart';
import '../../../../cores/widgets/app_shimmer.dart';

/// Wrap in [Shimmer] by the caller.
class CourseCardPlaceholder extends StatelessWidget {
  const CourseCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(child: ShimmerBox()),
      SizedBox(height: 10),
      ShimmerBox(height: 14),
      SizedBox(height: 6),
      Align(
        alignment: Alignment.centerLeft,
        child: ShimmerBox(width: 80, height: 12),
      ),
    ],
  );
}

class CourseTilePlaceholder extends StatelessWidget {
  const CourseTilePlaceholder({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 96,
    child: Row(
      children: [
        ShimmerBox(width: 96, height: 96),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerBox(height: 14),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ShimmerBox(width: 90, height: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
