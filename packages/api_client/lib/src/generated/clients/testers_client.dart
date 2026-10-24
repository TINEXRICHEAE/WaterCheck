// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/assign_area_in.dart';
import '../models/assign_in.dart';
import '../models/assignment_out.dart';
import '../models/confirm_in.dart';
import '../models/own_code_out.dart';
import '../models/sign_out_done.dart';
import '../models/sign_out_in.dart';
import '../models/sign_out_requested.dart';
import '../models/tester_access.dart';
import '../models/tester_device.dart';

part 'testers_client.g.dart';

@RestApi()
abstract class TestersClient {
  factory TestersClient(Dio dio, {String? baseUrl}) = _TestersClient;

  /// Assign With Code.
  ///
  /// An assignment code from an IT admin puts the tester officially in its.
  /// area. The code works for as many testers as it was made for.
  @POST('/v1/collectors/{collector_key}/assign')
  Future<List<AssignmentOut>> assignWithCode({
    @Path('collector_key') required String collectorKey,
    @Body() required AssignIn body,
  });

  /// Tester Assignments
  @GET('/v1/collectors/{collector_key}/assignments')
  Future<List<AssignmentOut>> testerAssignments({
    @Path('collector_key') required String collectorKey,
  });

  /// Own Recovery Code.
  ///
  /// A tester's own sign-in code for another device: one use, valid until.
  /// used. Shown once; only its hash is kept.
  @POST('/v1/collectors/{collector_key}/recovery-code/own')
  Future<OwnCodeOut> ownRecoveryCode({
    @Path('collector_key') required String collectorKey,
  });

  /// Tester Devices
  @GET('/v1/collectors/{collector_key}/devices')
  Future<List<TesterDevice>> testerDevices({
    @Path('collector_key') required String collectorKey,
  });

  /// Request Sign Out.
  ///
  /// Asks to sign the tester out of other devices. A code confirms it:.
  /// sent by email or SMS later; for now IT admins see it on the tester's.
  /// page and pass it on.
  @POST('/v1/collectors/{collector_key}/devices/sign-out')
  Future<SignOutRequested> requestSignOut({
    @Path('collector_key') required String collectorKey,
    @Body() required SignOutIn body,
  });

  /// Confirm Sign Out
  @POST('/v1/collectors/{collector_key}/devices/sign-out/{request_id}/confirm')
  Future<SignOutDone> confirmSignOut({
    @Path('collector_key') required String collectorKey,
    @Path('request_id') required String requestId,
    @Body() required ConfirmIn body,
  });

  /// All Assignments.
  ///
  /// Current assignments, so the Console can tell assigned testers.
  @GET('/v1/collectors/assignments')
  Future<List<AssignmentOut>> allAssignments();

  /// Tester Access.
  ///
  /// A tester's areas, devices, sign-ins, and codes waiting to be passed on.
  @GET('/v1/admin/collectors/{collector_key}/access')
  Future<TesterAccess> testerAccess({
    @Path('collector_key') required String collectorKey,
  });

  /// Assign Directly.
  ///
  /// An IT admin assigns a tester to an area without a code.
  @POST('/v1/admin/collectors/{collector_key}/assignments')
  Future<List<AssignmentOut>> assignDirectly({
    @Path('collector_key') required String collectorKey,
    @Body() required AssignAreaIn body,
  });

  /// End Assignment
  @POST('/v1/admin/collectors/{collector_key}/assignments/{assignment_id}/end')
  Future<List<AssignmentOut>> endAssignment({
    @Path('collector_key') required String collectorKey,
    @Path('assignment_id') required String assignmentId,
  });
}
