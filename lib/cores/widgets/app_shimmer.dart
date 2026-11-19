// lib/cores/widgets/app_shimmer.dart
import 'package:flutter/material.dart';
import '../themes/colors.dart';

/// Wrap any group of [ShimmerBox]es. One animation drives all children.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});
  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (_, child) => ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (rect) => LinearGradient(
        // slide a highlight band from left of the box to right of it
        begin: Alignment(-2 + 3 * _c.value, 0),
        end: Alignment(-1 + 3 * _c.value, 0),
        colors: const [
          AppColors.shimmerBase,
          AppColors.shimmerHighlight,
          AppColors.shimmerBase,
        ],
      ).createShader(rect),
      child: child,
    ),
  );
}

/// Placeholder block. Must stay white: [Shimmer] paints over its pixels.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.width, this.height, this.radius = 12});
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
