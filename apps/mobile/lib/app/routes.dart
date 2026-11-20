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

/// The key of the root navigator, used to show screens above the tab bar.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// The route to the start-up screen.
@TypedGoRoute<SplashRoute>(path: '/splash')
class SplashRoute extends GoRouteData with $SplashRoute {
  /// Creates the route to the start-up screen.
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashScreen();
}

/// The route to the welcome screen.
@TypedGoRoute<WelcomeRoute>(path: '/welcome')
class WelcomeRoute extends GoRouteData with $WelcomeRoute {
  /// Creates the route to the welcome screen.
  const WelcomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const WelcomeScreen();
}

/// The route to the sign-in screen.
@TypedGoRoute<SignInRoute>(path: '/sign-in')
class SignInRoute extends GoRouteData with $SignInRoute {
  /// Creates the route to the sign-in screen.
  const SignInRoute({this.notice});

  /// A message to show above the sign-in form, such as why the user was signed out.
  final String? notice;

  @override
  Widget build(BuildContext context, GoRouterState state) => SignInScreen(notice: notice);
}

/// The route to the sign-up screen.
@TypedGoRoute<SignUpRoute>(path: '/sign-up')
class SignUpRoute extends GoRouteData with $SignUpRoute {
  /// Creates the route to the sign-up screen.
  const SignUpRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SignUpScreen();
}

/// The route to the screen asking for the email verification code.
@TypedGoRoute<VerifyRoute>(path: '/verify')
class VerifyRoute extends GoRouteData with $VerifyRoute {
  /// Creates the route to the screen asking for the email verification code.
  const VerifyRoute({required this.email});

  /// The email address the code was sent to.
  final String email;

  @override
  Widget build(BuildContext context, GoRouterState state) => VerifyScreen(email: email);
}

/// The route to the forgotten password screen.
@TypedGoRoute<ForgotRoute>(path: '/forgot')
class ForgotRoute extends GoRouteData with $ForgotRoute {
  /// Creates the route to the forgotten password screen.
  const ForgotRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ForgotScreen();
}

/// The route to the screen for choosing a new password with an emailed code.
@TypedGoRoute<ResetRoute>(path: '/reset')
class ResetRoute extends GoRouteData with $ResetRoute {
  /// Creates the route to the screen for choosing a new password with an emailed code.
  const ResetRoute({required this.email});

  /// The email address the code was sent to.
  final String email;

  @override
  Widget build(BuildContext context, GoRouterState state) => ResetScreen(email: email);
}

/// The route to the screen for accepting an invitation.
@TypedGoRoute<InviteRoute>(path: '/invite/:token')
class InviteRoute extends GoRouteData with $InviteRoute {
  /// Creates the route to the screen for accepting an invitation.
  const InviteRoute({required this.token});

  /// The one-time token from the link.
  final String token;

  @override
  Widget build(BuildContext context, GoRouterState state) => InviteScreen(token: token);
}

/// The route to the setup step for creating a site.
@TypedGoRoute<OnboardingSiteRoute>(path: '/setup/site')
class OnboardingSiteRoute extends GoRouteData with $OnboardingSiteRoute {
  /// Creates the route to the setup step for creating a site.
  const OnboardingSiteRoute({this.first = true});

  /// Whether the step is part of first-time setup rather than adding to an existing site.
  final bool first;

  @override
  Widget build(BuildContext context, GoRouterState state) => SiteSetupScreen(first: first);
}

/// The route to the setup step for pairing a connector with a site.
@TypedGoRoute<OnboardingConnectorRoute>(path: '/setup/connector/:siteId')
class OnboardingConnectorRoute extends GoRouteData with $OnboardingConnectorRoute {
  /// Creates the route to the setup step for pairing a connector with a site.
  const OnboardingConnectorRoute({required this.siteId, this.first = true, this.code});

  /// The id of the site the step belongs to.
  final String siteId;

  /// Whether the step is part of first-time setup rather than adding to an existing site.
  final bool first;

  /// The pairing code to prefill, when the link carried one.
  final String? code;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ConnectorPairingScreen(siteId: siteId, first: first, code: code);
}

