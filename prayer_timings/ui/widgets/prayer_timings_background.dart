// Custom Painters remain the same...
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../config/colors/app_colors.dart';

class FloatingIslamicPatternsPainter extends CustomPainter {
  final double animationValue;

  FloatingIslamicPatternsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.kPrimaryColor.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x =
          (size.width * (i * 0.15)) + (sin(animationValue * 0.02 + i) * 30);
      final y =
          (size.height * (i * 0.12)) + (cos(animationValue * 0.02 + i) * 20);

      _drawIslamicStar(canvas, Offset(x, y), 15 + (i * 2), paint);
    }
  }

  void _drawIslamicStar(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final path = Path();
    const points = 8;

    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * pi) / points;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class IslamicAppBarPatternPainter extends CustomPainter {
  final double animationValue;

  IslamicAppBarPatternPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final centerX = size.width - 80;
    const centerY = 80;
    const radius = 40.0;

    for (int layer = 0; layer < 3; layer++) {
      final layerRadius = radius - (layer * 12);
      final path = Path();

      for (int i = 0; i < 8; i++) {
        final angle = (i * 2 * pi) / 8 + (animationValue * 0.1) + (layer * 0.2);
        final x = centerX + layerRadius * cos(angle);
        final y = centerY + layerRadius * sin(angle);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
    }

    paint.strokeWidth = 0.5;
    for (int i = 0; i < 8; i++) {
      final angle = (i * 2 * pi) / 8 + (animationValue * 0.1);
      final x1 = centerX + radius * cos(angle);
      final y1 = centerY + radius * sin(angle);
      final x2 = centerX + (radius - 24) * cos(angle);
      final y2 = centerY + (radius - 24) * sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
