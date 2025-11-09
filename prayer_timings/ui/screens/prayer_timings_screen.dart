import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noon_islamic/features/prayer_timings/data/models/prayer_type.dart';
import 'package:noon_islamic/features/prayer_timings/logic/prayer_cubit.dart';

import '../../../../config/colors/app_colors.dart';
import '../widgets/current_prayer_time.dart';
import '../widgets/date_picker_prayer.dart';
import '../widgets/loading_location.dart';
import '../widgets/location_dailog.dart';
import '../widgets/permanently_denied_dialog.dart';
import '../widgets/permision_dailog.dart';
import '../widgets/prayer_floating_action.dart';
import '../widgets/prayer_loading_state.dart';
import '../widgets/prayer_sliver_app_bar.dart';
import '../widgets/prayer_timing_item.dart';
import '../widgets/prayer_timings_background.dart';

class PrayerTimingsScreen extends StatefulWidget {
  const PrayerTimingsScreen({super.key});

  @override
  State<PrayerTimingsScreen> createState() => _PrayerTimingsScreenState();
}

class _PrayerTimingsScreenState extends State<PrayerTimingsScreen>
    with TickerProviderStateMixin {
  DateTime selectedDate = DateTime.now();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _staggerController;
  late AnimationController _breathingController;
  late AnimationController _floatingController;
  late AnimationController _appBarController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _breathingAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _appBarAnimation;

  bool _isDatePickerExpanded = false;
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  bool _isLoadingDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _isInitialized = true;
        context.read<PrayerCubit>().getPrayerTimes(date: DateTime.now());
      }
    });
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _appBarController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOutCubic),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _breathingAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _appBarAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _appBarController, curve: Curves.linear));

    _breathingController.repeat(reverse: true);
    _floatingController.repeat(reverse: true);
    _appBarController.repeat();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
        _staggerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _staggerController.dispose();
    _breathingController.dispose();
    _floatingController.dispose();
    _appBarController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      selectedDate = date;
    });

    HapticFeedback.lightImpact();

    if (mounted) {
      context.read<PrayerCubit>().getPrayerTimes(date: selectedDate);

      _staggerController.reset();
      _staggerController.forward();
    }
  }

  void _toggleDatePicker() {
    setState(() {
      _isDatePickerExpanded = !_isDatePickerExpanded;
    });
    HapticFeedback.lightImpact();
  }

  // معالجة عرض Loading Dialog
  Future<void> _showLoadingDialog() async {
    if (_isLoadingDialogShowing || !mounted) return;

    _isLoadingDialogShowing = true;
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const LoadingLocationWigdet();
      },
    );
  }

  // معالجة إخفاء Loading Dialog
  Future<void> _hideLoadingDialog() async {
    if (!_isLoadingDialogShowing || !mounted) return;

    await Future.delayed(const Duration(milliseconds: 200));
    _isLoadingDialogShowing = false;

    if (!mounted) return;

    try {
      final rootNavigator = Navigator.of(context, rootNavigator: true);
      if (rootNavigator.canPop()) {
        rootNavigator.pop();
      }
    } catch (e) {
      try {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      } catch (e) {}
    }
  }

  // معالجة رسالة النجاح
  void _showSuccessSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'تم تحديث مواقيت الصلاة بنجاح',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 2),
      ),
    );

    HapticFeedback.lightImpact();
  }

  // معالجة رسالة الموقع الافتراضي
  void _showDefaultLocationSnackBar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'تم عرض مواقيت مكة المكرمة كقيم افتراضية',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'إعادة المحاولة',
          textColor: Colors.white,
          onPressed: () {
            context.read<PrayerCubit>().getPrayerTimes();
          },
        ),
      ),
    );
  }

  // معالجة رسالة الخطأ
  void _handleLocationError(dynamic error) {
    if (!mounted) return;

    String message = 'تم تحميل مواقيت افتراضية';
    Color color = Colors.blue[600]!;
    IconData icon = Icons.info_outline;

    if (error.toString().contains('disabled')) {
      message = 'تم استخدام مواقيت افتراضية - خدمات الموقع معطلة';
    } else if (error.toString().contains('denied')) {
      message = 'تم استخدام مواقيت افتراضية - إذن الموقع مرفوض';
    } else if (error.toString().contains('timeout')) {
      message = 'تم استخدام مواقيت افتراضية - انتهت مهلة الموقع';
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'إعادة المحاولة',
          textColor: Colors.white,
          onPressed: () {
            context.read<PrayerCubit>().getPrayerTimes();
          },
        ),
      ),
    );

    HapticFeedback.lightImpact();
  }

  // معالجة dialog خدمة الموقع
  Future<void> _showEnhancedLocationServiceDialog() async {
    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const EnhancedLocationDialog();
      },
    );
  }

  // معالجة dialog الصلاحيات
  Future<void> _showEnhancedPermissionDialog() async {
    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return const EnhancedPermissionDialog();
      },
    );
  }

  // معالجة dialog الرفض الدائم
  Future<void> _showPermanentlyDeniedDialog() async {
    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PermissionDialog(
        title: 'إذن الموقع مرفوض نهائياً',
        description:
            'لتفعيل مواقيت الصلاة الدقيقة، يرجى تفعيل إذن الموقع من الإعدادات',
        icon: Icons.location_disabled_rounded,
        iconBackground: Colors.red[50]!,
        iconColor: Colors.red[400]!,
        steps: const [
          'اذهب إلى إعدادات التطبيق',
          'اختر "الأذونات"',
          'فعّل إذن "الموقع"',
          'ارجع للتطبيق وحاول مرة أخرى',
        ],
        primaryButtonText: 'فتح الإعدادات',
        primaryButtonColor: Colors.red[400]!,
        onPrimaryButtonPressed: () async {
          Navigator.of(context).pop();
          await Geolocator.openAppSettings();
        },
        secondaryButtonText: 'استخدام مواقيت افتراضية',
        onSecondaryButtonPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PrayerCubit, PrayerState>(
      listener: (context, state) {
        if (!mounted) return;

        // معالجة جميع الـ UI Actions من خلال الـ Listener
        if (state is ShowLoadingDialog) {
          _showLoadingDialog();
        } else if (state is HideLoadingDialog) {
          _hideLoadingDialog();
        } else if (state is ShowSuccessMessage) {
          _showSuccessSnackBar();
        } else if (state is ShowDefaultLocationMessage) {
          _showDefaultLocationSnackBar();
        } else if (state is ShowLocationError) {
          _handleLocationError(state.error);
        } else if (state is ShowLocationServiceDialog) {
          _showEnhancedLocationServiceDialog();
        } else if (state is ShowPermissionDialog) {
          _showEnhancedPermissionDialog();
        } else if (state is ShowPermanentlyDeniedDialog) {
          _showPermanentlyDeniedDialog();
        } else if (state is PrayerLoaded) {
          _staggerController.forward();
        }
      },
      builder: (context, state) {
        final prayerTimes = context.read<PrayerCubit>().prayerTimes;
        final prayers = context.read<PrayerCubit>().prayers(context);

        return Scaffold(
          body: Container(
            decoration: _buildBackgroundDecoration(),
            child: Stack(
              children: [
                // Floating Islamic patterns
                FloatingIslamicPatterns(animation: _floatingAnimation),

                // Main content
                _buildMainContent(prayerTimes, prayers),

                // Floating action button
                PrayerFloatingActionButton(
                  floatingAnimation: _floatingAnimation,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    _onDateChanged(DateTime.now());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(prayerTimes, prayers) {
    if (prayerTimes == null) {
      return const PrayerLoadingState();
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Enhanced Custom Sliver App Bar
        PrayerSliverAppBar(
          selectedDate: selectedDate,
          appBarAnimation: _appBarAnimation,
          onSettingsPressed: () => HapticFeedback.lightImpact(),
        ),

        // Date Picker Section
        EnhancedDatePickerSection(
          selectedDate: selectedDate,
          isExpanded: _isDatePickerExpanded,
          onDateChanged: _onDateChanged,
          onToggleExpanded: _toggleDatePicker,
          slideAnimation: _slideAnimation,
          fadeAnimation: _fadeAnimation,
        ),

        // Current Prayer Status Card
        CurrentPrayerStatusCard(
          currentPrayer: PrayerType().getArabicName(
            context.read<PrayerCubit>().nextPrayer,
          ),
          remainingTime: _remainingTime(
            context.read<PrayerCubit>().getNextPrayerTime(
              PrayerType().prayerOrder(context.read<PrayerCubit>().nextPrayer),
            ),
          ),
          breathingAnimation: _breathingAnimation,
          slideAnimation: _slideAnimation,
          fadeAnimation: _fadeAnimation,
        ),

        // Prayer Times List
        _buildPrayerTimesList(prayers),

        // Bottom spacing
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }

  Widget _buildPrayerTimesList(prayers) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = Curves.easeOutCubic.transform(
                ((_staggerController.value - delay).clamp(0.0, 1.0) /
                        (1.0 - delay))
                    .clamp(0.0, 1.0),
              );

              return Transform.translate(
                offset: Offset(0, 50 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: PrayerTimingItem(
                      key: ValueKey('prayer_$index'),
                      index: index,
                    ),
                  ),
                ),
              );
            },
          );
        }, childCount: prayers?.length ?? 0),
      ),
    );
  }

  String _remainingTime(String timeString) {
    try {
      DateTime targetTime = DateTime.parse(timeString);
      DateTime now = DateTime.now();
      Duration difference = targetTime.difference(now);

      if (difference.isNegative) {
        Duration passed = difference.abs();
        return "مرّ ${passed.inHours} ساعة و ${passed.inMinutes % 60} دقيقة";
      } else {
        return "يتبقى ${difference.inHours} ساعة و ${difference.inMinutes % 60} دقيقة";
      }
    } catch (e) {
      return "تاريخ غير صالح";
    }
  }

  BoxDecoration _buildBackgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFF8F6F3),
          const Color(0xFFFAF9F6),
          AppColors.kPrimaryColor.withOpacity(0.02),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
    );
  }
}

class FloatingIslamicPatterns extends StatelessWidget {
  final Animation<double> animation;

  const FloatingIslamicPatterns({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: FloatingIslamicPatternsPainter(animation.value),
        );
      },
    );
  }
}