/// The route to the setup step for adding a first camera.
@TypedGoRoute<OnboardingAddRoute>(path: '/setup/add/:siteId')
class OnboardingAddRoute extends GoRouteData with $OnboardingAddRoute {
  /// Creates the route to the setup step for adding a first camera.
  const OnboardingAddRoute({required this.siteId, this.first = true});

  /// The id of the site the step belongs to.
  final String siteId;

  /// Whether the step is part of first-time setup rather than adding to an existing site.
  final bool first;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AddCameraScreen(siteId: siteId, first: first);
}

/// The route to the setup step for choosing an analytics preset for a camera.
@TypedGoRoute<OnboardingAnalyticsRoute>(path: '/setup/analytics/:siteId/:cameraId')
class OnboardingAnalyticsRoute extends GoRouteData with $OnboardingAnalyticsRoute {
  /// Creates the route to the setup step for choosing an analytics preset for a camera.
  const OnboardingAnalyticsRoute({required this.siteId, required this.cameraId, this.first = true});

  /// The id of the site the step belongs to.
  final String siteId;

  /// The id of the camera.
  final String cameraId;

  /// Whether the step is part of first-time setup rather than adding to an existing site.
  final bool first;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      AnalyticsPresetScreen(siteId: siteId, cameraId: cameraId, first: first);
}

/// The route to the setup step for notification permissions.
@TypedGoRoute<OnboardingNotificationsRoute>(path: '/setup/notifications')
class OnboardingNotificationsRoute extends GoRouteData with $OnboardingNotificationsRoute {
  /// Creates the route to the setup step for notification permissions.
  const OnboardingNotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotificationsSetupScreen();
}

/// The route to the final setup screen.
@TypedGoRoute<OnboardingDoneRoute>(path: '/setup/done')
class OnboardingDoneRoute extends GoRouteData with $OnboardingDoneRoute {
  /// Creates the route to the final setup screen.
  const OnboardingDoneRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SetupDoneScreen();
}

/// The route to the screen opened from a connector pairing link.
@TypedGoRoute<ConnectRoute>(path: '/connect')
class ConnectRoute extends GoRouteData with $ConnectRoute {
  /// Creates the route to the screen opened from a connector pairing link.
  const ConnectRoute({this.code});

  /// The pairing code to prefill, when the link carried one.
  final String? code;

  @override
  Widget build(BuildContext context, GoRouterState state) => ConnectLinkScreen(code: code);
}

/// The route to the screen opened from an email verification link.
@TypedGoRoute<VerifyLinkRoute>(path: '/verify-email/:token')
class VerifyLinkRoute extends GoRouteData with $VerifyLinkRoute {
  /// Creates the route to the screen opened from an email verification link.
  const VerifyLinkRoute({required this.token});

  /// The one-time token from the link.
  final String token;

  @override
  Widget build(BuildContext context, GoRouterState state) => VerifyLinkScreen(token: token);
}

/// The route to the password reset screen opened from an emailed link.
@TypedGoRoute<ResetLinkRoute>(path: '/reset-password/:token')
class ResetLinkRoute extends GoRouteData with $ResetLinkRoute {
  /// Creates the route to the password reset screen opened from an emailed link.
  const ResetLinkRoute({required this.token});

  /// The one-time token from the link.
  final String token;

  @override
  Widget build(BuildContext context, GoRouterState state) => ResetScreen(email: '', token: token);
}

/// The route to the live view of one camera.
@TypedGoRoute<CameraRoute>(path: '/camera/:cameraId')
class CameraRoute extends GoRouteData with $CameraRoute {
  /// Creates the route to the live view of one camera.
  const CameraRoute({required this.cameraId, this.lens = 0});

  /// The id of the camera.
  final String cameraId;

  /// The index of the camera lens to show.
  final int lens;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CameraScreen(cameraId: cameraId, lens: lens);
}

/// The route to the details of one event.
@TypedGoRoute<EventRoute>(path: '/event/:eventId')
class EventRoute extends GoRouteData with $EventRoute {
  /// Creates the route to the details of one event.
  const EventRoute({required this.eventId});

