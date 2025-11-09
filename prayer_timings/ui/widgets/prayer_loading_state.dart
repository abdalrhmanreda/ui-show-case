import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/colors/app_colors.dart';
import '../../../../core/components/progress_indector.dart';

class PrayerLoadingState extends StatelessWidget {
  const PrayerLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.kPrimaryColor.withOpacity(0.1),
                  AppColors.kPrimaryColor.withOpacity(0.3),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const CustomLoadingIndicator(),
          ),
          SizedBox(height: 24.h),
          Text(
            'جاري تحميل مواقيت الصلاة...',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.kPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
