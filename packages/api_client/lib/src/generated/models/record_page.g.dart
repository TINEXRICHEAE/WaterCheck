// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record_page.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecordPage _$RecordPageFromJson(Map<String, dynamic> json) => RecordPage(
  total: (json['total'] as num).toInt(),
  items: (json['items'] as List<dynamic>)
      .map((e) => RecordRow.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RecordPageToJson(RecordPage instance) =>
    <String, dynamic>{'total': instance.total, 'items': instance.items};
