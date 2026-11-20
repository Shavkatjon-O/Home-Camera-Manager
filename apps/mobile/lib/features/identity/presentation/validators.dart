import 'package:smart_surveillance/app/l10n/l10n.dart';
final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? validateEmail(AppLocalizations l10n, String? value) =>
    value != null && emailPattern.hasMatch(value.trim()) ? null : l10n.validationEmail;

String? validatePassword(AppLocalizations l10n, String? value) =>
    value != null && value.length >= 8 ? null : l10n.validationPassword;

String? validateRequired(AppLocalizations l10n, String? value) =>
    value != null && value.trim().isNotEmpty ? null : l10n.validationRequired;

String? validateCode(AppLocalizations l10n, String? value) =>
    value != null && RegExp(r'^\d{6}$').hasMatch(value.trim()) ? null : l10n.validationCode;

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
