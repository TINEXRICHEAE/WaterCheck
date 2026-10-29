// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'contact_in_channel.dart';

part 'contact_in.g.dart';

@JsonSerializable()
class ContactIn {
  const ContactIn({required this.channel, required this.value});

  factory ContactIn.fromJson(Map<String, Object?> json) =>
      _$ContactInFromJson(json);

  final ContactInChannel channel;
  final String value;

  Map<String, Object?> toJson() => _$ContactInToJson(this);
}
