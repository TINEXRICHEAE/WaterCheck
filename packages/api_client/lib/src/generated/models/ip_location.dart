// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'ip_location.g.dart';

@JsonSerializable()
class IpLocation {
  const IpLocation({
    required this.lat,
    required this.lon,
    required this.accuracyM,
    required this.city,
    required this.region,
    required this.country,
  });
  
  factory IpLocation.fromJson(Map<String, Object?> json) => _$IpLocationFromJson(json);
  
  final num lat;
  final num lon;
  @JsonKey(name: 'accuracy_m')
  final num accuracyM;
  final String? city;
  final String? region;
  final String? country;

  Map<String, Object?> toJson() => _$IpLocationToJson(this);
}
