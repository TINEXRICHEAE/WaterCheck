// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'collector_card.g.dart';

@JsonSerializable()
class CollectorCard {
  const CollectorCard({required this.shareCode, required this.discoverable});

  factory CollectorCard.fromJson(Map<String, Object?> json) =>
      _$CollectorCardFromJson(json);

  @JsonKey(name: 'share_code')
  final String shareCode;
  final bool discoverable;

  Map<String, Object?> toJson() => _$CollectorCardToJson(this);
}
