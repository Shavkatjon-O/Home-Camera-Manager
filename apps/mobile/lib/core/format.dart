import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';

/// Formats times, dates, durations and numbers for the user's locale, relative to [now].
class Formats {
  /// Creates a formatter for the locale of [context], treating [now] as the current time.
  Formats(this.context, this.now);

  /// The context whose locale and translations are used.
  final BuildContext context;

  /// The moment treated as the present when describing relative times.
  final DateTime now;

  /// The language tag of the active locale, such as en or ru.
  String get locale => Localizations.localeOf(context).toLanguageTag();

  /// The translated strings of the active locale.
  AppLocalizations get l10n => context.l10n;

  /// Returns [at] as hours and minutes.
  String time(DateTime at) => DateFormat.Hm(locale).format(at);

  /// Returns [at] as hours, minutes and seconds.
  String timeSeconds(DateTime at) => DateFormat.Hms(locale).format(at);

  /// Returns [at] as a short date with the year.
  String date(DateTime at) => DateFormat.yMMMd(locale).format(at);

  /// Returns the short weekday name of [at].
  String weekday(DateTime at) => DateFormat.E(locale).format(at);

  /// Returns [at] as a short month and day.
  String dayMonth(DateTime at) => DateFormat.MMMd(locale).format(at);

  /// Returns the heading for a day group: Today, Yesterday or the full date of [at].
  String dayHeader(DateTime at) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    if (day == today) return l10n.commonToday;
    if (day == today.subtract(const Duration(days: 1))) return l10n.commonYesterday;
    return DateFormat.MMMMEEEEd(locale).format(at);
  }

  /// Returns the time of [at] when it is today, otherwise the day with the time.
  String when(DateTime at) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    if (day == today) return time(at);
    if (day == today.subtract(const Duration(days: 1))) {
      return '${l10n.commonYesterday}, ${time(at)}';
    }
    return '${dayMonth(at)}, ${time(at)}';
  }

  /// Returns how long before [now] [at] was, such as "5 minutes ago".
  String ago(DateTime at) {
    final delta = now.difference(at);
    if (delta.inSeconds < 45) return l10n.commonJustNow;
    if (delta.inMinutes < 60) return l10n.commonMinutesAgo(delta.inMinutes.clamp(1, 59));
    if (delta.inHours < 24) return l10n.commonHoursAgo(delta.inHours);
    return l10n.commonDaysAgo(delta.inDays);
  }

  /// Returns how long ago [at] was, written to start a line, as in Just now.
  String agoStart(DateTime at) {
    final text = ago(at);
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }

  /// Returns [value] as seconds, minutes and seconds, or hours and minutes, depending on its size.
  String duration(Duration value) {
    final seconds = value.inSeconds;
    if (seconds < 60) return l10n.commonSeconds(seconds);
    if (seconds < 3600) return l10n.commonMinutesSeconds(seconds ~/ 60, seconds % 60);
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return l10n.commonHoursMinutes(hours, minutes);
  }

  /// Returns [value] with [digits] decimal places and the locale's separators.
  String number(num value, {int digits = 0}) =>
      NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: digits).format(value);
}
