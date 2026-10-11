// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChainPerson _$ChainPersonFromJson(Map<String, dynamic> json) => ChainPerson(
  id: json['id'] as String,
  fullName: json['full_name'] as String,
  responsibilities: (json['responsibilities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  isActive: json['is_active'] as bool,
);

Map<String, dynamic> _$ChainPersonToJson(ChainPerson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'full_name': instance.fullName,
      'responsibilities': instance.responsibilities,
      'is_active': instance.isActive,
    };
