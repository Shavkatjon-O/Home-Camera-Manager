import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/features/identity/presentation/validators.dart';

/// Runs the validator tests.
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('validateEmail', () {
    test('accepts an address', () {
      expect(validateEmail(l10n, 'owner@example.com'), isNull);
      expect(validateEmail(l10n, '  owner@example.com  '), isNull);
    });

    test('rejects malformed values', () {
      for (final value in [null, '', 'owner', 'owner@', '@example.com', 'a b@example.com']) {
        expect(validateEmail(l10n, value), l10n.validationEmail, reason: '$value');
      }
    });
  });

  group('validatePassword', () {
    test('needs eight characters', () {
      expect(validatePassword(l10n, '12345678'), isNull);
      expect(validatePassword(l10n, '1234567'), l10n.validationPassword);
      expect(validatePassword(l10n, null), l10n.validationPassword);
    });
  });

  group('validateRequired', () {
    test('rejects blank values', () {
      expect(validateRequired(l10n, 'x'), isNull);
      expect(validateRequired(l10n, '   '), l10n.validationRequired);
      expect(validateRequired(l10n, null), l10n.validationRequired);
    });
  });

  group('validateCode', () {
    test('needs six digits', () {
      expect(validateCode(l10n, '123456'), isNull);
      expect(validateCode(l10n, ' 123456 '), isNull);
      expect(validateCode(l10n, '12345'), l10n.validationCode);
      expect(validateCode(l10n, '12345a'), l10n.validationCode);
      expect(validateCode(l10n, null), l10n.validationCode);
    });
  });

  group('passwordStrength', () {
    test('scores short passwords as weak', () {
      expect(passwordStrength(''), 0);
      expect(passwordStrength('Ab1!'), 0);
    });

    test('scores middling passwords', () {
      expect(passwordStrength('abcdefgh'), 0);
      expect(passwordStrength('abcdefg1'), 1);
      expect(passwordStrength('Abcdefgh'), 1);
    });

    test('scores long mixed passwords as strong', () {
      expect(passwordStrength('Abcdefg1'), 1);
      expect(passwordStrength('Abcdefg1!'), 2);
      expect(passwordStrength('Correct-Horse-9'), 2);
    });
  });
}
