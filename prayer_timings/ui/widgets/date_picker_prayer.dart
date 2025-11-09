import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/colors/app_colors.dart';

class EnhancedDatePickerSection extends StatefulWidget {
  final DateTime selectedDate;
  final bool isExpanded;
  final Function(DateTime) onDateChanged;
  final VoidCallback onToggleExpanded;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;

  const EnhancedDatePickerSection({
    super.key,
    required this.selectedDate,
    required this.isExpanded,
    required this.onDateChanged,
    required this.onToggleExpanded,
    required this.slideAnimation,
    required this.fadeAnimation,
  });

  @override
  State<EnhancedDatePickerSection> createState() =>
      _EnhancedDatePickerSectionState();
}

class _EnhancedDatePickerSectionState extends State<EnhancedDatePickerSection> {
  late DatePickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DatePickerController();

    // بعد ما يتبني الويجت، ننتقل مباشرة لليوم الحالي
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpToSelection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: widget.slideAnimation,
        child: FadeTransition(
          opacity: widget.fadeAnimation,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: _buildCardDecoration(),
            child: Column(
              children: [
                DatePickerHeader(
                  isExpanded: widget.isExpanded,
                  onToggle: widget.onToggleExpanded,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  height: widget.isExpanded ? 140.h : 110.h,
                  child: CustomDatePicker(
                    controller: _controller,
                    selectedDate: widget.selectedDate,
                    isExpanded: widget.isExpanded,
                    onDateChanged: widget.onDateChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        const BoxShadow(
          color: Colors.white,
          blurRadius: 10,
          offset: Offset(0, -2),
        ),
      ],
      border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
    );
  }
}

class DatePickerHeader extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const DatePickerHeader({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختر التاريخ',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kPrimaryColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'اسحب لتغيير التاريخ',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.expand_more,
                  color: AppColors.kPrimaryColor,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomDatePicker extends StatelessWidget {
  final DatePickerController controller;
  final DateTime selectedDate;
  final bool isExpanded;
  final Function(DateTime) onDateChanged;

  const CustomDatePicker({
    super.key,
    required this.controller,
    required this.selectedDate,
    required this.isExpanded,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: DatePicker(
        DateTime.now().subtract(const Duration(days: 30)),
        controller: controller,
        locale: 'ar',
        height: isExpanded ? 120.h : 95.h,
        width: 65.w,
        daysCount: 60,
        calendarType: CalendarType.gregorianDate,
        initialSelectedDate: selectedDate,

        // ✅ يركّز على اليوم الحالي
        selectionColor: AppColors.kPrimaryColor,
        selectedTextColor: Colors.white,
        deactivatedColor: Colors.grey.withOpacity(0.3),
        dateTextStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
        dayTextStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
        monthTextStyle: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
        onDateChange: onDateChanged,
      ),
    );
  }
}
