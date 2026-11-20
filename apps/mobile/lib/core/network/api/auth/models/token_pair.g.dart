// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_pair.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenPair _$TokenPairFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'access_token',
      'expires_in',
      'refresh_token',
      'refresh_expires_in',
      'session',
    ],
    disallowNullValues: const [
      'access_token',
      'token_type',
      'expires_in',
      'refresh_token',
      'refresh_expires_in',
      'session',
    ],
  );
  return TokenPair(
    accessToken: json['access_token'] as String,
    tokenType: TokenPair._presentValue(json, 'token_type') == null
        ? "Bearer"
        : TokenPair._read_tokenType(TokenPair._presentValue(json, 'token_type') as Object),
    expiresIn: TokenPair._read_expiresIn(json['expires_in']),
    refreshToken: json['refresh_token'] as String,
    refreshExpiresIn: TokenPair._read_refreshExpiresIn(json['refresh_expires_in']),
    session: SessionRead.fromJson(json['session'] as Map<String, dynamic>),
    additionalProperties: TokenPair._extras(json, 'additionalProperties') == null
        ? const {}
        : TokenPair._readExtras(TokenPair._extras(json, 'additionalProperties')),
  );
}

Map<String, dynamic> _$TokenPairToJson(TokenPair instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  'token_type': ?TokenPair._write_tokenType(instance.tokenType),
  'expires_in': ?TokenPair._write_expiresIn(instance.expiresIn),
  'refresh_token': instance.refreshToken,
  'refresh_expires_in': ?TokenPair._write_refreshExpiresIn(instance.refreshExpiresIn),
  'session': instance.session.toJson(),
};
