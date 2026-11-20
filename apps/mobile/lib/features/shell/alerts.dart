import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:push_bridge/push_bridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/routes.dart';
import '../../data/models/event.dart';
import '../../data/repositories.dart';

part 'alerts.g.dart';

class AlertCenter with WidgetsBindingObserver {
  AlertCenter(this.backend, this.open, {this.enabled = true});

  final Backend backend;
  final void Function(String location) open;
  final bool enabled;
  final plugin = FlutterLocalNotificationsPlugin();
  final PushBridge push = createPushBridge();
  AppLifecycleState lifecycle = AppLifecycleState.resumed;
  bool ready = false;
  StreamSubscription<PushMessage>? messages;
  StreamSubscription<String>? tokens;
  int next = 1;

  String get provider => push.provider;

  bool get pushAvailable => push.available;

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

  Future<bool> requestPermission() async {
    final android = plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<void> fetchAndShow(String eventId) async {
    try {
      final event = await backend.events.event(eventId);
      await show(event, event.cameraName);
    } catch (_) {}
  }

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

  void alert(CameraEvent event, String siteName) {
    if (lifecycle == AppLifecycleState.resumed) return;
    unawaited(show(event, siteName));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => lifecycle = state;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(messages?.cancel());
    unawaited(tokens?.cancel());
  }
}

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

@Riverpod(keepAlive: true)
bool notificationsEnabled(Ref ref) => true;
