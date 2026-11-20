import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/alerting/presentation/labels.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
import 'package:smart_surveillance/features/tenancy/presentation/site_setup_screen.dart';

/// The settings of the current site, such as its name and how long events are kept.
class SiteSettingsScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SiteSettingsScreen({super.key});

  @override
  ConsumerState<SiteSettingsScreen> createState() => _SiteSettingsScreenState();
}

class _SiteSettingsScreenState extends ConsumerState<SiteSettingsScreen> {
  final name = TextEditingController();
  Site? draft;
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> save() async {
    final site = draft;
    if (site == null) return;
    setState(() => busy = true);
    try {
      await ref
          .read(backendProvider)
          .tenancy
          .updateSite(site.copyWith(name: name.text.trim().isEmpty ? site.name : name.text.trim()));
      ref.invalidate(allSitesProvider);
      if (mounted) showMessage(context, context.l10n.commonSaved);
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final current = ref.watch(currentSiteProvider).value;
    if (current == null) return const Scaffold();
    if (draft == null || draft!.id != current.site.id) {
      draft = current.site;
      name.text = current.site.name;
    }
    final site = draft!;
    const retention = [7, 14, 30, 60, 90];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.siteSettingsTitle)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, Gaps.md),
          child: BusyButton(label: l10n.commonSave, busy: busy, onPressed: save),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gaps.page, Gaps.sm, Gaps.page, Gaps.xxl),
        children: [
          TextField(
            controller: name,
            decoration: InputDecoration(labelText: l10n.fieldSiteName),
          ),
          const SizedBox(height: Gaps.lg),
          Text(l10n.fieldSiteKind, style: context.text.titleSmall?.copyWith(color: p.text2)),
          const SizedBox(height: Gaps.sm),
          SiteKindPicker(
            value: site.kind,
            onChanged: (kind) => setState(() => draft = site.copyWith(kind: kind)),
          ),
          const SizedBox(height: Gaps.lg),
          TimezoneField(
            value: site.timezone,
            onChanged: (zone) => setState(() => draft = site.copyWith(timezone: zone)),
          ),
          // The server keeps events for a fixed time, so only the simulated site offers a choice.
          if (ref.read(backendProvider).demo) ...[
            const SizedBox(height: Gaps.lg),
            Text(l10n.siteRetention, style: context.text.titleSmall?.copyWith(color: p.text2)),
            const SizedBox(height: Gaps.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final days in retention)
                  ChoiceChip(
                    label: Text(l10n.siteRetentionDays(days)),
                    selected: site.retentionDays == days,
                    onSelected: (_) => setState(() => draft = site.copyWith(retentionDays: days)),
                  ),
              ],
            ),
          ],
          const SizedBox(height: Gaps.xl),
          Panel(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(armIcon(site.armMode), color: p.text2),
                const SizedBox(width: Gaps.md),
                Expanded(
                  child: Text(
                    l10n.siteArmHelp,
                    style: context.text.bodyMedium?.copyWith(color: p.text2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
