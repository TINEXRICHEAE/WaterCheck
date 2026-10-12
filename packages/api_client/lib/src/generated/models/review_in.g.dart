// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewIn _$ReviewInFromJson(Map<String, dynamic> json) => ReviewIn(
  action: $enumDecode(_$ReviewInActionEnumMap, json['action']),
  name: json['name'] as String?,
  mergeInto: json['merge_into'] as String?,
);

Map<String, dynamic> _$ReviewInToJson(ReviewIn instance) => <String, dynamic>{
  'action': instance.action,
  'name': instance.name,
  'merge_into': instance.mergeInto,
};

const _$ReviewInActionEnumMap = {
  ReviewInAction.approve: 'approve',
  ReviewInAction.rename: 'rename',
  ReviewInAction.merge: 'merge',
  ReviewInAction.reject: 'reject',
};
