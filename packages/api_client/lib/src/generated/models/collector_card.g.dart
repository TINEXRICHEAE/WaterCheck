// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collector_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectorCard _$CollectorCardFromJson(Map<String, dynamic> json) =>
    CollectorCard(
      shareCode: json['share_code'] as String,
      discoverable: json['discoverable'] as bool,
    );

Map<String, dynamic> _$CollectorCardToJson(CollectorCard instance) =>
    <String, dynamic>{
      'share_code': instance.shareCode,
      'discoverable': instance.discoverable,
    };
