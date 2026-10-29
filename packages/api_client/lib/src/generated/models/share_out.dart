// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'share_out.g.dart';

@JsonSerializable()
class ShareOut {
  const ShareOut({
    required this.userId,
    required this.name,
  });
  
  factory ShareOut.fromJson(Map<String, Object?> json) => _$ShareOutFromJson(json);
  
  @JsonKey(name: 'user_id')
  final String userId;
  final String? name;

  Map<String, Object?> toJson() => _$ShareOutToJson(this);
}
