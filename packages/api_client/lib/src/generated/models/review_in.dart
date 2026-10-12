// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'review_in_action.dart';

part 'review_in.g.dart';

@JsonSerializable()
class ReviewIn {
  const ReviewIn({required this.action, this.name, this.mergeInto});

  factory ReviewIn.fromJson(Map<String, Object?> json) =>
      _$ReviewInFromJson(json);

  final ReviewInAction action;
  final String? name;
  @JsonKey(name: 'merge_into')
  final String? mergeInto;

  Map<String, Object?> toJson() => _$ReviewInToJson(this);
}
