// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'form_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FormPatch _$FormPatchFromJson(Map<String, dynamic> json) => FormPatch(
  visibility: $enumDecodeNullable(
    _$FormPatchVisibilityEnumMap,
    json['visibility'],
  ),
  collectAccess: $enumDecodeNullable(
    _$FormPatchCollectAccessEnumMap,
    json['collect_access'],
  ),
  hidden: json['hidden'] as bool?,
  status: $enumDecodeNullable(_$FormPatchStatusEnumMap, json['status']),
);

Map<String, dynamic> _$FormPatchToJson(FormPatch instance) => <String, dynamic>{
  'visibility': instance.visibility,
  'collect_access': instance.collectAccess,
  'hidden': instance.hidden,
  'status': instance.status,
};

const _$FormPatchVisibilityEnumMap = {
  FormPatchVisibility.public: 'public',
  FormPatchVisibility.private: 'private',
  FormPatchVisibility.shared: 'shared',
};

const _$FormPatchCollectAccessEnumMap = {
  FormPatchCollectAccess.assigned: 'assigned',
  FormPatchCollectAccess.code: 'code',
  FormPatchCollectAccess.open: 'open',
};

const _$FormPatchStatusEnumMap = {
  FormPatchStatus.published: 'published',
  FormPatchStatus.closed: 'closed',
};
