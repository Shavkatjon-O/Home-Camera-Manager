import 'package:flutter/widgets.dart';
import 'package:smart_surveillance/app/l10n/generated/app_localizations.dart';

export 'package:smart_surveillance/app/l10n/generated/app_localizations.dart';
/// Adds shortcut access to the app's translated strings.
extension L10nContext on BuildContext {
  /// The translated strings for the locale of this context.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
