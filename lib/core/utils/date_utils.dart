import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _fullDateFormat = DateFormat('EEEE, dd MMMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');

  static String formatDisplayDate(DateTime? date) {
    if (date == null) return '';
    return _displayDateFormat.format(date);
  }

  static String formatFullDate(DateTime? date) {
    if (date == null) return '';
    return _fullDateFormat.format(date);
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return '';
    return _shortDateFormat.format(date);
  }

  static String formatTime(DateTime? date) {
    if (date == null) return '';
    return _timeFormat.format(date);
  }

  static String formatDateTimeCombined(DateTime date, String? timeString) {
    final dateStr = formatDisplayDate(date);
    if (timeString != null && timeString.trim().isNotEmpty) {
      return '$dateStr • $timeString';
    }
    return dateStr;
  }
}
