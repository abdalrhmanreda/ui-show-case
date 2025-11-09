import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:noon_islamic/config/colors/app_colors.dart';
import 'package:noon_islamic/features/prayer_timings/logic/prayer_cubit.dart';

import '../widgets/prayer_timings_background.dart';
import 'islamic_ornament.dart';

class PrayerSliverAppBar extends StatelessWidget {
  final DateTime selectedDate;
  final Animation<double> appBarAnimation;
  final VoidCallback? onSettingsPressed;

  const PrayerSliverAppBar({
    super.key,
    required this.selectedDate,
    required this.appBarAnimation,
    this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final expandRatio =
              (constraints.maxHeight - kToolbarHeight) /
              (200.h - kToolbarHeight);

          return FlexibleSpaceBar(
            background: Stack(
              children: [
                // Gradient Background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.kPrimaryColor,
                        AppColors.kPrimaryColor.withOpacity(0.8),
                        AppColors.kPrimaryColor.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),

                // Animated Islamic Pattern
                AnimatedBuilder(
                  animation: appBarAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size.infinite,
                      painter: IslamicAppBarPatternPainter(
                        appBarAnimation.value,
                      ),
                    );
                  },
                ),

                // Content
                Positioned.fill(
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),

                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Title and Date
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'مواقيت الصلاة',
                                      style: TextStyle(
                                        fontSize: 24.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(
                                              0.3,
                                            ),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      _formatDate(selectedDate),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Islamic Ornament
                              IslamicOrnament(animation: appBarAnimation),
                            ],
                          ),

                          SizedBox(height: 24.h),

                          // Location and Info
                          if (expandRatio > 0.3) ...[
                            LocationInfoCard(
                              locationText: context.read<PrayerCubit>().address,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // Glassmorphism overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),

      // Leading icon
      leading: CustomAppBarButton(
        icon: Icons.arrow_back_ios,
        onPressed: () => Navigator.of(context).pop(),
      ),

      // Actions
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    const days = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName، ${date.day} $monthName ${date.year}';
  }
}

class CustomAppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const CustomAppBarButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20.sp),
        onPressed: onPressed,
      ),
    );
  }
}
