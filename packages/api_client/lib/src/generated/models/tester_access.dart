// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'assignment_out.dart';
import 'pending_confirmation.dart';
import 'sign_in.dart';
import 'tester_device.dart';

part 'tester_access.g.dart';

@JsonSerializable()
class TesterAccess {
  const TesterAccess({
    required this.assignments,
    required this.devices,
    required this.signIns,
    required this.pending,
  });
  
  factory TesterAccess.fromJson(Map<String, Object?> json) => _$TesterAccessFromJson(json);
  
  final List<AssignmentOut> assignments;
  final List<TesterDevice> devices;
  @JsonKey(name: 'sign_ins')
  final List<SignIn> signIns;
  final List<PendingConfirmation> pending;

  Map<String, Object?> toJson() => _$TesterAccessToJson(this);
}
