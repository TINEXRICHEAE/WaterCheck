// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'link_in_kind.dart';

part 'link_in.g.dart';

@JsonSerializable()
class LinkIn {
  const LinkIn({required this.kind});

  factory LinkIn.fromJson(Map<String, Object?> json) => _$LinkInFromJson(json);

  final LinkInKind kind;

  Map<String, Object?> toJson() => _$LinkInToJson(this);
}
