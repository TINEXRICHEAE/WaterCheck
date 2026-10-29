// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/clone_in.dart';
import '../models/collector_assign_in.dart';
import '../models/collector_detail.dart';
import '../models/collector_out.dart';
import '../models/device_forms.dart';
import '../models/draft_in.dart';
import '../models/editor_in.dart';
import '../models/form_detail.dart';
import '../models/form_in.dart';
import '../models/form_out.dart';
import '../models/form_patch.dart';
import '../models/form_records.dart';
import '../models/join_in.dart';
import '../models/join_out.dart';
import '../models/library_form.dart';
import '../models/member_in.dart';
import '../models/message_in.dart';
import '../models/message_out.dart';
import '../models/point_out.dart';
import '../models/project_detail.dart';
import '../models/project_in.dart';
import '../models/project_out.dart';
import '../models/project_patch.dart';
import '../models/record_detail.dart';
import '../models/record_page.dart';
import '../models/share_in.dart';
import '../models/share_out.dart';
import '../models/tester_out.dart';
import '../models/thread_out.dart';
import '../models/version_out.dart';

part 'research_client.g.dart';

@RestApi()
abstract class ResearchClient {
  factory ResearchClient(Dio dio, {String? baseUrl}) = _ResearchClient;

  /// List Projects.
  ///
  /// The projects this user manages, newest first.
  @GET('/v1/research/projects')
  Future<List<ProjectOut>> listProjects();

  /// Create Project.
  ///
  /// Anyone with a Console account may start a research project and owns.
  /// it (ADR-030). The code starts its research numbers (ENT-HQ-…).
  @POST('/v1/research/projects')
  Future<ProjectDetail> createProject({
    @Body() required ProjectIn body,
  });

  /// List Forms
  @GET('/v1/research/projects/{project_id}/forms')
  Future<List<FormOut>> listForms({
    @Path('project_id') required String projectId,
  });

  /// Create Form.
  ///
  /// A new form, as a draft: built in the Console, then published.
  @POST('/v1/research/projects/{project_id}/forms')
  Future<FormDetail> createForm({
    @Path('project_id') required String projectId,
    @Body() required FormIn body,
  });

  /// Get Form.
  ///
  /// A form with its current definition (also a public or shared one,.
  /// for viewing before cloning).
  @GET('/v1/research/forms/{form_id}')
  Future<FormDetail> getForm({
    @Path('form_id') required String formId,
  });

  /// Update Form.
  ///
  /// Who may see and clone the form, who may collect with it, whether it.
  /// is listed, and whether it is open for collection.
  @PATCH('/v1/research/forms/{form_id}')
  Future<FormDetail> updateForm({
    @Path('form_id') required String formId,
    @Body() required FormPatch body,
  });

  /// List Records.
  ///
  /// A form's records, newest first; `q` narrows by research number.
  @GET('/v1/research/forms/{form_id}/records')
  Future<RecordPage> listRecords({
    @Path('form_id') required String formId,
    @Query('offset') int? offset = 0,
    @Query('limit') int? limit = 50,
    @Query('q') String? q,
  });

  /// Get Record.
  ///
  /// One record: its answers with the definition it was filled with, its.
  /// points of interview and its pictures.
  @GET('/v1/research/records/{record_id}')
  Future<RecordDetail> getRecord({
    @Path('record_id') required String recordId,
  });

  /// Project Points.
  ///
  /// Where each of the project's records was made, by research number.
  @GET('/v1/research/projects/{project_id}/points')
  Future<List<PointOut>> projectPoints({
    @Path('project_id') required String projectId,
  });

  /// Get Project
  @GET('/v1/research/projects/{project_id}')
  Future<ProjectDetail> getProject({
    @Path('project_id') required String projectId,
  });

  /// Update Project
  @PATCH('/v1/research/projects/{project_id}')
  Future<ProjectDetail> updateProject({
    @Path('project_id') required String projectId,
    @Body() required ProjectPatch body,
  });

