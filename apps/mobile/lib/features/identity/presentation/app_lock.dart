import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:smart_surveillance/app/l10n/l10n.dart';
import 'package:smart_surveillance/core/design/palette.dart';
import 'package:smart_surveillance/core/design/tokens.dart';
import 'package:smart_surveillance/core/providers.dart';
import 'package:smart_surveillance/core/widgets/logo.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
/// A wrapper that asks for device authentication before showing its [child].
class AppLock extends ConsumerStatefulWidget {
  /// Creates a lock around [child].
  const AppLock({super.key, required this.child});

  /// The content that is shown once the app is unlocked.
  final Widget child;

  @override
  ConsumerState<AppLock> createState() => _AppLockState();
}

class _AppLockState extends ConsumerState<AppLock> with WidgetsBindingObserver {
  final auth = LocalAuthentication();
  bool locked = false;
  DateTime? pausedAt;

  bool get wanted => ref.read(preferencesProvider).appLock && ref.read(sessionProvider).value is SignedIn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    locked = ref.read(preferencesProvider).appLock;
    if (locked) WidgetsBinding.instance.addPostFrameCallback((_) => unlock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) pausedAt = DateTime.now();
    if (state == AppLifecycleState.resumed && pausedAt != null && wanted) {
      if (DateTime.now().difference(pausedAt!) > const Duration(seconds: 30)) {
        setState(() => locked = true);
        unawaited(unlock());
      }
    }
  }

  Future<void> unlock() async {
    if (!mounted) return;
    final reason = context.l10n.lockReason;
    try {
      final ok = await auth.authenticate(localizedReason: reason);
      if (ok && mounted) setState(() => locked = false);
    } catch (_) {
      if (mounted && !await auth.isDeviceSupported()) setState(() => locked = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!locked || !wanted) return widget.child;
    final p = context.palette;
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Material(
            color: p.background,
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LogoMark(size: 64),
                    const SizedBox(height: Gaps.xl),
                    Text(context.l10n.lockTitle, style: context.text.titleMedium),
                    const SizedBox(height: Gaps.xl),
                    FilledButton.icon(
                      onPressed: unlock,
                      icon: const Icon(Icons.fingerprint_rounded),
                      label: Text(context.l10n.lockUnlock),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
