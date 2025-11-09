import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final List<String>? steps;
  final String primaryButtonText;
  final VoidCallback? onPrimaryButtonPressed;
  final String secondaryButtonText;
  final VoidCallback? onSecondaryButtonPressed;
  final Color primaryButtonColor;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    this.steps,
    required this.primaryButtonText,
    this.onPrimaryButtonPressed,
    required this.secondaryButtonText,
    this.onSecondaryButtonPressed,
    required this.primaryButtonColor,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Icon(icon, size: 40.sp, color: iconColor),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12.h),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (steps != null) ...[
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: steps!
                      .asMap()
                      .entries
                      .map(
                        (entry) =>
                            _buildManualStep('${entry.key + 1}', entry.value),
                      )
                      .toList(),
                ),
              ),
            ],
            SizedBox(height: 24.h),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onSecondaryButtonPressed,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      secondaryButtonText,
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
                    onPressed: onPrimaryButtonPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryButtonColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      primaryButtonText,
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

  Widget _buildManualStep(String stepNumber, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Text(
            '$stepNumber.',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
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
