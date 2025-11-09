import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IslamicOrnament extends StatelessWidget {
  final Animation<double> animation;

  const IslamicOrnament({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.w,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.rotate(
              angle: animation.value * 0.5,
              child: Icon(Icons.mosque, color: Colors.white, size: 28.sp),
            );
          },
        ),
      ),
    );
  }
}

class LocationInfoCard extends StatelessWidget {
  final String? locationText;

  const LocationInfoCard({super.key, this.locationText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: Colors.white, size: 18.sp),
          SizedBox(width: 8.w),
          Text(
            locationText ?? 'القاهرة، مصر',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
