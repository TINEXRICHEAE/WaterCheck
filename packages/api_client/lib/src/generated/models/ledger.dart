// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

import 'ledger_account.dart';
import 'ledger_code.dart';

part 'ledger.g.dart';

@JsonSerializable()
class Ledger {
  const Ledger({
    required this.codes,
    required this.accounts,
  });
  
  factory Ledger.fromJson(Map<String, Object?> json) => _$LedgerFromJson(json);
  
  final List<LedgerCode> codes;
  final List<LedgerAccount> accounts;

  Map<String, Object?> toJson() => _$LedgerToJson(this);
}
