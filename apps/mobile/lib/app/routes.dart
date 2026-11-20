import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_surveillance/app/settings/about_screen.dart';
import 'package:smart_surveillance/app/settings/appearance_screen.dart';
import 'package:smart_surveillance/app/shell/app_shell.dart';
import 'package:smart_surveillance/app/shell/more_screen.dart';
import 'package:smart_surveillance/app/shell/setup_done_screen.dart';
import 'package:smart_surveillance/app/shell/splash_screen.dart';
import 'package:smart_surveillance/features/alerting/presentation/notifications_screen.dart';
import 'package:smart_surveillance/features/alerting/presentation/notifications_setup_screen.dart';
import 'package:smart_surveillance/features/analytics/presentation/analytics_screens.dart';
import 'package:smart_surveillance/features/analytics/presentation/preset_screen.dart';
import 'package:smart_surveillance/features/analytics/presentation/zone_editor_screen.dart';
import 'package:smart_surveillance/features/billing/presentation/plan_screen.dart';
import 'package:smart_surveillance/features/devices/pairing/pairing_screens.dart';
import 'package:smart_surveillance/features/devices/presentation/cameras_screens.dart';
import 'package:smart_surveillance/features/devices/presentation/connectors_screen.dart';
import 'package:smart_surveillance/features/events/presentation/event_screen.dart';
import 'package:smart_surveillance/features/events/presentation/events_screen.dart';
import 'package:smart_surveillance/features/identity/presentation/account_screen.dart';
import 'package:smart_surveillance/features/identity/presentation/reset_screens.dart';
import 'package:smart_surveillance/features/identity/presentation/sign_in_screen.dart';
import 'package:smart_surveillance/features/identity/presentation/sign_up_screen.dart';
import 'package:smart_surveillance/features/identity/presentation/verify_screen.dart';
import 'package:smart_surveillance/features/identity/presentation/welcome_screen.dart';
import 'package:smart_surveillance/features/insights/presentation/counts_screen.dart';
import 'package:smart_surveillance/features/insights/presentation/home_screen.dart';
import 'package:smart_surveillance/features/investigation/presentation/faces_screen.dart';
import 'package:smart_surveillance/features/investigation/presentation/find_person_screen.dart';
import 'package:smart_surveillance/features/investigation/presentation/people_screens.dart';
import 'package:smart_surveillance/features/investigation/presentation/search_screen.dart';
import 'package:smart_surveillance/features/media/presentation/camera_screen.dart';
import 'package:smart_surveillance/features/media/presentation/live_screen.dart';
import 'package:smart_surveillance/features/operations/presentation/activity_screen.dart';
import 'package:smart_surveillance/features/operations/presentation/health_screen.dart';
import 'package:smart_surveillance/features/tenancy/presentation/invite_screen.dart';
import 'package:smart_surveillance/features/tenancy/presentation/members_screen.dart';
import 'package:smart_surveillance/features/tenancy/presentation/site_settings_screen.dart';
import 'package:smart_surveillance/features/tenancy/presentation/site_setup_screen.dart';

part 'routes.g.dart';
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashScreen();
}

@TypedGoRoute<WelcomeRoute>(path: '/welcome')
class WelcomeRoute extends GoRouteData with $WelcomeRoute {
  const WelcomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const WelcomeScreen();
}

@TypedGoRoute<SignInRoute>(path: '/sign-in')
class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute({this.notice});

  final String? notice;

  @override
  Widget build(BuildContext context, GoRouterState state) => SignInScreen(notice: notice);
}

@TypedGoRoute<SignUpRoute>(path: '/sign-up')
class SignUpRoute extends GoRouteData with $SignUpRoute {
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignUpScreen();
}

@TypedGoRoute<VerifyRoute>(path: '/verify')
class VerifyRoute extends GoRouteData with $VerifyRoute {
  const VerifyRoute({required this.email});

  final String email;

  @override
  Widget build(BuildContext context, GoRouterState state) => VerifyScreen(email: email);
}

@TypedGoRoute<ForgotRoute>(path: '/forgot')
class ForgotRoute extends GoRouteData with $ForgotRoute {
  const ForgotRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ForgotScreen();
}

@TypedGoRoute<ResetRoute>(path: '/reset')
class ResetRoute extends GoRouteData with $ResetRoute {
  const ResetRoute({required this.email});

  final String email;

  @override
  Widget build(BuildContext context, GoRouterState state) => ResetScreen(email: email);
}

@TypedGoRoute<InviteRoute>(path: '/invite/:token')
class InviteRoute extends GoRouteData with $InviteRoute {
  const InviteRoute({required this.token});

  final String token;

  @override
  Widget build(BuildContext context, GoRouterState state) => InviteScreen(token: token);
}

@TypedGoRoute<OnboardingSiteRoute>(path: '/setup/site')
class OnboardingSiteRoute extends GoRouteData with $OnboardingSiteRoute {
  const OnboardingSiteRoute({this.first = true});

