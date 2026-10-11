// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  const Category({
    required this.code,
    required this.name,
    required this.displayOrder,
  });

  factory Category.fromJson(Map<String, Object?> json) =>
      _$CategoryFromJson(json);

  final String code;
  final String name;
  @JsonKey(name: 'display_order')
  final int displayOrder;

  Map<String, Object?> toJson() => _$CategoryToJson(this);
}
