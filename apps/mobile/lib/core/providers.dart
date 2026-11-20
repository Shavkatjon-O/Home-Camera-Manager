import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/core/config.dart';
import 'package:smart_surveillance/core/storage/preferences.dart';

part 'providers.g.dart';
/// The provider of the app configuration; it is overridden at start-up.
@Riverpod(keepAlive: true)
AppConfig config(Ref ref) => throw UnimplementedError();

/// The provider of the stored preferences; it is overridden at start-up.
@Riverpod(keepAlive: true)
Preferences preferences(Ref ref) => throw UnimplementedError();

/// The provider of the current time, replaceable in tests.
@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;
