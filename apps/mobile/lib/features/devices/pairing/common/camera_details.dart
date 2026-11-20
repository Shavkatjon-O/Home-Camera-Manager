import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/widgets/failure_labels.dart';
import 'package:smart_surveillance/core/widgets/flow_scaffold.dart';
import 'package:smart_surveillance/core/widgets/media_view.dart';
import 'package:smart_surveillance/core/widgets/surfaces.dart';
import 'package:smart_surveillance/features/devices/domain/models.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_method.dart';
import 'package:smart_surveillance/features/identity/presentation/validators.dart';

/// The last step of adding one camera: login, stream test, name and lenses.
class CameraDetailsScreen extends ConsumerStatefulWidget {
  /// Creates the step for [camera].
  const CameraDetailsScreen({
    super.key,
    required this.pairing,
    required this.session,
    required this.camera,
    this.needsLogin = true,
    this.initialUser,
    this.initialPassword,
  });

  /// The pairing context.
  final PairingContext pairing;

  /// The attempt being reported.
  final PairingSession session;

  /// The camera to add.
  final DiscoveredCamera camera;

  /// Whether to ask for the camera's login.
  final bool needsLogin;

  /// A username to prefill.
  final String? initialUser;

  /// A password to prefill.
  final String? initialPassword;

  @override
  ConsumerState<CameraDetailsScreen> createState() => _CameraDetailsScreenState();
}

class _CameraDetailsScreenState extends ConsumerState<CameraDetailsScreen> {
  final form = GlobalKey<FormState>();
  late final username = TextEditingController(
    text: widget.initialUser ?? (widget.needsLogin ? 'admin' : ''),
  );
  late final password = TextEditingController(text: widget.initialPassword ?? '');
  late final name = TextEditingController(
    text: widget.camera.model ?? widget.camera.manufacturer ?? '',
  );
  late int lenses = widget.camera.brand == CameraBrand.v380 ? 2 : 1;
  StreamTest? test;
  bool testing = false;
  bool saving = false;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  String? get user => username.text.trim().isEmpty ? null : username.text.trim();

  String? get secret => password.text.isEmpty ? null : password.text;

  Future<void> runTest() async {
    final connector = widget.pairing.connector;
    if (connector == null) return;
    widget.session.step('test');
    setState(() {
      testing = true;
      test = null;
    });
    try {
      final result = await ref
          .read(backendProvider)
          .devices
          .testCamera(
            connectorId: connector.id,
            camera: widget.camera,
            username: user,
            password: secret,
          );
      if (!mounted) return;
      setState(() {
        test = result;
        if (result.ok) lenses = result.lenses;
      });
    } catch (failure) {
      if (mounted) {
        setState(() => test = StreamTest(ok: false, error: context.l10n.failure(failure)));
      }
    } finally {
      if (mounted) setState(() => testing = false);
    }
  }

  Future<void> save() async {
    final connector = widget.pairing.connector;
    if (connector == null || !form.currentState!.validate()) return;
    widget.session.step('add');
    setState(() => saving = true);
    try {
      final camera = await ref
          .read(backendProvider)
          .devices
          .addCamera(
            siteId: widget.pairing.siteId,
            connectorId: connector.id,
            camera: widget.camera,
            name: name.text.trim(),
            username: user,
            password: secret,
            lenses: lenses,
          );
      if (mounted) Navigator.of(context).pop(CamerasAdded([camera]));
    } catch (failure) {
      await widget.session.fail(failure);
      if (mounted) {
        setState(() => saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(context.l10n.failure(failure))));
      }
    }
  }

  String resultText(AppLocalizations l10n, StreamTest result) {
    if (!result.ok) {
      return result.error == 'unauthorised'
          ? l10n.onboardingTestFailed
          : (result.error ?? l10n.errorUnknown);
    }
    if (result.codec != null && result.width != null) {
      return l10n.onboardingTestOk(result.codec!, result.width!, result.height ?? 0);
    }
    return l10n.onboardingTestPassed;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final p = context.palette;
    final result = test;
    final camera = widget.camera;
    widget.session.step('credentials');
    return FlowScaffold(
      title: l10n.onboardingCameraTitle,
      subtitle: widget.needsLogin ? l10n.onboardingCameraBody : null,
      bottom: BusyButton(
        label: l10n.onboardingSaveCamera,
        busy: saving,
        onPressed: result?.ok == true ? save : null,
      ),
      children: [
        Panel(
          child: Row(
            children: [
              const IconBadge(icon: Icons.videocam_outlined),
              const SizedBox(width: Gaps.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [camera.manufacturer, camera.model].whereType<String>().join(' '),
                      style: context.text.titleMedium,
                    ),
                    Text(camera.host, style: dataStyle(context, size: 12.5, color: p.text2)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Gaps.lg),
        Form(
          key: form,
          child: Column(
            children: [
              if (widget.needsLogin) ...[
                TextFormField(
                  controller: username,
                  autocorrect: false,
                  decoration: InputDecoration(labelText: l10n.fieldCameraUser),
                  onChanged: (_) => setState(() => test = null),
                ),
                const SizedBox(height: Gaps.md),
                PasswordField(
                  controller: password,
                  label: l10n.fieldCameraPassword,
                  autofillHints: const [],
                  onChanged: (_) => setState(() => test = null),
                ),
                const SizedBox(height: Gaps.md),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: testing ? null : runTest,
                  icon: testing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.play_circle_outline_rounded, size: 19),
                  label: Text(testing ? l10n.onboardingTesting : l10n.onboardingTest),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                child: result == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: Gaps.md),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  result.ok
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.error_outline_rounded,
                                  color: result.ok ? p.ok : p.dangerText,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      resultText(l10n, result),
                                      style: context.text.bodyMedium?.copyWith(
                                        color: result.ok ? p.text : p.dangerText,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (result.ok && result.preview != null) ...[
                              const SizedBox(height: Gaps.md),
                              Frame(
                                aspect: 16 / 9,
                                child: MediaView(source: result.preview, showStamp: false),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
              if (result?.ok == true) ...[
                const SizedBox(height: Gaps.lg),
                TextFormField(
                  controller: name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: l10n.fieldCameraName,
                    hintText: l10n.fieldCameraNameHint,
                  ),
                  validator: (value) => validateRequired(l10n, value),
                ),
                const SizedBox(height: Gaps.lg),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.fieldLenses,
                    style: context.text.titleSmall?.copyWith(color: p.text2),
                  ),
                ),
                const SizedBox(height: Gaps.sm),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: 1,
                        label: Text(l10n.lensesOne),
                        icon: const Icon(Icons.crop_16_9_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: 2,
                        label: Text(l10n.lensesTwo),
                        icon: const Icon(Icons.view_day_outlined, size: 18),
                      ),
                    ],
                    selected: {lenses},
                    onSelectionChanged: (value) => setState(() => lenses = value.first),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
