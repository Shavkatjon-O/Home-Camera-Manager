import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/providers.dart';
import '../../core/theme/palette.dart';
import '../../core/theme/theme.dart';
import '../../l10n/l10n.dart';
import '../../widgets/logo.dart';
import '../../widgets/surfaces.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

void registerLicences() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(['Geist'], await rootBundle.loadString('assets/licenses/geist-ofl.txt'));
    yield LicenseEntryWithLineBreaks(['Lucide'], await rootBundle.loadString('assets/licenses/lucide-isc.txt'));
  });
}

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final p = context.palette;
    final info = ref.watch(packageInfoProvider).value;
    final config = ref.watch(configProvider);
    final backend = ref.watch(backendProvider);
    final version = info == null ? '' : '${info.version} (${info.buildNumber})';
    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Gaps.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.lg, Gaps.page, 0),
            child: Row(
              children: [
                const LogoMark(size: 56),
                const SizedBox(width: Gaps.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.appName, style: context.text.titleLarge),
                      Text(l10n.aboutVersion(version), style: dataStyle(context, size: 12.5, color: p.text2)),
                      Text(l10n.aboutBuild(config.flavor), style: dataStyle(context, size: 12.5, color: p.text3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gaps.xl),
          TileGroup(
            children: [
              ListTile(
                leading: const Icon(Icons.dns_outlined),
                title: Text(l10n.aboutServer),
                subtitle: Text(backend.demo ? l10n.serverDemo : (backend.server?.call() ?? '')),
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(l10n.aboutLicences),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appName,
                  applicationVersion: version,
                  applicationIcon: const Padding(padding: EdgeInsets.all(12), child: LogoMark(size: 48)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.page + 4, Gaps.xl, Gaps.page + 4, 0),
            child: Text(l10n.aboutPrivacy, style: context.text.bodySmall),
          ),
        ],
      ),
    );
  }
}
