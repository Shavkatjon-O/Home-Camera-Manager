import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/domain/pairing_models.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';

/// Picks a recorder, signs in to it and adds the chosen channels as cameras.
class NvrImportScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const NvrImportScreen({super.key, required this.pairing, required this.session});

  /// The pairing context.
  final PairingContext pairing;

  /// The attempt being reported.
  final PairingSession session;

  @override
  ConsumerState<NvrImportScreen> createState() => _NvrImportScreenState();
}

class _NvrImportScreenState extends ConsumerState<NvrImportScreen> {
  late DiscoveredCamera? recorder = widget.pairing.discovered?.nvr == true ? widget.pairing.discovered : null;
  late final Future<List<DiscoveredCamera>> recorders = ref
      .read(backendProvider)
      .devices
      .discovered(widget.pairing.connector!.id)
      .then((list) => list.where((d) => d.nvr && d.cameraId == null).toList());
  final username = TextEditingController(text: 'admin');
  final password = TextEditingController();
  List<NvrChannel>? channels;
  final selected = <int>{};
  bool busy = false;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Iterable<int> get free => (channels ?? const <NvrChannel>[]).where((c) => c.online && c.cameraId == null).map((c) => c.index);

  Future<void> load() async {
    final nvr = recorder;
    if (nvr == null) return;
    widget.session.step('channels');
    setState(() => busy = true);
    try {
      final list = await ref
          .read(backendProvider)
          .pairing
          .nvrChannels(connectorId: widget.pairing.connector!.id, nvr: nvr, username: username.text.trim(), password: password.text);
      setState(() {
        channels = list;
        selected
          ..clear()
          ..addAll(free);
      });
    } catch (failure) {
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> add() async {
    final nvr = recorder;
    final list = channels;
    if (nvr == null || list == null || selected.isEmpty) return;
    widget.session.step('add');
    setState(() => busy = true);
    try {
      final cameras = await ref
          .read(backendProvider)
          .pairing
          .addChannels(
            siteId: widget.pairing.siteId,
            connectorId: widget.pairing.connector!.id,
            nvr: nvr,
            channels: list.where((c) => selected.contains(c.index)).toList(),
            username: username.text.trim(),
            password: password.text,
          );
      if (mounted) Navigator.of(context).pop(CamerasAdded(cameras));
    } catch (failure) {
      await widget.session.fail(failure);
      if (mounted) showFailure(context, failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget pickRecorder(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    widget.session.step('recorder');
    return Scaffold(
      appBar: AppBar(title: Text(l10n.nvrPick)),
      body: FutureBuilder<List<DiscoveredCamera>>(
        future: recorders,
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorState(error: snapshot.error!);
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          final found = snapshot.data!;
          if (found.isEmpty) return EmptyState(icon: Icons.dns_outlined, title: l10n.nvrNone, body: l10n.onboardingNoCamerasBody);
          return ListView(
            padding: const EdgeInsets.all(Gaps.page),
            children: [
              for (final item in found)
                Padding(
                  padding: const EdgeInsets.only(bottom: Gaps.sm),
                  child: Panel(
                    onTap: () => setState(() => recorder = item),
                    child: Row(
                      children: [
                        const IconBadge(icon: Icons.dns_outlined),
                        const SizedBox(width: Gaps.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text([item.manufacturer, item.model].whereType<String>().join(' '), style: context.text.titleMedium),
                              Text(item.host, style: dataStyle(context, size: 12, color: p.text3)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final nvr = recorder;
    final list = channels;
    if (nvr == null) return pickRecorder(context);
    widget.session.step(list == null ? 'login' : 'pick');
    return FlowScaffold(
      title: l10n.nvrTitle,
      subtitle: [nvr.manufacturer, nvr.model, nvr.host].whereType<String>().join(', '),
      bottom: list == null
          ? BusyButton(label: l10n.nvrLoad, busy: busy, onPressed: load)
          : BusyButton(label: l10n.nvrAdd(selected.length), busy: busy, onPressed: selected.isEmpty ? null : add),
      children: [
        if (list == null) ...[
          Text(l10n.nvrLogin, style: context.text.titleSmall?.copyWith(color: p.text2)),
          const SizedBox(height: Gaps.sm),
          TextField(controller: username, autocorrect: false, decoration: InputDecoration(labelText: l10n.fieldCameraUser)),
          const SizedBox(height: Gaps.md),
          PasswordField(controller: password, label: l10n.fieldCameraPassword, autofillHints: const []),
        ] else ...[
          Row(
            children: [
              Expanded(child: Text(l10n.nvrChannels, style: context.text.titleSmall?.copyWith(color: p.text2))),
              TextButton(
                onPressed: () => setState(() {
                  final available = free.toSet();
                  if (selected.containsAll(available)) {
                    selected.clear();
                  } else {
                    selected.addAll(available);
                  }
                }),
                child: Text(l10n.commonAll),
              ),
            ],
          ),
          TileGroup(
            margin: EdgeInsets.zero,
            children: [
              for (final channel in list)
                CheckboxListTile(
                  value: selected.contains(channel.index),
                  onChanged: channel.online && channel.cameraId == null
                      ? (on) => setState(() => on == true ? selected.add(channel.index) : selected.remove(channel.index))
                      : null,
                  title: Text(channel.name),
                  subtitle: channel.cameraId != null
                      ? Text(l10n.onboardingAdded)
                      : (channel.online ? null : Text(l10n.nvrOffline, style: TextStyle(color: p.dangerText))),
                  secondary: Text('${channel.index}', style: dataStyle(context, size: 13, color: p.text3)),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
