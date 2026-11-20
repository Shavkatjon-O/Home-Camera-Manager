import 'package:smart_surveillance/app/l10n/l10n.dart';

/// The shape an email address must have.
final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Returns an error message when [value] is not an email address, otherwise null.
String? validateEmail(AppLocalizations l10n, String? value) =>
    value != null && emailPattern.hasMatch(value.trim()) ? null : l10n.validationEmail;

/// Returns an error message when [value] is shorter than eight characters, otherwise null.
String? validatePassword(AppLocalizations l10n, String? value) =>
    value != null && value.length >= 8 ? null : l10n.validationPassword;

/// Returns an error message when [value] is empty, otherwise null.
String? validateRequired(AppLocalizations l10n, String? value) =>
    value != null && value.trim().isNotEmpty ? null : l10n.validationRequired;

/// Returns an error message when [value] is not a six-digit code, otherwise null.
String? validateCode(AppLocalizations l10n, String? value) =>
    value != null && RegExp(r'^\d{6}$').hasMatch(value.trim()) ? null : l10n.validationCode;

/// Returns the strength of [value] from 0 (weak) to 2 (strong).
int passwordStrength(String value) {
  var score = 0;
  if (value.length >= 8) score++;
  if (value.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(value) && RegExp(r'[a-z]').hasMatch(value)) score++;
  if (RegExp(r'\d').hasMatch(value)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(value)) score++;
  if (value.length < 8) return 0;
  return score >= 4 ? 2 : (score >= 2 ? 1 : 0);
}
