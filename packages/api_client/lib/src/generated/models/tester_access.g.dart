// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tester_access.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TesterAccess _$TesterAccessFromJson(Map<String, dynamic> json) => TesterAccess(
  assignments: (json['assignments'] as List<dynamic>)
      .map((e) => AssignmentOut.fromJson(e as Map<String, dynamic>))
      .toList(),
  devices: (json['devices'] as List<dynamic>)
      .map((e) => TesterDevice.fromJson(e as Map<String, dynamic>))
      .toList(),
  signIns: (json['sign_ins'] as List<dynamic>)
      .map((e) => SignIn.fromJson(e as Map<String, dynamic>))
      .toList(),
  pending: (json['pending'] as List<dynamic>)
      .map((e) => PendingConfirmation.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$TesterAccessToJson(TesterAccess instance) =>
    <String, dynamic>{
      'assignments': instance.assignments,
      'devices': instance.devices,
      'sign_ins': instance.signIns,
      'pending': instance.pending,
    };
