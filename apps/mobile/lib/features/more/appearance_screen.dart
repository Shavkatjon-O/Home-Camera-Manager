import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/surfaces.dart';

const languageNames = {'en': 'English', 'ru': '\u0420\u0443\u0441\u0441\u043A\u0438\u0439', 'uz': 'O\u02BBzbekcha'};

String languageName(String code) => languageNames[code] ?? code;

Future<void> showLanguageSheet(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
  context: context,
  builder: (context) => Consumer(
    builder: (context, ref, _) {
      final current = ref.watch(appearanceSettingsProvider).locale?.languageCode;
      final l10n = context.l10n;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Gaps.page + 4, 0, Gaps.page, Gaps.sm),
              child: Text(l10n.appearanceLanguage, style: context.text.titleLarge),
            ),
            RadioGroup<String?>(
              groupValue: current,
              onChanged: (value) {
                ref.read(appearanceSettingsProvider.notifier).setLocale(value == null ? null : Locale(value));
                Navigator.of(context).pop();
              },
              child: Column(
                children: [
                  RadioListTile<String?>(value: null, title: Text(l10n.appearanceSystem)),
                  for (final code in AppLocalizations.supportedLocales.map((l) => l.languageCode))
                    RadioListTile<String?>(value: code, title: Text(languageName(code))),
                ],
              ),
            ),
            const SizedBox(height: Gaps.md),
          ],
        ),
      );
    },
  ),
);

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final settings = ref.watch(appearanceSettingsProvider);
    final notifier = ref.read(appearanceSettingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appearanceTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Gaps.xxl),
        children: [
          SectionHeader(l10n.appearanceTheme, padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, Gaps.sm)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.page),
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: ThemeMode.system, label: Text(l10n.themeSystem), icon: const Icon(Icons.brightness_auto_outlined, size: 18)),
                ButtonSegment(value: ThemeMode.light, label: Text(l10n.themeLight), icon: const Icon(Icons.light_mode_outlined, size: 18)),
                ButtonSegment(value: ThemeMode.dark, label: Text(l10n.themeDark), icon: const Icon(Icons.dark_mode_outlined, size: 18)),
              ],
              selected: {settings.theme},
              onSelectionChanged: (value) => notifier.setTheme(value.first),
            ),
          ),
          SectionHeader(l10n.appearanceLanguage),
          TileGroup(
            children: [
              RadioGroup<String?>(
                groupValue: settings.locale?.languageCode,
                onChanged: (value) => notifier.setLocale(value == null ? null : Locale(value)),
                child: Column(
                  children: [
                    RadioListTile<String?>(value: null, title: Text(l10n.appearanceSystem)),
                    for (final code in AppLocalizations.supportedLocales.map((l) => l.languageCode))
                      RadioListTile<String?>(value: code, title: Text(languageName(code))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
