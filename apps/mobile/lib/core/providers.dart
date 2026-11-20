import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_surveillance/core/config.dart';
import 'package:smart_surveillance/core/storage/preferences.dart';

part 'providers.g.dart';
@Riverpod(keepAlive: true)
AppConfig config(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
Preferences preferences(Ref ref) => throw UnimplementedError();

@Riverpod(keepAlive: true)
DateTime Function() clock(Ref ref) => DateTime.now;
