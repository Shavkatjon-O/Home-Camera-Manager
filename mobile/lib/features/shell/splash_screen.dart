import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../widgets/logo.dart';
import '../../widgets/states.dart';

class SplashScreen extends ConsumerWidget {
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
