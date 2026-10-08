import 'package:intl/intl.dart';

abstract final class DateHelper {
  static final _dayFmt = DateFormat('d MMM');
  static final _monthFmt = DateFormat('d MMM yyyy');
  static final _headerFmt = DateFormat('EEEE, d MMM');

  static String format(DateTime date) {
    final now = DateTime.now();
    final today = _normalize(now);
    final d = _normalize(date);
    final diff = d.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (date.year == now.year) return _dayFmt.format(date);
    return _monthFmt.format(date);
  }

  static String headerDate(DateTime date) => _headerFmt.format(date);

  static String taskDue(DateTime date) => _dayFmt.format(date);

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  static TaskGroup groupFor(DateTime due) {
    final now = DateTime.now();
    final today = _normalize(now);
    final d = _normalize(due);
    final diff = d.difference(today).inDays;

    if (diff < 0) return TaskGroup.overdue;
    if (diff == 0) return TaskGroup.today;
    if (diff == 1) return TaskGroup.tomorrow;
    if (diff <= 7) return TaskGroup.thisWeek;
    return TaskGroup.later;
  }
}

enum TaskGroup { overdue, today, tomorrow, thisWeek, later }