  /// The id of the event.
  final String eventId;

  @override
  Widget build(BuildContext context, GoRouterState state) => EventScreen(eventId: eventId);
}

/// The route to the search for a person seen in an event.
@TypedGoRoute<FindPersonRoute>(path: '/find-person/:eventId')
class FindPersonRoute extends GoRouteData with $FindPersonRoute {
  /// Creates the route to the search for a person seen in an event.
  const FindPersonRoute({required this.eventId});

  /// The id of the event.
  final String eventId;

  @override
  Widget build(BuildContext context, GoRouterState state) => FindPersonScreen(eventId: eventId);
}

/// The route to the details of one known person.
@TypedGoRoute<PersonRoute>(path: '/person/:personId')
class PersonRoute extends GoRouteData with $PersonRoute {
  /// Creates the route to the details of one known person.
  const PersonRoute({required this.personId});

  /// The id of the person.
  final String personId;

  @override
  Widget build(BuildContext context, GoRouterState state) => PersonScreen(personId: personId);
}

/// The route to the details of one cluster of similar faces.
@TypedGoRoute<ClusterRoute>(path: '/cluster/:clusterId')
class ClusterRoute extends GoRouteData with $ClusterRoute {
  /// Creates the route to the details of one cluster of similar faces.
  const ClusterRoute({required this.clusterId});

  /// The id of the face cluster.
  final String clusterId;

  @override
  Widget build(BuildContext context, GoRouterState state) => ClusterScreen(clusterId: clusterId);
}

/// The route to the editor for the zones of a camera view.
@TypedGoRoute<ZoneEditorRoute>(path: '/editor/:viewId')
class ZoneEditorRoute extends GoRouteData with $ZoneEditorRoute {
  /// Creates the route to the editor for the zones of a camera view.
  const ZoneEditorRoute({required this.viewId});

  /// The id of the analytics view.
  final String viewId;

  @override
  Widget build(BuildContext context, GoRouterState state) => ZoneEditorScreen(viewId: viewId);
}

/// The route of the tab shell that hosts the five main tabs.
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
            TypedGoRoute<CamerasRoute>(
              path: 'cameras',
              routes: [TypedGoRoute<CameraSettingsRoute>(path: ':cameraId')],
            ),
            TypedGoRoute<AnalyticsRoute>(
              path: 'analytics',
              routes: [TypedGoRoute<ViewRoute>(path: ':viewId')],
            ),
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
  /// Creates the tab shell route.
  const AppShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShell(shell: navigationShell);
}

/// The tab branch of the home tab.
class HomeBranch extends StatefulShellBranchData {
  /// Creates the branch of the home tab.
  const HomeBranch();
}

/// The tab branch of the live tab.
class LiveBranch extends StatefulShellBranchData {
  /// Creates the branch of the live tab.
  const LiveBranch();
}

/// The tab branch of the events tab.
class EventsBranch extends StatefulShellBranchData {
  /// Creates the branch of the events tab.
  const EventsBranch();
}

/// The tab branch of the search tab.
class SearchBranch extends StatefulShellBranchData {
  /// Creates the branch of the search tab.
  const SearchBranch();
}

/// The tab branch of the more tab.
class MoreBranch extends StatefulShellBranchData {
  /// Creates the branch of the more tab.
  const MoreBranch();
}

/// The route to the home tab.
class HomeRoute extends GoRouteData with $HomeRoute {
  /// Creates the route to the home tab.
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

/// The route to the live tab.
class LiveRoute extends GoRouteData with $LiveRoute {
  /// Creates the route to the live tab.
  const LiveRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const LiveScreen();
}

/// The route to the events tab.
class EventsRoute extends GoRouteData with $EventsRoute {
  /// Creates the route to the events tab.
  const EventsRoute({this.camera, this.kind, this.person, this.cluster, this.alerts = false});

  /// The id of the camera to filter by.
  final String? camera;

  /// The event kind to filter by.
  final String? kind;

  /// The id of the person to filter by.
  final String? person;

  /// The id of the face cluster to filter by.
  final String? cluster;

  /// Whether to list only events that raised alerts.
  final bool alerts;