  /// Add Member.
  ///
  /// Supervisors build forms and manage collectors; analysts read and.
  /// analyse. Both see all the project's records.
  @POST('/v1/research/projects/{project_id}/members')
  Future<ProjectDetail> addMember({
    @Path('project_id') required String projectId,
    @Body() required MemberIn body,
  });

  /// Remove Member
  @DELETE('/v1/research/projects/{project_id}/members/{user_id}')
  Future<ProjectDetail> removeMember({
    @Path('project_id') required String projectId,
    @Path('user_id') required String userId,
  });

  /// Save Draft.
  ///
  /// Saves the form being built. Collectors keep the published version.
  /// until the next publish.
  @PUT('/v1/research/forms/{form_id}/draft')
  Future<FormDetail> saveDraft({
    @Path('form_id') required String formId,
    @Body() required DraftIn body,
  });

  /// Discard Draft.
  ///
  /// Drops unpublished changes (a form never published keeps its draft).
  @DELETE('/v1/research/forms/{form_id}/draft')
  Future<FormDetail> discardDraft({
    @Path('form_id') required String formId,
  });

  /// Publish Form.
  ///
  /// The draft becomes the next version; collectors get it with their next.
  /// sync. Records already made keep the version they were filled with.
  @POST('/v1/research/forms/{form_id}/publish')
  Future<FormDetail> publishForm({
    @Path('form_id') required String formId,
  });

  /// New Access Code.
  ///
  /// A new access code; the old one stops working. Collectors who joined.
  /// keep the form.
  @POST('/v1/research/forms/{form_id}/code')
  Future<FormDetail> newAccessCode({
    @Path('form_id') required String formId,
  });

  /// Form Versions
  @GET('/v1/research/forms/{form_id}/versions')
  Future<List<VersionOut>> formVersions({
    @Path('form_id') required String formId,
  });

  /// Add Editor.
  ///
  /// Lets someone outside the team change the questions and publish new.
  /// versions (ADR-032); access and sharing stay with the team.
  @POST('/v1/research/forms/{form_id}/editors')
  Future<FormDetail> addEditor({
    @Path('form_id') required String formId,
    @Body() required EditorIn body,
  });

  /// Remove Editor
  @DELETE('/v1/research/forms/{form_id}/editors/{user_id}')
  Future<FormDetail> removeEditor({
    @Path('form_id') required String formId,
    @Path('user_id') required String userId,
  });

  /// Clone Form.
  ///
  /// A copy of a form the caller may see (theirs, public, or shared with.
  /// them) in one of their projects, as a draft noting where it came from.
  @POST('/v1/research/forms/{form_id}/clone')
  Future<FormDetail> cloneForm({
    @Path('form_id') required String formId,
    @Body() required CloneIn body,
  });

  /// Form Library.
  ///
  /// Forms other researchers made public or shared with the caller, to.
  /// view and clone (ADR-030 §2). Hidden forms are not listed.
  @GET('/v1/research/library')
  Future<List<LibraryForm>> formLibrary();

  /// Form Shares.
  ///
  /// The people a 'shared' form may be cloned by.
  @GET('/v1/research/forms/{form_id}/shares')
  Future<List<ShareOut>> formShares({
    @Path('form_id') required String formId,
  });

  /// Share Form
  @POST('/v1/research/forms/{form_id}/shares')
  Future<List<ShareOut>> shareForm({
    @Path('form_id') required String formId,
    @Body() required ShareIn body,
  });

  /// Unshare Form
  @DELETE('/v1/research/forms/{form_id}/shares/{user_id}')
  Future<List<ShareOut>> unshareForm({
    @Path('form_id') required String formId,
    @Path('user_id') required String userId,
  });

