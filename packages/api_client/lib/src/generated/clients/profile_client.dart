// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/area_request_in.dart';
import '../models/area_request_out.dart';
import '../models/close_in.dart';
import '../models/code_to_pass.dart';
import '../models/confirm_in.dart';
import '../models/contact_in.dart';
import '../models/contact_pending.dart';
import '../models/decide_in.dart';
import '../models/legal_in.dart';
import '../models/profile_in.dart';
import '../models/side.dart';

part 'profile_client.g.dart';

@RestApi()
abstract class ProfileClient {
  factory ProfileClient(Dio dio, {String? baseUrl}) = _ProfileClient;

  /// Edit Profile
  @PUT('/v1/me/profile')
  Future<void> editProfile({@Body() required ProfileIn body});

  /// Change Contact.
  ///
  /// Saves a new email or phone as not confirmed and makes a code.
  @POST('/v1/me/contacts')
  Future<ContactPending> changeContact({@Body() required ContactIn body});

  /// Confirm Contact
  @POST('/v1/me/contacts/{request_id}/confirm')
  Future<void> confirmContact({
    @Path('request_id') required String requestId,
    @Body() required ConfirmIn body,
  });

  /// Contact Status
  @GET('/v1/me/contacts/status')
  Future<Map<String, bool>> contactStatus();

  /// My Area Requests
  @GET('/v1/me/area-requests')
  Future<List<AreaRequestOut>> myAreaRequests();

  /// Request Areas.
  ///
  /// Asks the IT admin for different areas (replacing the current ones).
  @POST('/v1/me/area-requests')
  Future<List<AreaRequestOut>> requestAreas({
    @Body() required AreaRequestIn body,
  });

  /// Accept Legal.
  ///
  /// Records that the person accepted this version of the Privacy Policy.
  /// and Terms of Use (the version only goes up).
  @POST('/v1/me/legal')
  Future<void> acceptLegal({@Body() required LegalIn body});

  /// Close Account.
  ///
  /// Closes the account for good: no more sign-in, contact details erased,.
  /// every session ended. Records already made stay, under the name.
  @POST('/v1/me/close')
  Future<void> closeAccount({@Body() required CloseIn body});

  /// Tester Contact
  @POST('/v1/collectors/{collector_key}/contacts')
  Future<ContactPending> testerContact({
    @Path('collector_key') required String collectorKey,
    @Body() required ContactIn body,
  });

  /// Tester Confirm Contact
  @POST('/v1/collectors/{collector_key}/contacts/{request_id}/confirm')
  Future<void> testerConfirmContact({
    @Path('collector_key') required String collectorKey,
    @Path('request_id') required String requestId,
    @Body() required ConfirmIn body,
  });

  /// Tester Contact Status
  @GET('/v1/collectors/{collector_key}/contacts/status')
  Future<Map<String, String?>> testerContactStatus({
    @Path('collector_key') required String collectorKey,
  });

  /// Tester Sign Out Here.
  ///
  /// The tester leaves this device; a sign-in code brings them back.
  @POST('/v1/collectors/{collector_key}/sign-out-here')
  Future<void> testerSignOutHere({
    @Path('collector_key') required String collectorKey,
  });

  /// Tester Close.
  ///
  /// Deletes the tester's profile: every device signed out, assignments.
  /// ended, contact details erased. Their tests and sources stay.
  @POST('/v1/collectors/{collector_key}/close')
  Future<void> testerClose({
    @Path('collector_key') required String collectorKey,
  });

  /// Codes To Pass.
  ///
  /// Every confirmation code waiting for an IT admin to give by phone;.
  /// with `side`, those of that side's people (ADR-031).
  @GET('/v1/admin/codes-to-pass')
  Future<List<CodeToPass>> codesToPass({@Query('side') Side? side});

  /// Area Requests
  @GET('/v1/admin/area-requests')
  Future<List<AreaRequestOut>> areaRequests();

  /// Decide Area Request.
  ///
  /// Approving replaces the person's areas with those asked for.
  @POST('/v1/admin/area-requests/{request_id}/decide')
  Future<List<AreaRequestOut>> decideAreaRequest({
    @Path('request_id') required String requestId,
    @Body() required DecideIn body,
  });
}
