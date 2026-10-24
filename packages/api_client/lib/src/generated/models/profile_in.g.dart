// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileIn _$ProfileInFromJson(Map<String, dynamic> json) => ProfileIn(
  fullName: json['full_name'] as String,
  organisation: json['organisation'] as String?,
  position: json['position'] as String?,
);

Map<String, dynamic> _$ProfileInToJson(ProfileIn instance) => <String, dynamic>{
  'full_name': instance.fullName,
  'organisation': instance.organisation,
  'position': instance.position,
};
