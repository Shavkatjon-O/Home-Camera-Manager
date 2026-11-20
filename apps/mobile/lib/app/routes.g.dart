// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $splashRoute,
  $welcomeRoute,
  $signInRoute,
  $signUpRoute,
  $verifyRoute,
  $forgotRoute,
  $resetRoute,
  $inviteRoute,
  $onboardingSiteRoute,
  $onboardingConnectorRoute,
  $onboardingAddRoute,
  $onboardingAnalyticsRoute,
  $onboardingNotificationsRoute,
  $onboardingDoneRoute,
  $connectRoute,
  $verifyLinkRoute,
  $resetLinkRoute,
  $cameraRoute,
  $eventRoute,
  $findPersonRoute,
  $personRoute,
  $clusterRoute,
  $zoneEditorRoute,
  $appShellRoute,
];

RouteBase get $splashRoute => GoRouteData.$route(
  path: '/splash',
  hasOverriddenOnExit: false,
  factory: $SplashRoute._fromState,
);

mixin $SplashRoute on GoRouteData {
  static SplashRoute _fromState(GoRouterState state) => const SplashRoute();

  @override
  String get location => GoRouteData.$location('/splash');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $welcomeRoute => GoRouteData.$route(
  path: '/welcome',
  hasOverriddenOnExit: false,
  factory: $WelcomeRoute._fromState,
);

mixin $WelcomeRoute on GoRouteData {
  static WelcomeRoute _fromState(GoRouterState state) => const WelcomeRoute();

  @override
  String get location => GoRouteData.$location('/welcome');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signInRoute => GoRouteData.$route(
  path: '/sign-in',
  hasOverriddenOnExit: false,
  factory: $SignInRoute._fromState,
);

mixin $SignInRoute on GoRouteData {
  static SignInRoute _fromState(GoRouterState state) =>
      SignInRoute(notice: state.uri.queryParameters['notice']);

  SignInRoute get _self => this as SignInRoute;

  @override
  String get location => GoRouteData.$location(
    '/sign-in',
    queryParams: {if (_self.notice != null) 'notice': _self.notice},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $signUpRoute => GoRouteData.$route(
  path: '/sign-up',
  hasOverriddenOnExit: false,
  factory: $SignUpRoute._fromState,
);

mixin $SignUpRoute on GoRouteData {
  static SignUpRoute _fromState(GoRouterState state) => const SignUpRoute();

  @override
  String get location => GoRouteData.$location('/sign-up');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $verifyRoute => GoRouteData.$route(
  path: '/verify',
  hasOverriddenOnExit: false,
  factory: $VerifyRoute._fromState,
);

mixin $VerifyRoute on GoRouteData {
  static VerifyRoute _fromState(GoRouterState state) =>
      VerifyRoute(email: state.uri.queryParameters['email']!);

  VerifyRoute get _self => this as VerifyRoute;

  @override
  String get location => GoRouteData.$location('/verify', queryParams: {'email': _self.email});

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $forgotRoute => GoRouteData.$route(
  path: '/forgot',
  hasOverriddenOnExit: false,
  factory: $ForgotRoute._fromState,
);

mixin $ForgotRoute on GoRouteData {
  static ForgotRoute _fromState(GoRouterState state) => const ForgotRoute();

  @override
  String get location => GoRouteData.$location('/forgot');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $resetRoute =>
    GoRouteData.$route(path: '/reset', hasOverriddenOnExit: false, factory: $ResetRoute._fromState);

mixin $ResetRoute on GoRouteData {
  static ResetRoute _fromState(GoRouterState state) =>
      ResetRoute(email: state.uri.queryParameters['email']!);

  ResetRoute get _self => this as ResetRoute;

  @override
  String get location => GoRouteData.$location('/reset', queryParams: {'email': _self.email});

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $inviteRoute => GoRouteData.$route(
  path: '/invite/:token',
  hasOverriddenOnExit: false,
  factory: $InviteRoute._fromState,
);

mixin $InviteRoute on GoRouteData {
  static InviteRoute _fromState(GoRouterState state) =>
      InviteRoute(token: state.pathParameters['token']!);

  InviteRoute get _self => this as InviteRoute;

  @override
  String get location => GoRouteData.$location('/invite/${Uri.encodeComponent(_self.token)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingSiteRoute => GoRouteData.$route(
  path: '/setup/site',
  hasOverriddenOnExit: false,
  factory: $OnboardingSiteRoute._fromState,
);

mixin $OnboardingSiteRoute on GoRouteData {
  static OnboardingSiteRoute _fromState(GoRouterState state) => OnboardingSiteRoute(
    first: _$convertMapValue('first', state.uri.queryParameters, _$boolConverter) ?? true,
  );

  OnboardingSiteRoute get _self => this as OnboardingSiteRoute;

  @override
  String get location => GoRouteData.$location(
    '/setup/site',
    queryParams: {if (_self.first != true) 'first': _self.first.toString()},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(String key, Map<String, String> map, T? Function(String) converter) {
  final value = map[key];
  return value == null ? null : converter(value);
}

bool _$boolConverter(String value) {
  switch (value) {
    case 'true':
      return true;
    case 'false':
      return false;
    default:
      throw UnsupportedError('Cannot convert "$value" into a bool.');
  }
}

RouteBase get $onboardingConnectorRoute => GoRouteData.$route(
  path: '/setup/connector/:siteId',
  hasOverriddenOnExit: false,
  factory: $OnboardingConnectorRoute._fromState,
);

mixin $OnboardingConnectorRoute on GoRouteData {
  static OnboardingConnectorRoute _fromState(GoRouterState state) => OnboardingConnectorRoute(
    siteId: state.pathParameters['siteId']!,
    first: _$convertMapValue('first', state.uri.queryParameters, _$boolConverter) ?? true,
    code: state.uri.queryParameters['code'],
  );

  OnboardingConnectorRoute get _self => this as OnboardingConnectorRoute;

  @override
  String get location => GoRouteData.$location(
    '/setup/connector/${Uri.encodeComponent(_self.siteId)}',
    queryParams: {
      if (_self.first != true) 'first': _self.first.toString(),
      if (_self.code != null) 'code': _self.code,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingAddRoute => GoRouteData.$route(
  path: '/setup/add/:siteId',
  hasOverriddenOnExit: false,
  factory: $OnboardingAddRoute._fromState,
);

mixin $OnboardingAddRoute on GoRouteData {
  static OnboardingAddRoute _fromState(GoRouterState state) => OnboardingAddRoute(
    siteId: state.pathParameters['siteId']!,
    first: _$convertMapValue('first', state.uri.queryParameters, _$boolConverter) ?? true,
  );

  OnboardingAddRoute get _self => this as OnboardingAddRoute;

  @override
  String get location => GoRouteData.$location(
    '/setup/add/${Uri.encodeComponent(_self.siteId)}',
    queryParams: {if (_self.first != true) 'first': _self.first.toString()},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingAnalyticsRoute => GoRouteData.$route(
  path: '/setup/analytics/:siteId/:cameraId',
  hasOverriddenOnExit: false,
  factory: $OnboardingAnalyticsRoute._fromState,
);

mixin $OnboardingAnalyticsRoute on GoRouteData {
  static OnboardingAnalyticsRoute _fromState(GoRouterState state) => OnboardingAnalyticsRoute(
    siteId: state.pathParameters['siteId']!,
    cameraId: state.pathParameters['cameraId']!,
    first: _$convertMapValue('first', state.uri.queryParameters, _$boolConverter) ?? true,
  );

  OnboardingAnalyticsRoute get _self => this as OnboardingAnalyticsRoute;

  @override
  String get location => GoRouteData.$location(
    '/setup/analytics/${Uri.encodeComponent(_self.siteId)}/${Uri.encodeComponent(_self.cameraId)}',
    queryParams: {if (_self.first != true) 'first': _self.first.toString()},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingNotificationsRoute => GoRouteData.$route(
  path: '/setup/notifications',
  hasOverriddenOnExit: false,
  factory: $OnboardingNotificationsRoute._fromState,
);

mixin $OnboardingNotificationsRoute on GoRouteData {
  static OnboardingNotificationsRoute _fromState(GoRouterState state) =>
      const OnboardingNotificationsRoute();

  @override
  String get location => GoRouteData.$location('/setup/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $onboardingDoneRoute => GoRouteData.$route(
  path: '/setup/done',
  hasOverriddenOnExit: false,
  factory: $OnboardingDoneRoute._fromState,
);

mixin $OnboardingDoneRoute on GoRouteData {
  static OnboardingDoneRoute _fromState(GoRouterState state) => const OnboardingDoneRoute();

  @override
  String get location => GoRouteData.$location('/setup/done');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $connectRoute => GoRouteData.$route(
  path: '/connect',
  hasOverriddenOnExit: false,
  factory: $ConnectRoute._fromState,
);

mixin $ConnectRoute on GoRouteData {
  static ConnectRoute _fromState(GoRouterState state) =>
      ConnectRoute(code: state.uri.queryParameters['code']);

  ConnectRoute get _self => this as ConnectRoute;

  @override
  String get location =>
      GoRouteData.$location('/connect', queryParams: {if (_self.code != null) 'code': _self.code});

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $verifyLinkRoute => GoRouteData.$route(
  path: '/verify-email/:token',
  hasOverriddenOnExit: false,
  factory: $VerifyLinkRoute._fromState,
);

mixin $VerifyLinkRoute on GoRouteData {
  static VerifyLinkRoute _fromState(GoRouterState state) =>
      VerifyLinkRoute(token: state.pathParameters['token']!);

  VerifyLinkRoute get _self => this as VerifyLinkRoute;

  @override
  String get location => GoRouteData.$location('/verify-email/${Uri.encodeComponent(_self.token)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $resetLinkRoute => GoRouteData.$route(
  path: '/reset-password/:token',
  hasOverriddenOnExit: false,
  factory: $ResetLinkRoute._fromState,
);

mixin $ResetLinkRoute on GoRouteData {
  static ResetLinkRoute _fromState(GoRouterState state) =>
      ResetLinkRoute(token: state.pathParameters['token']!);

  ResetLinkRoute get _self => this as ResetLinkRoute;

  @override
  String get location =>
      GoRouteData.$location('/reset-password/${Uri.encodeComponent(_self.token)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $cameraRoute => GoRouteData.$route(
  path: '/camera/:cameraId',
  hasOverriddenOnExit: false,
  factory: $CameraRoute._fromState,
);

mixin $CameraRoute on GoRouteData {
  static CameraRoute _fromState(GoRouterState state) => CameraRoute(
    cameraId: state.pathParameters['cameraId']!,
    lens: _$convertMapValue('lens', state.uri.queryParameters, int.parse) ?? 0,
  );

  CameraRoute get _self => this as CameraRoute;

  @override
  String get location => GoRouteData.$location(
    '/camera/${Uri.encodeComponent(_self.cameraId)}',
    queryParams: {if (_self.lens != 0) 'lens': _self.lens.toString()},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $eventRoute => GoRouteData.$route(
  path: '/event/:eventId',
  hasOverriddenOnExit: false,
  factory: $EventRoute._fromState,
);

mixin $EventRoute on GoRouteData {
  static EventRoute _fromState(GoRouterState state) =>
      EventRoute(eventId: state.pathParameters['eventId']!);

  EventRoute get _self => this as EventRoute;

  @override
  String get location => GoRouteData.$location('/event/${Uri.encodeComponent(_self.eventId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $findPersonRoute => GoRouteData.$route(
  path: '/find-person/:eventId',
  hasOverriddenOnExit: false,
  factory: $FindPersonRoute._fromState,
);

mixin $FindPersonRoute on GoRouteData {
  static FindPersonRoute _fromState(GoRouterState state) =>
      FindPersonRoute(eventId: state.pathParameters['eventId']!);

  FindPersonRoute get _self => this as FindPersonRoute;

  @override
  String get location =>
      GoRouteData.$location('/find-person/${Uri.encodeComponent(_self.eventId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $personRoute => GoRouteData.$route(
  path: '/person/:personId',
  hasOverriddenOnExit: false,
  factory: $PersonRoute._fromState,
);

mixin $PersonRoute on GoRouteData {
  static PersonRoute _fromState(GoRouterState state) =>
      PersonRoute(personId: state.pathParameters['personId']!);

  PersonRoute get _self => this as PersonRoute;

  @override
  String get location => GoRouteData.$location('/person/${Uri.encodeComponent(_self.personId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $clusterRoute => GoRouteData.$route(
  path: '/cluster/:clusterId',
  hasOverriddenOnExit: false,
  factory: $ClusterRoute._fromState,
);

mixin $ClusterRoute on GoRouteData {
  static ClusterRoute _fromState(GoRouterState state) =>
      ClusterRoute(clusterId: state.pathParameters['clusterId']!);

  ClusterRoute get _self => this as ClusterRoute;

  @override
  String get location => GoRouteData.$location('/cluster/${Uri.encodeComponent(_self.clusterId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $zoneEditorRoute => GoRouteData.$route(
  path: '/editor/:viewId',
  hasOverriddenOnExit: false,
  factory: $ZoneEditorRoute._fromState,
);

mixin $ZoneEditorRoute on GoRouteData {
  static ZoneEditorRoute _fromState(GoRouterState state) =>
      ZoneEditorRoute(viewId: state.pathParameters['viewId']!);

  ZoneEditorRoute get _self => this as ZoneEditorRoute;

  @override
  String get location => GoRouteData.$location('/editor/${Uri.encodeComponent(_self.viewId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appShellRoute => StatefulShellRouteData.$route(
  factory: $AppShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/home',
          hasOverriddenOnExit: false,
          factory: $HomeRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/live',
          hasOverriddenOnExit: false,
          factory: $LiveRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/events',
          hasOverriddenOnExit: false,
          factory: $EventsRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/search',
          hasOverriddenOnExit: false,
          factory: $SearchRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/more',
          hasOverriddenOnExit: false,
          factory: $MoreRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'counts',
              hasOverriddenOnExit: false,
              factory: $CountsRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'site',
              hasOverriddenOnExit: false,
              factory: $SiteSettingsRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'cameras',
              hasOverriddenOnExit: false,
              factory: $CamerasRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':cameraId',
                  hasOverriddenOnExit: false,
                  factory: $CameraSettingsRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'analytics',
              hasOverriddenOnExit: false,
              factory: $AnalyticsRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':viewId',
                  hasOverriddenOnExit: false,
                  factory: $ViewRoute._fromState,
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'connectors',
              hasOverriddenOnExit: false,
              factory: $ConnectorsRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'health',
              hasOverriddenOnExit: false,
              factory: $HealthRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'members',
              hasOverriddenOnExit: false,
              factory: $MembersRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'faces',
              hasOverriddenOnExit: false,
              factory: $FacesRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'notifications',
              hasOverriddenOnExit: false,
              factory: $NotificationsRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'plan',
              hasOverriddenOnExit: false,
              factory: $PlanRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'activity',
              hasOverriddenOnExit: false,
              factory: $ActivityRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'account',
              hasOverriddenOnExit: false,
              factory: $AccountRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'appearance',
              hasOverriddenOnExit: false,
              factory: $AppearanceRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'about',
              hasOverriddenOnExit: false,
              factory: $AboutRoute._fromState,
            ),
          ],
        ),
      ],
    ),
  ],
);

extension $AppShellRouteExtension on AppShellRoute {
  static AppShellRoute _fromState(GoRouterState state) => const AppShellRoute();
}

mixin $HomeRoute on GoRouteData {
  static HomeRoute _fromState(GoRouterState state) => const HomeRoute();

  @override
  String get location => GoRouteData.$location('/home');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $LiveRoute on GoRouteData {
  static LiveRoute _fromState(GoRouterState state) => const LiveRoute();

  @override
  String get location => GoRouteData.$location('/live');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $EventsRoute on GoRouteData {
  static EventsRoute _fromState(GoRouterState state) => EventsRoute(
    camera: state.uri.queryParameters['camera'],
    kind: state.uri.queryParameters['kind'],
    person: state.uri.queryParameters['person'],
    cluster: state.uri.queryParameters['cluster'],
    alerts: _$convertMapValue('alerts', state.uri.queryParameters, _$boolConverter) ?? false,
  );

  EventsRoute get _self => this as EventsRoute;

  @override
  String get location => GoRouteData.$location(
    '/events',
    queryParams: {
      if (_self.camera != null) 'camera': _self.camera,
      if (_self.kind != null) 'kind': _self.kind,
      if (_self.person != null) 'person': _self.person,
      if (_self.cluster != null) 'cluster': _self.cluster,
      if (_self.alerts != false) 'alerts': _self.alerts.toString(),
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SearchRoute on GoRouteData {
  static SearchRoute _fromState(GoRouterState state) =>
      SearchRoute(tab: _$convertMapValue('tab', state.uri.queryParameters, int.parse) ?? 0);

  SearchRoute get _self => this as SearchRoute;

  @override
  String get location => GoRouteData.$location(
    '/search',
    queryParams: {if (_self.tab != 0) 'tab': _self.tab.toString()},
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MoreRoute on GoRouteData {
  static MoreRoute _fromState(GoRouterState state) => const MoreRoute();

  @override
  String get location => GoRouteData.$location('/more');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CountsRoute on GoRouteData {
  static CountsRoute _fromState(GoRouterState state) => const CountsRoute();

  @override
  String get location => GoRouteData.$location('/more/counts');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $SiteSettingsRoute on GoRouteData {
  static SiteSettingsRoute _fromState(GoRouterState state) => const SiteSettingsRoute();

  @override
  String get location => GoRouteData.$location('/more/site');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CamerasRoute on GoRouteData {
  static CamerasRoute _fromState(GoRouterState state) => const CamerasRoute();

  @override
  String get location => GoRouteData.$location('/more/cameras');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CameraSettingsRoute on GoRouteData {
  static CameraSettingsRoute _fromState(GoRouterState state) =>
      CameraSettingsRoute(cameraId: state.pathParameters['cameraId']!);

  CameraSettingsRoute get _self => this as CameraSettingsRoute;

  @override
  String get location =>
      GoRouteData.$location('/more/cameras/${Uri.encodeComponent(_self.cameraId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AnalyticsRoute on GoRouteData {
  static AnalyticsRoute _fromState(GoRouterState state) => const AnalyticsRoute();

  @override
  String get location => GoRouteData.$location('/more/analytics');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ViewRoute on GoRouteData {
  static ViewRoute _fromState(GoRouterState state) =>
      ViewRoute(viewId: state.pathParameters['viewId']!);

  ViewRoute get _self => this as ViewRoute;

  @override
  String get location =>
      GoRouteData.$location('/more/analytics/${Uri.encodeComponent(_self.viewId)}');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ConnectorsRoute on GoRouteData {
  static ConnectorsRoute _fromState(GoRouterState state) => const ConnectorsRoute();

  @override
  String get location => GoRouteData.$location('/more/connectors');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $HealthRoute on GoRouteData {
  static HealthRoute _fromState(GoRouterState state) => const HealthRoute();

  @override
  String get location => GoRouteData.$location('/more/health');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MembersRoute on GoRouteData {
  static MembersRoute _fromState(GoRouterState state) => const MembersRoute();

  @override
  String get location => GoRouteData.$location('/more/members');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $FacesRoute on GoRouteData {
  static FacesRoute _fromState(GoRouterState state) => const FacesRoute();

  @override
  String get location => GoRouteData.$location('/more/faces');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $NotificationsRoute on GoRouteData {
  static NotificationsRoute _fromState(GoRouterState state) => const NotificationsRoute();

  @override
  String get location => GoRouteData.$location('/more/notifications');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $PlanRoute on GoRouteData {
  static PlanRoute _fromState(GoRouterState state) => const PlanRoute();

  @override
  String get location => GoRouteData.$location('/more/plan');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ActivityRoute on GoRouteData {
  static ActivityRoute _fromState(GoRouterState state) => const ActivityRoute();

  @override
  String get location => GoRouteData.$location('/more/activity');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AccountRoute on GoRouteData {
  static AccountRoute _fromState(GoRouterState state) => const AccountRoute();

  @override
  String get location => GoRouteData.$location('/more/account');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AppearanceRoute on GoRouteData {
  static AppearanceRoute _fromState(GoRouterState state) => const AppearanceRoute();

  @override
  String get location => GoRouteData.$location('/more/appearance');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $AboutRoute on GoRouteData {
  static AboutRoute _fromState(GoRouterState state) => const AboutRoute();

  @override
  String get location => GoRouteData.$location('/more/about');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) => context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