  /// Project Collectors.
  ///
  /// Everyone collecting for the project: given a form, joined with a.
  /// code, or with records in it.
  @GET('/v1/research/projects/{project_id}/collectors')
  Future<List<CollectorOut>> projectCollectors({
    @Path('project_id') required String projectId,
  });

  /// Find Testers.
  ///
  /// Research collectors on Collect, to give a form to (water testers are.
  /// other people, ADR-031). Anyone by their username or collector code; by.
  /// real name or phone only where the caller may see it (ADR-032). Named by.
  /// username, with the real name where it may be seen.
  @GET('/v1/research/testers')
  Future<List<TesterOut>> findTesters({
    @Query('q') required String q,
  });

  /// Device Forms.
  ///
  /// After each sync, Collect keeps only the research forms it may still.
  /// use and lists those behind a code (2026-10-27).
  @GET('/v1/research/device/forms')
  Future<DeviceForms> deviceForms();

  /// Research Collector.
  ///
  /// A research collector: details, the forms of the caller's projects.
  /// they have, and their records there.
  @GET('/v1/research/collectors/{collector_key}')
  Future<CollectorDetail> researchCollector({
    @Path('collector_key') required String collectorKey,
  });

  /// Assign Collector.
  ///
  /// Gives a form to a tester: once published it reaches their phone with.
  /// the next sync, whatever the form's access.
  @POST('/v1/research/forms/{form_id}/collectors')
  Future<FormDetail> assignCollector({
    @Path('form_id') required String formId,
    @Body() required CollectorAssignIn body,
  });

  /// Unassign Collector.
  ///
  /// Takes the form back (records already made stay).
  @DELETE('/v1/research/forms/{form_id}/collectors/{collector_key}')
  Future<FormDetail> unassignCollector({
    @Path('form_id') required String formId,
    @Path('collector_key') required String collectorKey,
  });

  /// Join With Code.
  ///
  /// Collect: a tester signed in on this phone joins a form with its access.
  /// code; the form arrives with the next sync.
  @POST('/v1/research/join')
  Future<JoinOut> joinWithCode({
    @Body() required JoinIn body,
  });

  /// Project Records.
  ///
  /// The project's records, newest first; narrowed by research number,.
  /// form or collector.
  @GET('/v1/research/projects/{project_id}/records')
  Future<RecordPage> projectRecords({
    @Path('project_id') required String projectId,
    @Query('offset') int? offset = 0,
    @Query('limit') int? limit = 50,
    @Query('q') String? q,
    @Query('form_id') String? formId,
    @Query('collector_key') String? collectorKey,
  });

  /// Form Data.
  ///
  /// All of a form's records with their answers, for the Console's.
  /// summaries, cross-tabs, indicators, visit audit and exports (worked out.
  /// there with the same form engine as on the phones).
  @GET('/v1/research/forms/{form_id}/data')
  Future<FormRecords> formData({
    @Path('form_id') required String formId,
    @Query('since') DateTime? since,
    @Query('until') DateTime? until,
    @Query('collector_key') String? collectorKey,
  });

  /// Record Messages.
  ///
  /// The conversation about a record, with the collector who made it.
  @GET('/v1/research/records/{record_id}/messages')
  Future<List<MessageOut>> recordMessages({
    @Path('record_id') required String recordId,
  });

  /// Send Record Message.
  ///
  /// A message to the collector; it reaches their phone with its next.
  /// sync. The id comes from the Console, so a retry is not sent twice.
  @POST('/v1/research/records/{record_id}/messages')
  Future<List<MessageOut>> sendRecordMessage({
    @Path('record_id') required String recordId,
    @Body() required MessageIn body,
  });

  /// Research Threads.
  ///
  /// Conversations on records in the caller's projects, newest first; a.
  /// thread whose last message came from a collector awaits an answer.
  @GET('/v1/research/messages')
  Future<List<ThreadOut>> researchThreads({
    @Query('project_id') String? projectId,
  });
}
