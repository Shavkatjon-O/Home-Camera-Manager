import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/alerting/domain/models.dart';
import 'package:smart_surveillance/features/alerting/presentation/labels.dart';
import 'package:smart_surveillance/features/tenancy/domain/models.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
/// A card that shows and changes the arm mode of a site.
class ArmControl extends ConsumerStatefulWidget {
  /// Creates the control for [site].
  const ArmControl({super.key, required this.site});

  /// The site whose arm mode is controlled.
  final SiteContext site;

  @override
  ConsumerState<ArmControl> createState() => _ArmControlState();
}

class _ArmControlState extends ConsumerState<ArmControl> {
  ArmMode? pending;
  ArmMode? local;

  @override
  void didUpdateWidget(ArmControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.site.site.id != widget.site.site.id) local = null;
  }

  Future<void> change(ArmMode mode) async {
    final l10n = context.l10n;
    setState(() => pending = mode);
    try {
      await ref.read(backendProvider).tenancy.setArmMode(widget.site.site.id, mode);
      if (!mounted) return;
      setState(() => local = mode);
      ref.invalidate(allSitesProvider);
      showMessage(context, l10n.armChanged(l10n.arm(mode).toLowerCase()));
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => pending = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final mode = pending ?? local ?? widget.site.site.armMode;
    final allowed = widget.site.can(Role.operator);
    final armed = mode == ArmMode.away;
    return Panel(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: armed ? p.error.withValues(alpha: 0.14) : p.surface2,
                  borderRadius: BorderRadius.circular(Radii.medium),
                  border: Border.all(color: armed ? p.error.withValues(alpha: 0.4) : p.border),
                ),
                child: Icon(armIcon(mode), size: 19, color: armed ? p.dangerText : p.text),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.armTitle, style: context.text.labelMedium),
                    Text(l10n.arm(mode), style: context.text.titleMedium),
                  ],
                ),
              ),
              if (pending != null) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ArmMode>(
              showSelectedIcon: false,
              segments: [
                for (final value in ArmMode.values)
                  ButtonSegment(
                    value: value,
                    label: Text(l10n.arm(value), maxLines: 1, overflow: TextOverflow.ellipsis),
                    tooltip: l10n.armBody(value),
                  ),
              ],
              selected: {mode},
              onSelectionChanged: allowed && pending == null ? (value) => change(value.first) : null,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            allowed ? l10n.armBody(mode) : l10n.commonPermissionNeeded,
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}
