part of 'prayer_cubit.dart';

@immutable
sealed class PrayerState {}

final class PrayerInitial extends PrayerState {}

class PrayerLoading extends PrayerState {}

class PrayerLoaded extends PrayerState {
  final PrayerTimes prayerModel;

  PrayerLoaded(this.prayerModel);
}

class PrayerError extends PrayerState {
  final String error;

  PrayerError(this.error);
}

class DaySeleceted extends PrayerState {
  final DateTime date;

  DaySeleceted(this.date);
}

class LocationPermissionGranted extends PrayerState {}

class LocationPermissionDenied extends PrayerState {
  final String message;

  LocationPermissionDenied(this.message);
}

class LocationServiceDisabled extends PrayerState {
  final String message;

  LocationServiceDisabled(this.message);
}

class LocationLoading extends PrayerState {}

class LocationLoaded extends PrayerState {
  final Position position;

  LocationLoaded(this.position);
}

class LocationError extends PrayerState {
  final String error;

  LocationError(this.error);
}

// States للتحكم في UI
class ShowLoadingDialog extends PrayerState {}

class HideLoadingDialog extends PrayerState {}

class ShowSuccessMessage extends PrayerState {}

class ShowDefaultLocationMessage extends PrayerState {}

class ShowLocationError extends PrayerState {
  final dynamic error;

  ShowLocationError({required this.error});
}

class ShowLocationServiceDialog extends PrayerState {}

class ShowPermissionDialog extends PrayerState {}

class ShowPermanentlyDeniedDialog extends PrayerState {}