  final bool first;

  @override
  Widget build(BuildContext context, GoRouterState state) => SiteSetupScreen(first: first);
}

@TypedGoRoute<OnboardingConnectorRoute>(path: '/setup/connector/:siteId')
class OnboardingConnectorRoute extends GoRouteData with $OnboardingConnectorRoute {
  const OnboardingConnectorRoute({required this.siteId, this.first = true, this.code});

  final String siteId;
  final bool first;
  final String? code;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ConnectorPairingScreen(siteId: siteId, first: first, code: code);
}

@TypedGoRoute<OnboardingAddRoute>(path: '/setup/add/:siteId')
class OnboardingAddRoute extends GoRouteData with $OnboardingAddRoute {
  const OnboardingAddRoute({required this.siteId, this.first = true});

  final String siteId;
  final bool first;

  @override
  Widget build(BuildContext context, GoRouterState state) => AddCameraScreen(siteId: siteId, first: first);
}

@TypedGoRoute<OnboardingAnalyticsRoute>(path: '/setup/analytics/:siteId/:cameraId')
class OnboardingAnalyticsRoute extends GoRouteData with $OnboardingAnalyticsRoute {
  const OnboardingAnalyticsRoute({required this.siteId, required this.cameraId, this.first = true});

  final String siteId;
  final String cameraId;
  final bool first;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AnalyticsPresetScreen(siteId: siteId, cameraId: cameraId, first: first);
}

@TypedGoRoute<OnboardingNotificationsRoute>(path: '/setup/notifications')
class OnboardingNotificationsRoute extends GoRouteData with $OnboardingNotificationsRoute {
  const OnboardingNotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotificationsSetupScreen();
}

@TypedGoRoute<OnboardingDoneRoute>(path: '/setup/done')
class OnboardingDoneRoute extends GoRouteData with $OnboardingDoneRoute {
  const OnboardingDoneRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SetupDoneScreen();
}

@TypedGoRoute<ConnectRoute>(path: '/connect')
class ConnectRoute extends GoRouteData with $ConnectRoute {
  const ConnectRoute({this.code});

  final String? code;

  @override
  Widget build(BuildContext context, GoRouterState state) => ConnectLinkScreen(code: code);
}

@TypedGoRoute<VerifyLinkRoute>(path: '/verify-email/:token')
class VerifyLinkRoute extends GoRouteData with $VerifyLinkRoute {
  const VerifyLinkRoute({required this.token});

  final String token;

  @override
  Widget build(BuildContext context, GoRouterState state) => VerifyLinkScreen(token: token);
}

@TypedGoRoute<ResetLinkRoute>(path: '/reset-password/:token')
class ResetLinkRoute extends GoRouteData with $ResetLinkRoute {
  const ResetLinkRoute({required this.token});

  final String token;

  @override
  Widget build(BuildContext context, GoRouterState state) => ResetScreen(email: '', token: token);
}

@TypedGoRoute<CameraRoute>(path: '/camera/:cameraId')
class CameraRoute extends GoRouteData with $CameraRoute {
  const CameraRoute({required this.cameraId, this.lens = 0});

  final String cameraId;
  final int lens;

  @override
  Widget build(BuildContext context, GoRouterState state) => CameraScreen(cameraId: cameraId, lens: lens);
}

@TypedGoRoute<EventRoute>(path: '/event/:eventId')
class EventRoute extends GoRouteData with $EventRoute {
  const EventRoute({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, GoRouterState state) => EventScreen(eventId: eventId);
}

@TypedGoRoute<FindPersonRoute>(path: '/find-person/:eventId')
class FindPersonRoute extends GoRouteData with $FindPersonRoute {
  const FindPersonRoute({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, GoRouterState state) => FindPersonScreen(eventId: eventId);
}

@TypedGoRoute<PersonRoute>(path: '/person/:personId')
class PersonRoute extends GoRouteData with $PersonRoute {
  const PersonRoute({required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, GoRouterState state) => PersonScreen(personId: personId);
}

@TypedGoRoute<ClusterRoute>(path: '/cluster/:clusterId')
class ClusterRoute extends GoRouteData with $ClusterRoute {
  const ClusterRoute({required this.clusterId});

  final String clusterId;

  @override
  Widget build(BuildContext context, GoRouterState state) => ClusterScreen(clusterId: clusterId);
}

@TypedGoRoute<ZoneEditorRoute>(path: '/editor/:viewId')
class ZoneEditorRoute extends GoRouteData with $ZoneEditorRoute {
  const ZoneEditorRoute({required this.viewId});

  final String viewId;

