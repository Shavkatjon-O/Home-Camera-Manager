import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
class Formats {
  Formats(this.context, this.now);

  final BuildContext context;
  final DateTime now;

  String get locale => Localizations.localeOf(context).toLanguageTag();

  AppLocalizations get l10n => context.l10n;

  String time(DateTime at) => DateFormat.Hm(locale).format(at);

  String timeSeconds(DateTime at) => DateFormat.Hms(locale).format(at);

  String date(DateTime at) => DateFormat.yMMMd(locale).format(at);

  String weekday(DateTime at) => DateFormat.E(locale).format(at);

  String dayMonth(DateTime at) => DateFormat.MMMd(locale).format(at);

  String dayHeader(DateTime at) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    if (day == today) return l10n.commonToday;
    if (day == today.subtract(const Duration(days: 1))) return l10n.commonYesterday;
    return DateFormat.MMMMEEEEd(locale).format(at);
  }

  String when(DateTime at) {
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    if (day == today) return time(at);
    if (day == today.subtract(const Duration(days: 1))) return '${l10n.commonYesterday}, ${time(at)}';
    return '${dayMonth(at)}, ${time(at)}';
  }

  String ago(DateTime at) {
    final delta = now.difference(at);
    if (delta.inSeconds < 45) return l10n.commonJustNow;
    if (delta.inMinutes < 60) return l10n.commonMinutesAgo(delta.inMinutes.clamp(1, 59));
    if (delta.inHours < 24) return l10n.commonHoursAgo(delta.inHours);
    return l10n.commonDaysAgo(delta.inDays);
  }

  String duration(Duration value) {
    final seconds = value.inSeconds;
    if (seconds < 60) return l10n.commonSeconds(seconds);
    if (seconds < 3600) return l10n.commonMinutesSeconds(seconds ~/ 60, seconds % 60);
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return l10n.commonHoursMinutes(hours, minutes);
  }

  String number(num value, {int digits = 0}) =>
      NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: digits).format(value);
}
