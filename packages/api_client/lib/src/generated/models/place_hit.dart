// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'place_hit.g.dart';

/// A place by name (ADR-023): an official one from the area list, or a.
/// name from the map placed in its sub-county.
@JsonSerializable()
class PlaceHit {
  const PlaceHit({
    required this.id,
    required this.name,
    required this.kind,
    required this.source,
    required this.lat,
    required this.lon,
    required this.subcountyId,
    required this.subcounty,
    required this.districtId,
    required this.district,
    this.addedBy,
  });

  factory PlaceHit.fromJson(Map<String, Object?> json) =>
      _$PlaceHitFromJson(json);

  final String id;
  final String name;
  final String kind;
  final String source;
  final num? lat;
  final num? lon;
  @JsonKey(name: 'subcounty_id')
  final String? subcountyId;
  final String? subcounty;
  @JsonKey(name: 'district_id')
  final String? districtId;
  final String? district;
  @JsonKey(name: 'added_by')
  final String? addedBy;

  Map<String, Object?> toJson() => _$PlaceHitToJson(this);
}