  @override
  Widget build(BuildContext context, GoRouterState state) => ZoneEditorScreen(viewId: viewId);
}

@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<HomeBranch>(routes: [TypedGoRoute<HomeRoute>(path: '/home')]),
    TypedStatefulShellBranch<LiveBranch>(routes: [TypedGoRoute<LiveRoute>(path: '/live')]),
    TypedStatefulShellBranch<EventsBranch>(routes: [TypedGoRoute<EventsRoute>(path: '/events')]),
    TypedStatefulShellBranch<SearchBranch>(routes: [TypedGoRoute<SearchRoute>(path: '/search')]),
    TypedStatefulShellBranch<MoreBranch>(
      routes: [
        TypedGoRoute<MoreRoute>(
          path: '/more',
          routes: [
            TypedGoRoute<CountsRoute>(path: 'counts'),
            TypedGoRoute<SiteSettingsRoute>(path: 'site'),
            TypedGoRoute<CamerasRoute>(path: 'cameras', routes: [TypedGoRoute<CameraSettingsRoute>(path: ':cameraId')]),
            TypedGoRoute<AnalyticsRoute>(path: 'analytics', routes: [TypedGoRoute<ViewRoute>(path: ':viewId')]),
            TypedGoRoute<ConnectorsRoute>(path: 'connectors'),
            TypedGoRoute<HealthRoute>(path: 'health'),
            TypedGoRoute<MembersRoute>(path: 'members'),
            TypedGoRoute<FacesRoute>(path: 'faces'),
            TypedGoRoute<NotificationsRoute>(path: 'notifications'),
            TypedGoRoute<PlanRoute>(path: 'plan'),
            TypedGoRoute<ActivityRoute>(path: 'activity'),
            TypedGoRoute<AccountRoute>(path: 'account'),
            TypedGoRoute<AppearanceRoute>(path: 'appearance'),
            TypedGoRoute<AboutRoute>(path: 'about'),
          ],
        ),
      ],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) =>
      AppShell(shell: navigationShell);
}

class HomeBranch extends StatefulShellBranchData {
  const HomeBranch();
}

class LiveBranch extends StatefulShellBranchData {
  const LiveBranch();
}

class EventsBranch extends StatefulShellBranchData {
  const EventsBranch();
}

class SearchBranch extends StatefulShellBranchData {
  const SearchBranch();
}

class MoreBranch extends StatefulShellBranchData {
  const MoreBranch();
}

class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

class LiveRoute extends GoRouteData with $LiveRoute {
  const LiveRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LiveScreen();
}

class EventsRoute extends GoRouteData with $EventsRoute {
  const EventsRoute({this.camera, this.kind, this.person, this.cluster, this.alerts = false});

  final String? camera;
  final String? kind;
  final String? person;
  final String? cluster;
  final bool alerts;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EventsScreen(camera: camera, kind: kind, person: person, cluster: cluster, alertsOnly: alerts);
}

class SearchRoute extends GoRouteData with $SearchRoute {
  const SearchRoute({this.tab = 0});

  final int tab;

  @override
  Widget build(BuildContext context, GoRouterState state) => SearchScreen(tab: tab);
}

class MoreRoute extends GoRouteData with $MoreRoute {
  const MoreRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MoreScreen();
}

class CountsRoute extends GoRouteData with $CountsRoute {
  const CountsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const CountsScreen();
}

class SiteSettingsRoute extends GoRouteData with $SiteSettingsRoute {
  const SiteSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SiteSettingsScreen();
}

class CamerasRoute extends GoRouteData with $CamerasRoute {
  const CamerasRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const CamerasScreen();
}

class CameraSettingsRoute extends GoRouteData with $CameraSettingsRoute {
  const CameraSettingsRoute({required this.cameraId});

  final String cameraId;

  @override
  Widget build(BuildContext context, GoRouterState state) => CameraSettingsScreen(cameraId: cameraId);
}

class AnalyticsRoute extends GoRouteData with $AnalyticsRoute {
  const AnalyticsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AnalyticsScreen();
}

class ViewRoute extends GoRouteData with $ViewRoute {
  const ViewRoute({required this.viewId});

  final String viewId;

  @override
  Widget build(BuildContext context, GoRouterState state) => ViewScreen(viewId: viewId);
}

class ConnectorsRoute extends GoRouteData with $ConnectorsRoute {
  const ConnectorsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ConnectorsScreen();
}

class HealthRoute extends GoRouteData with $HealthRoute {
  const HealthRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HealthScreen();
}

class MembersRoute extends GoRouteData with $MembersRoute {
  const MembersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MembersScreen();
}

class FacesRoute extends GoRouteData with $FacesRoute {
  const FacesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const FacesScreen();
}

class NotificationsRoute extends GoRouteData with $NotificationsRoute {
  const NotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotificationsScreen();
}

class AccountRoute extends GoRouteData with $AccountRoute {
  const AccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AccountScreen();
}

class AppearanceRoute extends GoRouteData with $AppearanceRoute {
  const AppearanceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AppearanceScreen();
}

class AboutRoute extends GoRouteData with $AboutRoute {
  const AboutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AboutScreen();
}

class PlanRoute extends GoRouteData with $PlanRoute {
  const PlanRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const PlanScreen();
}

class ActivityRoute extends GoRouteData with $ActivityRoute {
  const ActivityRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ActivityScreen();
}
