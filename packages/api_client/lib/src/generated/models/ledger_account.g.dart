// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LedgerAccount _$LedgerAccountFromJson(Map<String, dynamic> json) =>
    LedgerAccount(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      role: json['role'] as String,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      firstSignInDone: json['first_sign_in_done'] as bool,
      lastSignInAt: json['last_sign_in_at'] == null
          ? null
          : DateTime.parse(json['last_sign_in_at'] as String),
      isActive: json['is_active'] as bool,
      areas: (json['areas'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$LedgerAccountToJson(LedgerAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'full_name': instance.fullName,
      'role': instance.role,
      'created_by': instance.createdBy,
      'created_at': instance.createdAt.toIso8601String(),
      'first_sign_in_done': instance.firstSignInDone,
      'last_sign_in_at': instance.lastSignInAt?.toIso8601String(),
      'is_active': instance.isActive,
      'areas': instance.areas,
    };
