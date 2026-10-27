// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'record_row.dart';

part 'record_page.g.dart';

@JsonSerializable()
class RecordPage {
  const RecordPage({required this.total, required this.items});

  factory RecordPage.fromJson(Map<String, Object?> json) =>
      _$RecordPageFromJson(json);

  final int total;
  final List<RecordRow> items;

  Map<String, Object?> toJson() => _$RecordPageToJson(this);
}
