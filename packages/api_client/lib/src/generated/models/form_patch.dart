// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'form_patch_collect_access.dart';
import 'form_patch_status.dart';
import 'form_patch_visibility.dart';

part 'form_patch.g.dart';

@JsonSerializable()
class FormPatch {
  const FormPatch({
    this.visibility,
    this.collectAccess,
    this.hidden,
    this.status,
  });

  factory FormPatch.fromJson(Map<String, Object?> json) =>
      _$FormPatchFromJson(json);

  final FormPatchVisibility? visibility;
  @JsonKey(name: 'collect_access')
  final FormPatchCollectAccess? collectAccess;
  final bool? hidden;
  final FormPatchStatus? status;

  Map<String, Object?> toJson() => _$FormPatchToJson(this);
}
