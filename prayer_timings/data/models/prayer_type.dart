class PrayerType {
  static const String fajr = 'fajr';
  static const String sunrise = 'sunrise';
  static const String dhuhr = 'dhuhr';
  static const String asr = 'asr';
  static const String maghrib = 'maghrib';
  static const String isha = 'isha';
  static const String ishaBefore = 'ishabefore';
  static const String fajrAfter = 'fajrafter';
  static const String none = 'none';
  static const String sehri = 'sehri';

  /// تحويل اسم الصلاة من إنجليزي إلى عربي
  String getArabicName(String type) {
    switch (type.toLowerCase()) {
      case fajr:
        return 'الفجر';
      case sunrise:
        return 'الشروق';
      case dhuhr:
        return 'الظهر';
      case asr:
        return 'العصر';
      case maghrib:
        return 'المغرب';
      case isha:
        return 'العشاء';
      case ishaBefore:
        return 'العشاء قبل منتصف الليل';
      case fajrAfter:
        return 'الفجر بعد منتصف الليل';
      case sehri:
        return 'السحور';
      case none:
      default:
        return 'غير محدد';
    }
  }

  int prayerOrder(String type) {
    switch (type.toLowerCase()) {
      case fajr:
        return 0;
      case sunrise:
        return 1;
      case dhuhr:
        return 2;
      case asr:
        return 3;
      case maghrib:
        return 4;
      case isha:
        return 5;
      case ishaBefore:
        return 6;
      case fajrAfter:
        return 7;
      case sehri:
        return 8;
      case none:
      default:
        return 9;
    }
  }
}
