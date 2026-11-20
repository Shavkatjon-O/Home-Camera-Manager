import 'dart:async';

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

PushBridge createPushBridge() => const NoPushBridge();

class NoPushBridge implements PushBridge {
  const NoPushBridge();

  @override
  String get provider => 'none';

  @override
  bool get available => false;

  @override
  Future<void> start() async {}

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get tokenChanges => const Stream.empty();

  @override
  Stream<PushMessage> get messages => const Stream.empty();
}
