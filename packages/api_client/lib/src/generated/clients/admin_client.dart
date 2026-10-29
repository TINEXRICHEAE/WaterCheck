// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/acceptance_out.dart';
import '../models/activation_code_out.dart';
import '../models/archive_in.dart';
import '../models/archive_out.dart';
import '../models/archived_item.dart';
import '../models/audit_entry.dart';
import '../models/card_in.dart';
import '../models/card_out.dart';
import '../models/chain_out.dart';
import '../models/credentials_out.dart';
import '../models/default_profile_in.dart';
import '../models/device_collector.dart';
import '../models/health.dart';
import '../models/installation_out.dart';
import '../models/label_in.dart';
import '../models/ledger.dart';
import '../models/new_area_in.dart';
import '../models/new_place.dart';
import '../models/new_user_in.dart';
import '../models/pending_parameter.dart';
import '../models/place_out.dart';
import '../models/rename_in.dart';
import '../models/responsibility.dart';
import '../models/review_in.dart';
import '../models/routing.dart';
import '../models/routing_in.dart';
import '../models/security_in.dart';
import '../models/side.dart';
import '../models/typed_value.dart';
import '../models/typed_value_in.dart';
import '../models/user_changes_in.dart';
import '../models/user_out.dart';

part 'admin_client.g.dart';

@RestApi()
abstract class AdminClient {
  factory AdminClient(Dio dio, {String? baseUrl}) = _AdminClient;

  /// Activation Codes.
  ///
  /// Recent codes; the codes themselves were shown once and are not stored.
  @GET('/v1/admin/activation-codes')
  Future<List<ActivationCodeOut>> activationCodes();

  /// Users.
  ///
  /// Console accounts; with `side`, that side's accounts and the IT admins,.
  /// who work on every side (ADR-031).
  @GET('/v1/admin/users')
  Future<List<UserOut>> users({@Query('side') Side? side});

  /// New User
  @POST('/v1/admin/users')
  Future<CredentialsOut> newUser({@Body() required NewUserIn body});

  /// Change User
  @PATCH('/v1/admin/users/{user_id}')
  Future<UserOut> changeUser({
    @Path('user_id') required String userId,
    @Body() required UserChangesIn body,
  });

  /// Reset Password
  @POST('/v1/admin/users/{user_id}/reset-password')
  Future<CredentialsOut> resetPassword({
    @Path('user_id') required String userId,
  });

  /// Installations.
  ///
  /// Devices; with `side`, those its testers use. `tests` counts that.
  /// side's records (water tests or research records).
  @GET('/v1/admin/installations')
  Future<List<InstallationOut>> installations({@Query('side') Side? side});

  /// Installation Collectors.
  ///
  /// The collectors and testers seen on one device. People added on the.
  /// device who never sent anything are not known to the server yet.
  @GET('/v1/admin/installations/{installation_id}/collectors')
  Future<List<DeviceCollector>> installationCollectors({
    @Path('installation_id') required String installationId,
  });

  /// Credentials.
  ///
  /// Every activation code and Console account made, by whom, for which.
  /// area, and their use: devices activated, first and last sign-in.
  /// (ADR-022). The codes and passwords themselves are never stored.
  @GET('/v1/admin/credentials')
  Future<Ledger> credentials({@Query('side') Side? side});

  /// Revoke Code.
  ///
  /// Withdraws an unused or partly used code; devices already activated.
  /// with it keep working (revoke those one by one).
  @POST('/v1/admin/activation-codes/{code_id}/revoke')
  Future<void> revokeCode({@Path('code_id') required String codeId});

  /// Chain
  @GET('/v1/admin/areas/{area_id}/chain')
  Future<ChainOut> chain({@Path('area_id') required String areaId});

  /// Legal Acceptances.
  ///
  /// Each time an account or a tester accepted a side's Terms of Use and.
  /// Privacy Policy (ADR-031): kept for accountability, newest first.
  @GET('/v1/admin/legal-acceptances')
  Future<List<AcceptanceOut>> legalAcceptances({
    @Query('user_id') String? userId,
    @Query('collector_key') String? collectorKey,
  });

  /// Audit
  @GET('/v1/admin/audit')
  Future<List<AuditEntry>> audit({
    @Query('limit') int? limit = 200,
    @Query('action') String? action,
    @Query('entity') String? entity,
    @Query('actor_id') String? actorId,
    @Query('installation_id') String? installationId,
    @Query('since') DateTime? since,
    @Query('until') DateTime? until,
  });

  /// Audit Csv.
  ///
  /// The same filters as a CSV file (UTF-8, ISO dates).
  @GET('/v1/admin/audit.csv')
  Future<String> auditCsv({
    @Query('limit') int? limit = 10000,
    @Query('action') String? action,
    @Query('entity') String? entity,
    @Query('actor_id') String? actorId,
    @Query('installation_id') String? installationId,
    @Query('since') DateTime? since,
    @Query('until') DateTime? until,
  });

