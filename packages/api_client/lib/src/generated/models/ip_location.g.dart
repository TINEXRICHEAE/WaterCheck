// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ip_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IpLocation _$IpLocationFromJson(Map<String, dynamic> json) => IpLocation(
  lat: json['lat'] as num,
  lon: json['lon'] as num,
  accuracyM: json['accuracy_m'] as num,
  city: json['city'] as String?,
  region: json['region'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$IpLocationToJson(IpLocation instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
      'accuracy_m': instance.accuracyM,
      'city': instance.city,
      'region': instance.region,
      'country': instance.country,
    };
