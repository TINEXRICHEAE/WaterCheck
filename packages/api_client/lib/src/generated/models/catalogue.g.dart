// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Catalogue _$CatalogueFromJson(Map<String, dynamic> json) => Catalogue(
  categories: (json['categories'] as List<dynamic>)
      .map((e) => Category.fromJson(e as Map<String, dynamic>))
      .toList(),
  parameters: (json['parameters'] as List<dynamic>)
      .map((e) => Parameter.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CatalogueToJson(Catalogue instance) => <String, dynamic>{
  'categories': instance.categories,
  'parameters': instance.parameters,
};
