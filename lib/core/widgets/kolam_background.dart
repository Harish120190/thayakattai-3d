import 'dart:math';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class KolamBackground extends StatelessWidget {
  final Widget child;

  const KolamBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.2),
              radius: 1.2,
              colors: [
                Color(0xFF172033),
                Color(0xFF0F1524),
                AppColors.background,
              ],
            ),
          ),
        ),
        // Subtle decorative Kolam pattern overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _KolamPatternPainter(),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class _KolamPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    // Draw traditional grid of subtle dots & connecting lines in corner zones
    const step = 40.0;
    for (double x = 20; x < size.width; x += step) {
      for (double y = 20; y < size.height; y += step) {
        final distFromCenter =
            sqrt(pow(x - size.width / 2, 2) + pow(y - size.height / 2, 2));
        if (distFromCenter > 150) {
          canvas.drawCircle(Offset(x, y), 1.2, dotPaint);
        }
      }
    }

    // Sacred central concentric subtle circles
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 120, paint);
    canvas.drawCircle(center, 180, paint);
    canvas.drawCircle(center, 240, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
