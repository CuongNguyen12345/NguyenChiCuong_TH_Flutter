import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String fullDate(DateTime dateTime) {
    return DateFormat('EEEE, MMM d').format(dateTime);
  }

  static String hourLabel(DateTime dateTime, {required bool use24HourFormat}) {
    return DateFormat(use24HourFormat ? 'HH:mm' : 'h a').format(dateTime);
  }

  static String dayLabel(DateTime dateTime) {
    return DateFormat('EEE').format(dateTime);
  }

  static String shortDate(DateTime dateTime) {
    return DateFormat('dd/MM').format(dateTime);
  }
}