  /// System Health.
  ///
  /// DevOps view (F-ADM-6). Backups come with deployment (P12); until.
  /// then `last_backup_at` stays empty.
  @GET('/v1/admin/health')
  Future<Health> systemHealth();

  /// New Area.
  ///
  /// Adds a sub-county, parish or village (the official list stops at.
  /// sub-counties). Its code extends the parent's.
  @POST('/v1/admin/areas')
  Future<PlaceOut> newArea({@Body() required NewAreaIn body});

  /// Rename Area
  @PATCH('/v1/admin/areas/{area_id}')
  Future<PlaceOut> renameArea({
    @Path('area_id') required String areaId,
    @Body() required RenameIn body,
  });

  /// New Places
  @GET('/v1/admin/areas/new')
  Future<List<NewPlace>> newPlaces();

  /// Mark Place Official.
  ///
  /// Accepts a place added from a device into the list.
  @POST('/v1/admin/areas/{area_id}/official')
  Future<void> markPlaceOfficial({@Path('area_id') required String areaId});

  /// Get Default Profile.
  ///
  /// The limit set set on this area itself (empty: it inherits).
  @GET('/v1/admin/areas/{area_id}/default-profile')
  Future<DefaultProfileIn> getDefaultProfile({
    @Path('area_id') required String areaId,
  });

  /// Default Profile.
  ///
  /// The limit set phones in this area start with (cleared: inherit).
  @PUT('/v1/admin/areas/{area_id}/default-profile')
  Future<void> defaultProfile({
    @Path('area_id') required String areaId,
    @Body() required DefaultProfileIn body,
  });

  /// Routing
  @GET('/v1/admin/routing')
  Future<Routing> routing();

  /// Set Routing.
  ///
  /// Replaces the routing table: which alert types reach which.
  /// responsibilities (people with none get everything in their areas).
  @PUT('/v1/admin/routing')
  Future<void> setRouting({@Body() required RoutingIn body});

  /// New Responsibility
  @POST('/v1/admin/responsibilities')
  Future<Responsibility> newResponsibility({
    @Body() required Responsibility body,
  });

  /// Get Security
  @GET('/v1/admin/security')
  Future<SecurityIn> getSecurity();

  /// Set Security
  @PUT('/v1/admin/security')
  Future<SecurityIn> setSecurity({@Body() required SecurityIn body});

  /// Typed Values.
  ///
  /// Values typed under "Other" that the shared lists do not have yet.
  @GET('/v1/admin/typed-values')
  Future<List<TypedValue>> typedValues();

  /// Add Typed Value.
  ///
  /// Adds a typed value to the shared list, before "Other"; devices get.
  /// it with the next sync.
  @POST('/v1/admin/typed-values')
  Future<void> addTypedValue({@Body() required TypedValueIn body});

  /// Pending Parameters
  @GET('/v1/admin/parameters/pending')
  Future<List<PendingParameter>> pendingParameters();

  /// Review Parameter.
  ///
  /// Approve, rename, merge into a catalogue parameter (readings keep their.
  /// original code and stay traceable through `merged_into`) or reject.
  @POST('/v1/admin/parameters/{code}/review')
  Future<void> reviewParameter({
    @Path('code') required String code,
    @Body() required ReviewIn body,
  });

  /// Admin Response Cards
  @GET('/v1/admin/response-cards')
  Future<List<CardOut>> adminResponseCards();

  /// Edit Card.
  ///
  /// A new version of the card; phones get it with the reference data.
  @PUT('/v1/admin/response-cards/{card_id}')
  Future<CardOut> editCard({
    @Path('card_id') required String cardId,
    @Body() required CardIn body,
  });

  /// Archived.
  ///
  /// Archive actions that can still be restored, newest first.
  @GET('/v1/admin/archive')
  Future<List<ArchivedItem>> archived();

  /// Archive Record.
  ///
  /// Archives a record and what cascades from it (restorable).
  @POST('/v1/admin/archive')
  Future<ArchiveOut> archiveRecord({@Body() required ArchiveIn body});

  /// Restore.
  ///
  /// Brings back everything one archive action hid. A restored phone stays.
  /// revoked: issue it a new activation code.
  @POST('/v1/admin/archive/{batch_id}/restore')
  Future<Map<String, int>> restore({@Path('batch_id') required String batchId});

  /// Name Installation.
  ///
  /// Names a phone ("Nalongo's phone"); the change is kept in its trail.
  @PATCH('/v1/admin/installations/{installation_id}')
  Future<void> nameInstallation({
    @Path('installation_id') required String installationId,
    @Body() required LabelIn body,
  });
}
