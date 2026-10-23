// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ledger _$LedgerFromJson(Map<String, dynamic> json) => Ledger(
  codes: (json['codes'] as List<dynamic>)
      .map((e) => LedgerCode.fromJson(e as Map<String, dynamic>))
      .toList(),
  accounts: (json['accounts'] as List<dynamic>)
      .map((e) => LedgerAccount.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LedgerToJson(Ledger instance) => <String, dynamic>{
  'codes': instance.codes,
  'accounts': instance.accounts,
};
