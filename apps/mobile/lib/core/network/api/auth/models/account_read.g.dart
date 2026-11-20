// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_read.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountRead _$AccountReadFromJson(Map<String, dynamic> json) {
  $checkKeys(
    json,
    requiredKeys: const [
      'uuid',
      'username',
      'email',
      'name',
      'email_verified',
      'created_at',
    ],
    disallowNullValues: const [
      'uuid',
      'username',
      'email_verified',
      'created_at',
    ],
  );
  return AccountRead(
    uuid: json['uuid'] as String,
    username: json['username'] as String,
    email: json['email'] as String?,
    name: json['name'] as String?,
    emailVerified: json['email_verified'] as bool,
    createdAt: AccountRead._read_createdAt(json['created_at']),
    additionalProperties:
        AccountRead._extras(json, 'additionalProperties') == null
        ? const {}
        : AccountRead._readExtras(
            AccountRead._extras(json, 'additionalProperties'),
          ),
  );
}

Map<String, dynamic> _$AccountReadToJson(AccountRead instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'username': instance.username,
      'email': instance.email,
      'name': instance.name,
      'email_verified': instance.emailVerified,
      'created_at': ?AccountRead._write_createdAt(instance.createdAt),
    };
