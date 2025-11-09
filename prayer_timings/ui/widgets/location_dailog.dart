import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';

class EnhancedLocationDialog extends StatelessWidget {
  const EnhancedLocationDialog({super.key});

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
            colors: [Colors.white, Colors.grey[50]!],
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
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Icon(
                Icons.location_off_rounded,
                size: 40.sp,
                color: Colors.orange[400],
              ),
            ),
            SizedBox(height: 20.h),

            // Title and Description
            Text(
              'خدمات الموقع معطلة',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'نحتاج إلى تفعيل خدمات الموقع لحساب مواقيت الصلاة بدقة حسب موقعك الحالي',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),

            // Steps
            _buildStep('1', 'اذهب إلى الإعدادات', Icons.settings),
            SizedBox(height: 8.h),
            _buildStep('2', 'فعّل خدمات الموقع', Icons.location_on),
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
                      ),
                    ),
                    child: Text(
                      'لاحقاً',
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
                      await Geolocator.openLocationSettings();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[600],
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'فتح الإعدادات',
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

  Widget _buildStep(String number, String text, IconData icon) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: Colors.orange[100],
          child: Text(
            number,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Icon(icon, size: 20.sp, color: Colors.orange[400]),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
