// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'source_hit.g.dart';

@JsonSerializable()
class SourceHit {
  const SourceHit({
    required this.id,
    required this.code,
    required this.name,
    required this.villageId,
    required this.village,
    required this.districtId,
    required this.district,
    required this.lat,
    required this.lon,
    required this.latest,
  });
  
  factory SourceHit.fromJson(Map<String, Object?> json) => _$SourceHitFromJson(json);
  
  final String id;
  final String code;
  final String? name;
  @JsonKey(name: 'village_id')
  final String villageId;
  final String village;
  @JsonKey(name: 'district_id')
  final String? districtId;
  final String? district;
  final num? lat;
  final num? lon;
  final String? latest;

  Map<String, Object?> toJson() => _$SourceHitToJson(this);
}
