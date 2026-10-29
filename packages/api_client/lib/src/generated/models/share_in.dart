// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'share_in.g.dart';

@JsonSerializable()
class ShareIn {
  const ShareIn({
    required this.username,
  });
  
  factory ShareIn.fromJson(Map<String, Object?> json) => _$ShareInFromJson(json);
  
  final String username;

  Map<String, Object?> toJson() => _$ShareInToJson(this);
}
