// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardIn _$CardInFromJson(Map<String, dynamic> json) => CardIn(
  title: json['title'] as String,
  actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
  reportTo: (json['report_to'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  reportNote: json['report_note'] as String?,
);

Map<String, dynamic> _$CardInToJson(CardIn instance) => <String, dynamic>{
  'title': instance.title,
  'actions': instance.actions,
  'report_to': instance.reportTo,
  'report_note': instance.reportNote,
};
