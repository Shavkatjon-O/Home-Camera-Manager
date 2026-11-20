import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/features/identity/presentation/session.dart';
import 'package:smart_surveillance/features/tenancy/presentation/current_site.dart';

part 'router.g.dart';
const authPaths = ['/welcome', '/sign-in', '/sign-up', '/forgot', '/reset', '/verify-email', '/reset-password'];

@Riverpod(keepAlive: true)
class PendingLink extends _$PendingLink {
  @override
  String? build() => null;

  void set(String? location) => state = location;
}

String? redirectFor(Ref ref, GoRouterState state) {
  final location = state.matchedLocation;
  final session = ref.read(sessionProvider);
  final auth = authPaths.any(location.startsWith);
  final invite = location.startsWith('/invite/');
  final connect = location.startsWith('/connect');
  if (!session.hasValue) return location == '/splash' ? null : '/splash';
  final current = session.requireValue;
  if (current is SignedOut) {
    if (invite || connect) ref.read(pendingLinkProvider.notifier).set(state.uri.toString());
    if (auth || invite) return null;
    return const WelcomeRoute().location;
  }
  if (current is AwaitingVerification) {
    if (location.startsWith('/verify')) return null;
    return VerifyRoute(email: current.email).location;
  }
  final organisations = ref.read(organisationsProvider);
  final arriving = auth || location == '/splash' || location.startsWith('/verify');
  // Right after signing in the list still holds the signed-out value, so wait for the reload.
  if (!organisations.hasValue || (organisations.isLoading && arriving)) {
    return location == '/splash' ? null : '/splash';
  }
  if (invite) {
    ref.read(pendingLinkProvider.notifier).set(null);
    return null;
  }
  final pending = ref.read(pendingLinkProvider);
  if (pending != null) {
    ref.read(pendingLinkProvider.notifier).set(null);
    return pending;
  }
  if (organisations.requireValue.isEmpty) {
    if (location.startsWith('/setup')) return null;
    return const OnboardingSiteRoute().location;
  }
  if (auth || location == '/splash' || location.startsWith('/verify')) return const HomeRoute().location;
  return null;
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) {
    // The session listener can run before the list notices its dependency changed.
    ref.invalidate(organisationsProvider);
    refresh.value++;
  });
  ref.listen(organisationsProvider, (_, _) => refresh.value++);
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: const SplashRoute().location,
    routes: $appRoutes,
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(ref, state),
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
}
