import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_bridge/push_bridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/app/backend.dart';
import 'package:smart_surveillance/app/router.dart';
import 'package:smart_surveillance/app/routes.dart';
import 'package:smart_surveillance/features/events/domain/models.dart';

part 'alert_center.g.dart';
/// Delivers local and push notifications for camera events and opens the tapped event.
class AlertCenter with WidgetsBindingObserver {
  /// Creates an alert center that reads events from [backend] and navigates through [open].
  AlertCenter(this.backend, this.open, {this.enabled = true});

  /// The backend used to register push targets and load events.
  final Backend backend;
  /// Navigates the app to a route location.
  final void Function(String location) open;
  /// Whether notifications are shown at all.
  final bool enabled;
  /// The local notifications plugin that displays alerts.
  final plugin = FlutterLocalNotificationsPlugin();
  /// The platform push bridge that supplies tokens and incoming messages.
  final PushBridge push = createPushBridge();
  /// The last known app lifecycle state, used to skip alerts while the app is in the foreground.
  AppLifecycleState lifecycle = AppLifecycleState.resumed;
  /// Whether [start] has already initialised the plugin.
  bool ready = false;
  /// The subscription to incoming push messages.
  StreamSubscription<PushMessage>? messages;
  /// The subscription to push token changes.
  StreamSubscription<String>? tokens;
  /// The id given to the next notification shown.
  int next = 1;

  /// The name of the push provider in use.
  String get provider => push.provider;

  /// Whether the platform offers a push provider.
  bool get pushAvailable => push.available;

  /// Initialises notifications, creates the alert channel and starts listening for push messages.
  ///
  /// [channelName] and [channelBody] label the Android notification channel. Does nothing when
  /// notifications are disabled or already started.
  Future<void> start({required String channelName, required String channelBody}) async {
    if (!enabled || ready) return;
    ready = true;
    WidgetsBinding.instance.addObserver(this);
    await plugin.initialize(
      settings: const InitializationSettings(android: AndroidInitializationSettings('@drawable/ic_notification')),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) open(EventRoute(eventId: payload).location);
      },
    );
    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          AndroidNotificationChannel('alerts', channelName, description: channelBody, importance: Importance.high),
        );
    if (!push.available) return;
    await push.start();
    final token = await push.token();
    if (token != null) await backend.notifications.registerPushTarget(provider: push.provider, token: token);
    tokens = push.tokenChanges.listen(
      (token) => backend.notifications.registerPushTarget(provider: push.provider, token: token),
    );
    messages = push.messages.listen((message) {
      final eventId = message.data['event_id'];
      if (eventId == null) return;
      if (message.opened) {
        open(EventRoute(eventId: eventId).location);
      } else {
        unawaited(fetchAndShow(eventId));
      }
    });
  }

  /// Asks the user for notification permission and returns whether it was granted.
  Future<bool> requestPermission() async {
    final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  /// Loads the event [eventId] and shows a notification for it, ignoring failures.
  Future<void> fetchAndShow(String eventId) async {
    try {
      final event = await backend.events.event(eventId);
      await show(event, event.cameraName);
    } catch (_) {}
  }

  /// Shows a notification for [event] under [title].
  Future<void> show(CameraEvent event, String title) async {
    if (!enabled || !ready) return;
    await plugin.show(
      id: next++,
      title: title,
      body: event.label == null ? event.cameraName : '${event.cameraName}: ${event.label}',
      payload: event.id,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'alerts',
          'Alerts',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
        ),
      ),
    );
  }

  /// Shows a notification for [event] on [siteName] unless the app is in the foreground.
  void alert(CameraEvent event, String siteName) {
    if (lifecycle == AppLifecycleState.resumed) return;
    unawaited(show(event, siteName));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => lifecycle = state;

  /// Stops listening for push messages and token changes.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(messages?.cancel());
    unawaited(tokens?.cancel());
  }
}

/// Provides the alert center for the signed-in backend.
@Riverpod(keepAlive: true)
AlertCenter alertCenter(Ref ref) {
  final center = AlertCenter(
    ref.watch(backendProvider),
    (location) => ref.read(routerProvider).push(location),
    enabled: ref.watch(notificationsEnabledProvider),
  );
  ref.onDispose(center.dispose);
  return center;
}

/// Provides whether notifications are enabled.
@Riverpod(keepAlive: true)
bool notificationsEnabled(Ref ref) => true;
