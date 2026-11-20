import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
class FacesScreen extends ConsumerStatefulWidget {
  const FacesScreen({super.key});

  @override
  ConsumerState<FacesScreen> createState() => _FacesScreenState();
}

class _FacesScreenState extends ConsumerState<FacesScreen> {
  bool busy = false;

  Future<void> change(Organisation organisation, bool enabled) async {
    final l10n = context.l10n;
    final tenancy = ref.read(backendProvider).tenancy;
    String? version;
    if (enabled) {
      final consent = await tenancy.facesConsent();
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.face_outlined),
          title: Text(l10n.facesConsentTitle),
          content: SingleChildScrollView(child: Text(consent.text ?? l10n.facesConsentBody)),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.facesConsentConfirm)),
          ],
        ),
      );
      if (ok != true) return;
      version = consent.version;
    }
    setState(() => busy = true);
    try {
      await tenancy.setFaces(organisation.id, enabled, consentVersion: version);
      ref.invalidate(organisationsProvider);
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
    final site = ref.watch(currentSiteProvider).value;
    if (site == null) return const Scaffold();
    final organisation = site.organisation;
    final allowed = site.can(Role.admin);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.facesTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Gaps.xxl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Gaps.page, 0, Gaps.page, Gaps.lg),
            child: Text(l10n.facesBody, style: context.text.bodyMedium?.copyWith(color: p.text2)),
          ),
          TileGroup(
            children: [
              SwitchListTile(
                secondary: Icon(
                  organisation.facesEnabled ? Icons.face_retouching_natural_outlined : Icons.face_retouching_off_outlined,
                ),
                title: Text(organisation.name),
                subtitle: Text(
                  allowed ? (organisation.facesEnabled ? l10n.facesEnabled : l10n.facesDisabled) : l10n.facesOwnerOnly,
                ),
                value: organisation.facesEnabled,
                onChanged: allowed && !busy ? (value) => change(organisation, value) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
