// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'place_at.g.dart';

@JsonSerializable()
class PlaceAt {
  const PlaceAt({
    required this.subcountyId,
    required this.subcounty,
    required this.districtId,
    required this.district,
  });
  
  factory PlaceAt.fromJson(Map<String, Object?> json) => _$PlaceAtFromJson(json);
  
  @JsonKey(name: 'subcounty_id')
  final String subcountyId;
  final String subcounty;
  @JsonKey(name: 'district_id')
  final String? districtId;
  final String? district;

  Map<String, Object?> toJson() => _$PlaceAtToJson(this);
}
