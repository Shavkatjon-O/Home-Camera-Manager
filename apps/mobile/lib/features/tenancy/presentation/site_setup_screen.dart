import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/identity/presentation/validators.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
import 'package:smart_surveillance/features/tenancy/presentation/labels.dart';

/// The time zones offered for a site, most likely first for the first market.
const timezones = [
  'Asia/Tashkent',
  'Asia/Samarkand',
  'Asia/Almaty',
  'Asia/Bishkek',
  'Asia/Dushanbe',
  'Asia/Ashgabat',
  'Asia/Baku',
  'Asia/Tbilisi',
  'Asia/Yerevan',
  'Asia/Dubai',
  'Asia/Karachi',
  'Asia/Kolkata',
  'Asia/Bangkok',
  'Asia/Shanghai',
  'Asia/Seoul',
  'Asia/Tokyo',
  'Europe/Moscow',
  'Europe/Istanbul',
  'Europe/Kyiv',
  'Europe/Berlin',
  'Europe/Paris',
  'Europe/London',
  'Africa/Cairo',
  'America/New_York',
  'America/Chicago',
  'America/Los_Angeles',
  'America/Sao_Paulo',
  'Australia/Sydney',
  'UTC',
];

/// Guesses a time zone from the phone's offset at [now].
String guessTimezone(DateTime now) {
  final hours = now.timeZoneOffset.inMinutes / 60;
  final byOffset = {
    5.0: 'Asia/Tashkent',
    6.0: 'Asia/Almaty',
    4.0: 'Asia/Dubai',
    3.0: 'Europe/Moscow',
    2.0: 'Europe/Kyiv',
    1.0: 'Europe/Berlin',
    0.0: 'Europe/London',
    8.0: 'Asia/Shanghai',
    9.0: 'Asia/Tokyo',
    5.5: 'Asia/Kolkata',
    -5.0: 'America/New_York',
    -8.0: 'America/Los_Angeles',
  };
  return byOffset[hours] ?? 'UTC';
}

/// A grid of the site kinds.
class SiteKindPicker extends StatelessWidget {
  /// Creates the picker.
  const SiteKindPicker({super.key, required this.value, required this.onChanged});

  /// The selected kind.
  final SiteKind value;

  /// Called with the kind the user picks.
  final ValueChanged<SiteKind> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.25,
      children: [
        for (final kind in SiteKind.values)
          Semantics(
            selected: value == kind,
            button: true,
            child: Material(
              color: value == kind ? p.surface3 : p.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.medium),
                side: BorderSide(
                  color: value == kind ? p.text : p.borderInput,
                  width: value == kind ? 1.5 : 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(Radii.medium),
                onTap: () => onChanged(kind),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(siteKindIcon(kind), color: value == kind ? p.text : p.text2),
                    const SizedBox(height: 6),
                    Text(
                      l10n.siteKind(kind),
                      style: context.text.labelMedium?.copyWith(
                        color: value == kind ? p.text : p.text2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A drop down of [timezones].
class TimezoneField extends StatelessWidget {
  /// Creates the field.
  const TimezoneField({super.key, required this.value, required this.onChanged});

  /// The selected time zone.
  final String value;

  /// Called with the zone the user picks.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final zones = timezones.contains(value) ? timezones : [value, ...timezones];
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.fieldTimezone,
        prefixIcon: const Icon(Icons.public_rounded),
      ),
      borderRadius: BorderRadius.circular(Radii.medium),
      menuMaxHeight: 420,
      items: [
        for (final zone in zones)
          DropdownMenuItem(value: zone, child: Text(zone.replaceAll('_', ' '))),
      ],
      onChanged: (zone) {
        if (zone != null) onChanged(zone);
      },
    );
  }
}

/// Creates the organisation and the first site, or another site.
class SiteSetupScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const SiteSetupScreen({super.key, this.first = true});

  /// Whether this starts the first setup flow.
  final bool first;

  @override
  ConsumerState<SiteSetupScreen> createState() => _SiteSetupScreenState();
}

class _SiteSetupScreenState extends ConsumerState<SiteSetupScreen> {
  final form = GlobalKey<FormState>();
  final organisation = TextEditingController();
  final name = TextEditingController();
  SiteKind kind = SiteKind.home;
  late String timezone = guessTimezone(ref.read(clockProvider)());
  String? organisationId;
  bool busy = false;

  @override
  void dispose() {
    organisation.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> submit(List<Organisation> organisations) async {
    if (!form.currentState!.validate()) return;
    final tenancy = ref.read(backendProvider).tenancy;
    setState(() => busy = true);
    try {
      var orgId =
          organisationId ?? organisations.where((o) => o.role.atLeast(Role.admin)).firstOrNull?.id;
      if (orgId == null) {
        final created = await tenancy.createOrganisation(organisation.text.trim());
        orgId = created.id;
      }
      final site = await tenancy.createSite(
        organisationId: orgId,
        name: name.text.trim(),
        kind: kind,
        timezone: timezone,
      );
      await ref.read(selectedSiteProvider.notifier).select(site.id);
      ref.invalidate(organisationsProvider);
      ref.invalidate(allSitesProvider);
      if (!mounted) return;
      OnboardingConnectorRoute(siteId: site.id, first: true).go(context);
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
    final organisations = ref.watch(organisationsProvider).value ?? const <Organisation>[];
    final adminOf = organisations.where((o) => o.role.atLeast(Role.admin)).toList();
    return FlowScaffold(
      title: l10n.onboardingSiteTitle,
      subtitle: l10n.onboardingSiteBody,
      step: l10n.onboardingStep(1, 4),
      showBack: !widget.first || Navigator.of(context).canPop(),
      actions: [
        if (widget.first && organisations.isEmpty)
          TextButton(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            child: Text(l10n.moreSignOut, style: TextStyle(color: p.text2)),
          ),
      ],
      bottom: BusyButton(
        label: l10n.commonContinue,
        busy: busy,
        onPressed: () => submit(organisations),
      ),
      children: [
        Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (adminOf.isEmpty) ...[
                TextFormField(
                  controller: organisation,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: l10n.fieldOrganisation,
                    hintText: l10n.fieldOrganisationHint,
                  ),
                  validator: (value) => validateRequired(l10n, value),
                ),
                const SizedBox(height: Gaps.md),
              ] else if (adminOf.length > 1) ...[
                DropdownButtonFormField<String>(
                  initialValue: organisationId ?? adminOf.first.id,
                  decoration: InputDecoration(labelText: l10n.moreOrganisation),
                  items: [
                    for (final o in adminOf) DropdownMenuItem(value: o.id, child: Text(o.name)),
                  ],
                  onChanged: (value) => setState(() => organisationId = value),
                ),
                const SizedBox(height: Gaps.md),
              ],
              TextFormField(
                controller: name,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.fieldSiteName,
                  hintText: l10n.fieldSiteNameHint,
                ),
                validator: (value) => validateRequired(l10n, value),
              ),
              const SizedBox(height: Gaps.lg),
              Text(l10n.fieldSiteKind, style: context.text.titleSmall?.copyWith(color: p.text2)),
              const SizedBox(height: Gaps.sm),
              SiteKindPicker(value: kind, onChanged: (value) => setState(() => kind = value)),
              const SizedBox(height: Gaps.lg),
              TimezoneField(
                value: timezone,
                onChanged: (value) => setState(() => timezone = value),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
