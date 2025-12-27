import 'package:flutter/material.dart';

/// Soft, blurred decorative background blob used for subtle gradients.
///
/// Implemented via large [BoxShadow] blur to avoid expensive image filters.
class AppDecorativeBlob extends StatelessWidget {
  final Alignment alignment;
  final double width;
  final double height;
  final Color color;
  final double opacity;
  final double blurRadius;

  const AppDecorativeBlob({
    super.key,
    required this.alignment,
    required this.width,
    required this.height,
    required this.color,
    this.opacity = 0.08,
    this.blurRadius = 80,
  });

  @override
  Widget build(BuildContext context) {
    final c = color.withValues(alpha: opacity);
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: c,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: c,
                blurRadius: blurRadius,
                spreadRadius: blurRadius / 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
