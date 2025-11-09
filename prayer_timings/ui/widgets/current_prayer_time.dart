import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/colors/app_colors.dart';
import 'current_prayer_content.dart';

class CurrentPrayerStatusCard extends StatefulWidget {
  final String currentPrayer;
  final String remainingTime;
  final Animation<double> breathingAnimation;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const CurrentPrayerStatusCard({
    super.key,
    required this.currentPrayer,
    required this.remainingTime,
    required this.breathingAnimation,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  State<CurrentPrayerStatusCard> createState() =>
      _CurrentPrayerStatusCardState();
}

class _CurrentPrayerStatusCardState extends State<CurrentPrayerStatusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _mosqueController;
  late Animation<double> _mosqueAnimation;
  late Animation<double> _mosqueFloatAnimation;

  @override
  void initState() {
    super.initState();
    _initMosqueAnimation();
  }

  void _initMosqueAnimation() {
    _mosqueController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _mosqueAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mosqueController, curve: Curves.easeInOut),
    );

    _mosqueFloatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _mosqueController, curve: Curves.easeInOut),
    );

    _mosqueController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mosqueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: widget.breathingAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.breathingAnimation.value,
            child: SlideTransition(
              position: widget.slideAnimation,
              child: FadeTransition(
                opacity: widget.fadeAnimation,
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: _buildCardShadow(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: _buildPrimaryCardDecoration(),
                        child: Stack(
                          children: [
                            // Background Pattern
                            _buildBackgroundPattern(),

                            // Main Content
                            Padding(
                              padding: EdgeInsets.all(20.w),
                              child: CurrentPrayerContent(
                                currentPrayer: widget.currentPrayer,
                                remainingTime: widget.remainingTime,
                                mosqueAnimation: _mosqueAnimation,
                                mosqueFloatAnimation: _mosqueFloatAnimation,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildCardShadow() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24.r),
      boxShadow: [
        BoxShadow(
          color: AppColors.kPrimaryColor.withOpacity(0.35),
          blurRadius: 25,
          offset: const Offset(0, 12),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  BoxDecoration _buildPrimaryCardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.kPrimaryColor,
          AppColors.kPrimaryColor.withOpacity(0.9),
          AppColors.kPrimaryColor.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      borderRadius: BorderRadius.circular(24.r),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: IslamicPatternPainter(color: Colors.white.withOpacity(0.05)),
      ),
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  final Color color;

  IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw decorative Islamic patterns
    for (int i = 0; i < 3; i++) {
      final radius = 40.0 + (i * 25);
      final center = Offset(size.width - 40, size.height - 40);

      // Draw star pattern
      _drawStarPattern(canvas, center, radius, paint);
    }

    // Draw corner decorations
    _drawCornerDecoration(canvas, const Offset(20, 20), paint);
    _drawCornerDecoration(canvas, Offset(size.width - 20, 20), paint);
  }

  void _drawStarPattern(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    const points = 8;
    final path = Path();

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points);
      final r = i.isEven ? radius : radius * 0.5;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawCornerDecoration(Canvas canvas, Offset center, Paint paint) {
    canvas.drawCircle(center, 8, paint);
    canvas.drawCircle(center, 12, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
