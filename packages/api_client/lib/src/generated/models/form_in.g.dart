// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormIn _$FormInFromJson(Map<String, dynamic> json) => FormIn(
  code: json['code'] as String,
  title: json['title'] as String,
  numbering:
      $enumDecodeNullable(_$FormInNumberingEnumMap, json['numbering']) ??
      FormInNumbering.generated,
  description: json['description'] as String?,
  definition: json['definition'],
);

Map<String, dynamic> _$FormInToJson(FormIn instance) => <String, dynamic>{
  'code': instance.code,
  'title': instance.title,
  'description': instance.description,
  'numbering': instance.numbering,
  'definition': instance.definition,
};

const _$FormInNumberingEnumMap = {
  FormInNumbering.generated: 'generated',
  FormInNumbering.typed: 'typed',
};
