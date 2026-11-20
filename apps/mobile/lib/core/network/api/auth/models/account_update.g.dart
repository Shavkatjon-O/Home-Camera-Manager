// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountUpdate _$AccountUpdateFromJson(Map<String, dynamic> json) =>
    AccountUpdate(
      name: json['name'] as String?,
      additionalProperties:
          AccountUpdate._extras(json, 'additionalProperties') == null
          ? const {}
          : AccountUpdate._readExtras(
              AccountUpdate._extras(json, 'additionalProperties'),
            ),
    );

Map<String, dynamic> _$AccountUpdateToJson(AccountUpdate instance) =>
    <String, dynamic>{'name': ?instance.name};
