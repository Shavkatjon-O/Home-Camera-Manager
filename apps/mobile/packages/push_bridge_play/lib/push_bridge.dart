import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushMessage {
  const PushMessage({required this.data, required this.opened});

  final Map<String, String> data;
  final bool opened;
}

abstract interface class PushBridge {
  String get provider;

  bool get available;

  Future<void> start();

  Future<String?> token();

  Stream<String> get tokenChanges;

  Stream<PushMessage> get messages;
}

PushBridge createPushBridge() => FcmPushBridge();

Map<String, String> flatten(Map<String, dynamic> data) =>
    data.map((key, value) => MapEntry(key, '$value'));

@pragma('vm:entry-point')
Future<void> backgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FcmPushBridge implements PushBridge {
  final StreamController<PushMessage> controller = StreamController.broadcast();
  bool started = false;

  @override
  String get provider => 'fcm';

  @override
  bool get available => true;

  @override
  Future<void> start() async {
    if (started) return;
    started = true;
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(backgroundMessage);
    FirebaseMessaging.onMessage.listen(
      (message) => controller.add(PushMessage(data: flatten(message.data), opened: false)),
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => controller.add(PushMessage(data: flatten(message.data), opened: true)),
    );
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      controller.add(PushMessage(data: flatten(initial.data), opened: true));
    }
  }

  @override
  Future<String?> token() => FirebaseMessaging.instance.getToken();

  @override
  Stream<String> get tokenChanges => FirebaseMessaging.instance.onTokenRefresh;

  @override
  Stream<PushMessage> get messages => controller.stream;
}
