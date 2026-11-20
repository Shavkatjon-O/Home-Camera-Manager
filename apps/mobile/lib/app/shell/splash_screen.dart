import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_surveillance/core/widgets/logo.dart';
import 'package:smart_surveillance/core/widgets/states.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';
/// The start-up screen shown while the session and organisations load, or when loading fails.
/// The start-up screen shown while the session and organisations load, or when loading fails.
/// Creates the splash screen.
class SplashScreen extends ConsumerWidget {
  /// Creates the splash screen.
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final organisations = ref.watch(organisationsProvider);
    final error = session.error ?? organisations.error;
    return Scaffold(
      body: Center(
        child: error != null
            ? ErrorState(
                error: error,
                onRetry: () {
                  ref.invalidate(sessionProvider);
                  ref.invalidate(organisationsProvider);
                },
              )
            : const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LogoMark(size: 72),
                  SizedBox(height: 28),
                  SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                ],
              ),
      ),
    );
  }
}
