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
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/analytics/domain/models.dart';
import 'package:smart_surveillance/features/analytics/domain/presets.dart';
import 'package:smart_surveillance/features/analytics/presentation/analytics_screens.dart';
import 'package:smart_surveillance/features/analytics/presentation/labels.dart';
import 'package:smart_surveillance/features/analytics/presentation/providers.dart';

/// The icon of [preset].
IconData presetIcon(AnalyticsPreset preset) => switch (preset) {
  AnalyticsPreset.perimeter => Icons.fence_outlined,
  AnalyticsPreset.entrance => Icons.door_front_door_outlined,
  AnalyticsPreset.counting => Icons.people_alt_outlined,
  AnalyticsPreset.tamperOnly => Icons.visibility_off_outlined,
};

/// Offers the analytics presets for a newly added camera.
class AnalyticsPresetScreen extends ConsumerStatefulWidget {
  /// Creates the screen for [cameraId] on [siteId].
  const AnalyticsPresetScreen({
    super.key,
    required this.siteId,
    required this.cameraId,
    this.first = false,
  });

  /// The site of the camera.
  final String siteId;

  /// The camera whose views get the preset.
  final String cameraId;

  /// Whether this is part of the first setup flow.
  final bool first;

  @override
  ConsumerState<AnalyticsPresetScreen> createState() => _AnalyticsPresetScreenState();
}

class _AnalyticsPresetScreenState extends ConsumerState<AnalyticsPresetScreen> {
  AnalyticsPreset preset = AnalyticsPreset.perimeter;
  bool busy = false;

  Future<void> apply(List<AnalyticsView> views) async {
    final l10n = context.l10n;
    final analytics = ref.read(backendProvider).analytics;
    setState(() => busy = true);
    try {
      for (final view in views) {
        final plan = presetPlan(
          preset,
          view,
          zoneName: l10n.presetZoneName,
          lineName: l10n.presetLineName,
        );
        await analytics.updateView(plan.view);
        await analytics.saveRules(view.id, zones: plan.zones, lines: plan.lines);
      }
      ref.invalidate(viewsProvider(widget.siteId));
      if (mounted) next();
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void next() {
    final prefs = ref.read(preferencesProvider);
    if (widget.first && !prefs.onboardedNotifications) {
      const OnboardingNotificationsRoute().pushReplacement(context);
    } else if (widget.first) {
      const OnboardingDoneRoute().pushReplacement(context);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final views = (ref.watch(viewsProvider(widget.siteId)).value ?? const <AnalyticsView>[])
        .where((v) => v.cameraId == widget.cameraId)
        .toList();
    final camera = views.isEmpty ? '' : views.first.cameraName;
    return FlowScaffold(
      title: l10n.onboardingAnalyticsTitle,
      subtitle: l10n.onboardingAnalyticsBody(camera),
      step: widget.first ? l10n.onboardingStep(4, 4) : null,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BusyButton(
            label: l10n.commonApply,
            busy: busy,
            onPressed: views.isEmpty ? null : () => apply(views),
          ),
          TextButton(onPressed: busy ? null : next, child: Text(l10n.commonSkip)),
        ],
      ),
      children: [
        if (views.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: Gaps.lg),
            child: ViewThumb(view: views.first, rules: false),
          ),
        RadioGroup<AnalyticsPreset>(
          groupValue: preset,
          onChanged: (value) => setState(() => preset = value ?? preset),
          child: Column(
            children: [
              for (final option in AnalyticsPreset.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: Gaps.sm),
                  child: Panel(
                    padding: EdgeInsets.zero,
                    color: preset == option ? p.surface2 : null,
                    child: RadioListTile<AnalyticsPreset>(
                      value: option,
                      title: Text(l10n.preset(option), style: context.text.titleMedium),
                      subtitle: Text(l10n.presetBody(option)),
                      secondary: Icon(presetIcon(option)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
