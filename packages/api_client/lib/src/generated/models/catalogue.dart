// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'category.dart';
import 'parameter.dart';

part 'catalogue.g.dart';

@JsonSerializable()
class Catalogue {
  const Catalogue({required this.categories, required this.parameters});

  factory Catalogue.fromJson(Map<String, Object?> json) =>
      _$CatalogueFromJson(json);

  final List<Category> categories;
  final List<Parameter> parameters;

  Map<String, Object?> toJson() => _$CatalogueToJson(this);
}
