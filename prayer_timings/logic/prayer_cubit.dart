import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:noon_islamic/core/helpers/location_helper.dart';
import 'package:noon_islamic/gen/locale_keys.g.dart';
import 'package:prayers_times/prayers_times.dart';

import '../../../core/helpers/local_notify.dart';
import '../../../generated/assets.dart';
import '../data/models/prayer_timing_model.dart';

part 'prayer_state.dart';

class PrayerCubit extends Cubit<PrayerState> {
  PrayerCubit() : super(PrayerInitial()) {
    startWatcher();
  }

  DateTime currentDate = DateTime.now();
  String? address;
  PrayerTimes? prayerTimes;
  Timer? _prayerCheckTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Position? _lastKnownPosition;
  var nextPrayer;

  int get currentDay => currentDate.day;
  int get currentYear => currentDate.year;
  int get currentMonth => currentDate.month;

  void selectDay(int day) {
    currentDate = DateTime(currentDate.year, currentDate.month, day);
    emit(DaySeleceted(currentDate));
  }

  Future<void> getPrayerTimes({DateTime? date}) async {
    emit(PrayerLoading());
    emit(ShowLoadingDialog()); // طلب عرض الـ dialog

    try {
      Position? position = await CurrentLocationHandler().getCurrentLocation();

      // Get address
      address = await placemarkFromCoordinates(
        position!.latitude,
        position.longitude,
      ).then((placemarks) {
        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          return [

            if (placemark.administrativeArea != null)
              placemark.administrativeArea,
            if (placemark.country != null) placemark.country,
          ].whereType<String>().join(', ');
        }
        return 'Unknown location';
      }).catchError((e) {
        return 'Unknown location';
      });

      // Calculate prayer times
      PrayerCalculationParameters params =
          PrayerCalculationMethod.muslimWorldLeague();
      final coordinates = Coordinates(position.latitude, position.longitude);
      String timezoneId = _getTimezoneIdentifier(
        position.latitude,
        position.longitude,
      );

      prayerTimes = PrayerTimes(
        coordinates: coordinates,
        calculationParameters: params,
        precision: true,
        locationName: timezoneId,
        dateTime: date ?? DateTime.now(),
      );
      nextPrayer = prayerTimes?.nextPrayer();
      
      emit(HideLoadingDialog()); // طلب إخفاء الـ dialog
      
      if (!isClosed) {
        emit(PrayerLoaded(prayerTimes!));
        emit(ShowSuccessMessage()); // طلب عرض رسالة النجاح
      }

      startWatcher();
    } catch (e) {
      emit(HideLoadingDialog());
      
      if (!isClosed) {
        await _loadDefaultPrayerTimes();
        emit(ShowLocationError(error: e)); // طلب عرض رسالة الخطأ
      }
    }
  }

  Future<void> _loadDefaultPrayerTimes() async {
    try {
      const double defaultLatitude = 21.4241;
      const double defaultLongitude = 39.8173;

      PrayerCalculationParameters params =
          PrayerCalculationMethod.muslimWorldLeague();
      final coordinates = Coordinates(defaultLatitude, defaultLongitude);

      prayerTimes = PrayerTimes(
        coordinates: coordinates,
        dateTime: DateTime.now(),
        calculationParameters: params,
        locationName: 'Asia/Riyadh',
      );
      nextPrayer = prayerTimes!.nextPrayer();

      if (!isClosed) {
        emit(PrayerLoaded(prayerTimes!));
        emit(ShowDefaultLocationMessage()); // طلب عرض رسالة الموقع الافتراضي
      }

      startWatcher();
    } catch (e) {
      if (!isClosed) {
        emit(PrayerError('فشل في تحميل المواقيت الافتراضية'));
      }
    }
  }

  String getNextPrayerTime(int index) {
    if (prayerTimes == null) return '';
    
    try {
      DateTime? time;
      
      switch (index) {
        case 0:
          time = prayerTimes!.fajrStartTime;
          break;
        case 1:
          time = prayerTimes!.sunrise;
          break;
        case 2:
          time = prayerTimes!.dhuhrStartTime;
          break;
        case 3:
          time = prayerTimes!.asrStartTime;
          break;
        case 4:
          time = prayerTimes!.maghribStartTime;
          break;
        case 5:
          time = prayerTimes!.ishaStartTime;
          break;
        default:
          return '';
      }
      
      return time?.toIso8601String() ?? '';
    } catch (e) {
      print('Error getting prayer time at index $index: $e');
      return '';
    }
  }

  /// الحصول على الوقت المتبقي للصلاة القادمة
  String getRemainingTimeForNextPrayer() {
    if (prayerTimes == null || nextPrayer == null) {
      return "غير متاح";
    }

    try {
      DateTime? nextPrayerTime;
      
      switch (nextPrayer.toString()) {
        case 'Prayer.fajr':
          nextPrayerTime = prayerTimes!.fajrStartTime;
          break;
        case 'Prayer.sunrise':
          nextPrayerTime = prayerTimes!.sunrise;
          break;
        case 'Prayer.dhuhr':
          nextPrayerTime = prayerTimes!.dhuhrStartTime;
          break;
        case 'Prayer.asr':
          nextPrayerTime = prayerTimes!.asrStartTime;
          break;
        case 'Prayer.maghrib':
          nextPrayerTime = prayerTimes!.maghribStartTime;
          break;
        case 'Prayer.isha':
          nextPrayerTime = prayerTimes!.ishaStartTime;
          break;
        default:
          return "غير متاح";
      }

      if (nextPrayerTime == null) {
        return "غير متاح";
      }

      DateTime now = DateTime.now();
      Duration difference = nextPrayerTime.difference(now);

      if (difference.isNegative) {
        Duration passed = difference.abs();
        int hours = passed.inHours;
        int minutes = passed.inMinutes % 60;
        
        if (hours > 0) {
          return "مرّ ${hours} ساعة و ${minutes} دقيقة";
        } else {
          return "مرّ ${minutes} دقيقة";
        }
      } else {
        int hours = difference.inHours;
        int minutes = difference.inMinutes % 60;
        
        if (hours > 0) {
          return "يتبقى ${hours} ساعة و ${minutes} دقيقة";
        } else if (minutes > 0) {
          return "يتبقى ${minutes} دقيقة";
        } else {
          return "الآن";
        }
      }
    } catch (e) {
      print('Error calculating remaining time: $e');
      return "غير متاح";
    }
  }

  String _getTimezoneIdentifier(double latitude, double longitude) {
    try {
      // Egypt timezones
      if (latitude >= 22.0 &&
          latitude <= 32.0 &&
          longitude >= 25.0 &&
          longitude <= 36.0) {
        return 'Africa/Cairo';
      }

      // Saudi Arabia
      if (latitude >= 16.0 &&
          latitude <= 32.0 &&
          longitude >= 34.0 &&
          longitude <= 56.0) {
        return 'Asia/Riyadh';
      }

      // UAE
      if (latitude >= 22.0 &&
          latitude <= 26.5 &&
          longitude >= 51.0 &&
          longitude <= 57.0) {
        return 'Asia/Dubai';
      }

      // Kuwait
      if (latitude >= 28.5 &&
          latitude <= 30.5 &&
          longitude >= 46.5 &&
          longitude <= 49.0) {
        return 'Asia/Kuwait';
      }

      // Qatar
      if (latitude >= 24.5 &&
          latitude <= 26.5 &&
          longitude >= 50.5 &&
          longitude <= 52.0) {
        return 'Asia/Qatar';
      }

      return 'UTC';
    } catch (e) {
      return 'UTC';
    }
  }

  Future<Position> getLocationWithEnhancedFlow() async {
    emit(LocationLoading());

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(LocationServiceDisabled('Location services are disabled'));
      emit(ShowLocationServiceDialog()); // طلب عرض dialog خدمة الموقع
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(LocationPermissionDenied('Location permissions are denied'));
        emit(ShowPermissionDialog()); // طلب عرض dialog الصلاحيات
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(
        LocationPermissionDenied('Location permissions are permanently denied'),
      );
      emit(ShowPermanentlyDeniedDialog()); // طلب عرض dialog الرفض الدائم
      throw Exception('Location permissions are permanently denied');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
      _lastKnownPosition = position;
      emit(LocationLoaded(position));
      return position;
    } catch (e) {
      if (_lastKnownPosition != null) {
        emit(LocationLoaded(_lastKnownPosition!));
        return _lastKnownPosition!;
      }

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 15),
        );
        _lastKnownPosition = position;
        emit(LocationLoaded(position));
        return position;
      } catch (e) {
        emit(LocationError('Failed to get location: $e'));
        rethrow;
      }
    }
  }

  List<PrayerTimingModel> prayers(BuildContext context) => [
        PrayerTimingModel(
          img: Assets.prayerTimingsFajr,
          prayerName: LocaleKeys.fajr.tr(),
        ),
        PrayerTimingModel(
          img: Assets.prayerTimingsSunset,
          prayerName: LocaleKeys.shuruq.tr(),
        ),
        PrayerTimingModel(
          img: Assets.prayerTimingsDhuhr,
          prayerName: LocaleKeys.dhuhr.tr(),
        ),
        PrayerTimingModel(
          img: Assets.prayerTimingsAsr,
          prayerName: LocaleKeys.asr.tr(),
        ),
        PrayerTimingModel(
          img: Assets.prayerTimingsSunset,
          prayerName: LocaleKeys.maghrib.tr(),
        ),
        PrayerTimingModel(
          img: Assets.prayerTimingsAsha,
          prayerName: LocaleKeys.isha.tr(),
        ),
      ];

  DateTime? _lastNotifiedTime;

  Future<void> playAdhanIfNowIsPrayerTime() async {
    if (prayerTimes == null) return;

    final now = DateTime.now();
    final prayerMap = {
      'fajr': prayerTimes!.fajrStartTime,
      'sunrise': prayerTimes!.sunrise,
      'dhuhr': prayerTimes!.dhuhrStartTime,
      'asr': prayerTimes!.asrStartTime,
      'maghrib': prayerTimes!.maghribStartTime,
      'isha': prayerTimes!.ishaStartTime,
    };

    for (final entry in prayerMap.entries) {
      final prayerTime = entry.value;
      if (prayerTime == null) continue;

      final difference = now.difference(prayerTime).inSeconds;

      // تحقق أن الوقت الحالي يطابق الصلاة بالثواني (±30 ثانية)
      if (difference.abs() <= 30) {
        // تأكد إنه لم يتم إرسال إشعار لنفس الصلاة قبل قليل
        if (_lastNotifiedTime != null &&
            now.difference(_lastNotifiedTime!).inMinutes < 1) {
          return;
        }

        _lastNotifiedTime = now;

        final prayerName = _getPrayerNameInArabic(entry.key);

        try {
          // إرسال إشعار فوري بدلاً من مجدول لأن الوقت الآن
          await NotificationService().sendAdhanNotificationNow(
            title: 'حان وقت الصلاة 🕌',
            body: 'حان الآن موعد صلاة $prayerName. بارك الله فيك',
          );
          
          print('✅ Adhan notification sent for $prayerName');
        } catch (e) {
          print('❌ Error sending adhan notification: $e');
        }

        break;
      }
    }
  }

  /// جدولة إشعارات الأذان لجميع الصلوات في اليوم الحالي
  Future<void> scheduleAllPrayerNotifications() async {
    if (prayerTimes == null) return;

    final now = DateTime.now();
    final prayerMap = {
      'fajr': prayerTimes!.fajrStartTime,
      'dhuhr': prayerTimes!.dhuhrStartTime,
      'asr': prayerTimes!.asrStartTime,
      'maghrib': prayerTimes!.maghribStartTime,
      'isha': prayerTimes!.ishaStartTime,
    };

    for (final entry in prayerMap.entries) {
      final prayerTime = entry.value;
      if (prayerTime == null) continue;

      // جدولة فقط للصلوات القادمة
      if (prayerTime.isAfter(now)) {
        final prayerName = _getPrayerNameInArabic(entry.key);

        try {
          await NotificationService().scheduleAdhanNotification(
            title: 'حان وقت الصلاة 🕌',
            body: 'حان الآن موعد صلاة $prayerName. بارك الله فيك',
            scheduleTime: prayerTime,
          );
          
          print('✅ Scheduled notification for $prayerName at $prayerTime');
        } catch (e) {
          print('❌ Error scheduling notification for $prayerName: $e');
        }
      }
    }
  }

  String _getPrayerNameInArabic(String key) {
    switch (key) {
      case 'fajr':
        return 'الفجر';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return 'الصلاة';
    }
  }

  void startWatcher() {
    _prayerCheckTimer?.cancel();

    _prayerCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await playAdhanIfNowIsPrayerTime();
    });

    playAdhanIfNowIsPrayerTime();
  }

  @override
  Future<void> close() {
    _prayerCheckTimer?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}