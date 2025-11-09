import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:noon_islamic/core/methods/get_responsive_text/responsive_text.dart';

import '../../../../../config/themes/font_weight.dart';

class CurrentPrayerContent extends StatelessWidget {
  final String currentPrayer;
  final String remainingTime;
  final Animation<double> mosqueAnimation;
  final Animation<double> mosqueFloatAnimation;

  const CurrentPrayerContent({
    super.key,
    required this.currentPrayer,
    required this.remainingTime,
    required this.mosqueAnimation,
    required this.mosqueFloatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Section
        PrayerHeaderSection(
          currentPrayer: currentPrayer,
          mosqueAnimation: mosqueAnimation,
          mosqueFloatAnimation: mosqueFloatAnimation,
        ),

        SizedBox(height: 12.h),

        // Divider
        const GradientDivider(),

        SizedBox(height: 12.h),

        // Remaining Time Section
        RemainingTimeIndicator(remainingTime: remainingTime),
      ],
    );
  }
}

class PrayerHeaderSection extends StatelessWidget {
  final String currentPrayer;
  final Animation<double> mosqueAnimation;
  final Animation<double> mosqueFloatAnimation;

  const PrayerHeaderSection({
    super.key,
    required this.currentPrayer,
    required this.mosqueAnimation,
    required this.mosqueFloatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon Container
        const PrayerTimeIconBadge(),

        SizedBox(width: 16.w),

        // Prayer Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الصلاة القادمة',
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context, fontSize: 13),
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeightHelper.medium,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                currentPrayer,
                style: TextStyle(
                  fontSize: getResponsiveFontSize(context, fontSize: 20),
                  color: Colors.white,
                  fontWeight: FontWeightHelper.bold,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Animated Mosque Icon
        AnimatedMosqueIcon(
          mosqueAnimation: mosqueAnimation,
          mosqueFloatAnimation: mosqueFloatAnimation,
        ),
      ],
    );
  }
}

class PrayerTimeIconBadge extends StatelessWidget {
  const PrayerTimeIconBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.access_time_rounded,
        color: Colors.white,
        size: 25,
      ),
    );
  }
}

class AnimatedMosqueIcon extends StatelessWidget {
  final Animation<double> mosqueAnimation;
  final Animation<double> mosqueFloatAnimation;

  const AnimatedMosqueIcon({
    super.key,
    required this.mosqueAnimation,
    required this.mosqueFloatAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mosqueAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, mosqueFloatAnimation.value),
          child: Transform.scale(
            scale: 1.0 + (mosqueAnimation.value * 0.1),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.15),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.mosque_rounded,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
        );
      },
    );
  }
}

class GradientDivider extends StatelessWidget {
  const GradientDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class RemainingTimeIndicator extends StatelessWidget {
  final String remainingTime;

  const RemainingTimeIndicator({super.key, required this.remainingTime});

  @override
  Widget build(BuildContext context) {
    // Parse time if it's in "HH:MM:SS" format
    final timeParts = remainingTime.split(':');
    final hasMultipleParts = timeParts.length > 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.2),
            Colors.white.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Timer Icon
          const TimerIconBadge(),

          SizedBox(width: 12.w),

          // Time Display
          if (hasMultipleParts)
            _buildTimeSegments(context, timeParts)
          else
            _buildSimpleTime(context, remainingTime),
        ],
      ),
    );
  }

  Widget _buildTimeSegments(BuildContext context, List<String> timeParts) {
    return Row(
      children: [
        TimeSegment(value: timeParts[0], label: 'ساعة'),
        if (timeParts.length > 1) ...[
          _buildTimeSeparator(context),
          TimeSegment(value: timeParts[1], label: 'دقيقة'),
        ],
        if (timeParts.length > 2) ...[
          _buildTimeSeparator(context),
          TimeSegment(value: timeParts[2], label: 'ثانية'),
        ],
      ],
    );
  }

  Widget _buildTimeSeparator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: getResponsiveFontSize(context, fontSize: 20),
          color: Colors.white.withOpacity(0.7),
          fontWeight: FontWeightHelper.bold,
        ),
      ),
    );
  }

  Widget _buildSimpleTime(BuildContext context, String time) {
    return Text(
      'باقي $time',
      style: TextStyle(
        fontSize: getResponsiveFontSize(context, fontSize: 15),
        color: Colors.white,
        fontWeight: FontWeightHelper.semiBold,
        letterSpacing: 0.5,
      ),
    );
  }
}

class TimeSegment extends StatelessWidget {
  final String value;
  final String label;

  const TimeSegment({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, fontSize: 24),
            color: Colors.white,
            fontWeight: FontWeightHelper.bold,
            letterSpacing: 1,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: getResponsiveFontSize(context, fontSize: 10),
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeightHelper.medium,
          ),
        ),
      ],
    );
  }
}

class TimerIconBadge extends StatelessWidget {
  const TimerIconBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.timer_rounded, color: Colors.white, size: 24),
    );
  }
}
