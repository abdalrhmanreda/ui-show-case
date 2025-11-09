import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../config/colors/app_colors.dart';

class EnhancedPermissionDialog extends StatelessWidget {
  const EnhancedPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColors.kPrimaryColor.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.kPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Icon(
                Icons.location_searching_rounded,
                size: 40.sp,
                color: AppColors.kPrimaryColor,
              ),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              'إذن الوصول للموقع',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),

            // Description
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.kPrimaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.kPrimaryColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 24.sp,
                    color: AppColors.kPrimaryColor,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'نحتاج للوصول إلى موقعك لحساب مواقيت الصلاة الدقيقة حسب منطقتك الجغرافية',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[700],
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Benefits
            _buildBenefitItem('مواقيت دقيقة حسب موقعك', Icons.access_time),
            _buildBenefitItem(
              'تنبيهات في الوقت المناسب',
              Icons.notifications_active,
            ),
            _buildBenefitItem('حساب اتجاه القبلة', Icons.explore),
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'ليس الآن',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await Geolocator.requestPermission();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kPrimaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'منح الإذن',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.kPrimaryColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
