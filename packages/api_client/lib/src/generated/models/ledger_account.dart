// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:json_annotation/json_annotation.dart';

part 'ledger_account.g.dart';

/// A Console account: who made it, and whether and when it was used.
@JsonSerializable()
class LedgerAccount {
  const LedgerAccount({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.createdBy,
    required this.createdAt,
    required this.firstSignInDone,
    required this.lastSignInAt,
    required this.isActive,
    required this.areas,
  });
  
  factory LedgerAccount.fromJson(Map<String, Object?> json) => _$LedgerAccountFromJson(json);
  
  final String id;
  final String username;
  @JsonKey(name: 'full_name')
  final String fullName;
  final String role;
  @JsonKey(name: 'created_by')
  final String? createdBy;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'first_sign_in_done')
  final bool firstSignInDone;
  @JsonKey(name: 'last_sign_in_at')
  final DateTime? lastSignInAt;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<String> areas;

  Map<String, Object?> toJson() => _$LedgerAccountToJson(this);
}