  @override
  Widget build(BuildContext context, GoRouterState state) => EventsScreen(
    camera: camera,
    kind: kind,
    person: person,
    cluster: cluster,
    alertsOnly: alerts,
  );
}

/// The route to the search tab.
class SearchRoute extends GoRouteData with $SearchRoute {
  /// Creates the route to the search tab.
  const SearchRoute({this.tab = 0});

  /// The index of the search tab to open.
  final int tab;

  @override
  Widget build(BuildContext context, GoRouterState state) => SearchScreen(tab: tab);
}

/// The route to the more tab.
class MoreRoute extends GoRouteData with $MoreRoute {
  /// Creates the route to the more tab.
  const MoreRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MoreScreen();
}

/// The route to the people and vehicle counts screen.
class CountsRoute extends GoRouteData with $CountsRoute {
  /// Creates the route to the people and vehicle counts screen.
  const CountsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const CountsScreen();
}

/// The route to the settings of the current site.
class SiteSettingsRoute extends GoRouteData with $SiteSettingsRoute {
  /// Creates the route to the settings of the current site.
  const SiteSettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SiteSettingsScreen();
}

/// The route to the list of cameras.
class CamerasRoute extends GoRouteData with $CamerasRoute {
  /// Creates the route to the list of cameras.
  const CamerasRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const CamerasScreen();
}

/// The route to the settings of one camera.
class CameraSettingsRoute extends GoRouteData with $CameraSettingsRoute {
  /// Creates the route to the settings of one camera.
  const CameraSettingsRoute({required this.cameraId});

  /// The id of the camera.
  final String cameraId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      CameraSettingsScreen(cameraId: cameraId);
}

/// The route to the list of analytics views.
class AnalyticsRoute extends GoRouteData with $AnalyticsRoute {
  /// Creates the route to the list of analytics views.
  const AnalyticsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AnalyticsScreen();
}

/// The route to the settings of one analytics view.
class ViewRoute extends GoRouteData with $ViewRoute {
  /// Creates the route to the settings of one analytics view.
  const ViewRoute({required this.viewId});

  /// The id of the analytics view.
  final String viewId;

  @override
  Widget build(BuildContext context, GoRouterState state) => ViewScreen(viewId: viewId);
}

/// The route to the list of connectors.
class ConnectorsRoute extends GoRouteData with $ConnectorsRoute {
  /// Creates the route to the list of connectors.
  const ConnectorsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ConnectorsScreen();
}

/// The route to the device and server health screen.
class HealthRoute extends GoRouteData with $HealthRoute {
  /// Creates the route to the device and server health screen.
  const HealthRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HealthScreen();
}

/// The route to the members of the current site.
class MembersRoute extends GoRouteData with $MembersRoute {
  /// Creates the route to the members of the current site.
  const MembersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MembersScreen();
}

/// The route to the known faces screen.
class FacesRoute extends GoRouteData with $FacesRoute {
  /// Creates the route to the known faces screen.
  const FacesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const FacesScreen();
}

/// The route to the notification settings.
class NotificationsRoute extends GoRouteData with $NotificationsRoute {
  /// Creates the route to the notification settings.
  const NotificationsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const NotificationsScreen();
}

/// The route to the account screen.
class AccountRoute extends GoRouteData with $AccountRoute {
  /// Creates the route to the account screen.
  const AccountRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AccountScreen();
}

/// The route to the theme and language settings.
class AppearanceRoute extends GoRouteData with $AppearanceRoute {
  /// Creates the route to the theme and language settings.
  const AppearanceRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AppearanceScreen();
}

/// The route to the about screen.
class AboutRoute extends GoRouteData with $AboutRoute {
  /// Creates the route to the about screen.
  const AboutRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const AboutScreen();
}

/// The route to the plan and billing screen.
class PlanRoute extends GoRouteData with $PlanRoute {
  /// Creates the route to the plan and billing screen.
  const PlanRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const PlanScreen();
}

/// The route to the activity log.
class ActivityRoute extends GoRouteData with $ActivityRoute {
  /// Creates the route to the activity log.
  const ActivityRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const ActivityScreen();
}
