import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/colors/app_colors.dart';

class PrayerFloatingActionButton extends StatelessWidget {
  final Animation<double> floatingAnimation;
  final VoidCallback onPressed;

  const PrayerFloatingActionButton({
    super.key,
    required this.floatingAnimation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30.h,
      right: 20.w,
      child: AnimatedBuilder(
        animation: floatingAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, floatingAnimation.value),
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.kPrimaryColor,
                      AppColors.kPrimaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.kPrimaryColor.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(Icons.today, color: Colors.white, size: 24.sp),
              ),
            ),
          );
        },
      ),
    );
  }
}
