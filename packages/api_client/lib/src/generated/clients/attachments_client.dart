// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/upload_state_out.dart';

part 'attachments_client.g.dart';

@RestApi()
abstract class AttachmentsClient {
  factory AttachmentsClient(Dio dio, {String? baseUrl}) = _AttachmentsClient;

  /// Upload State.
  ///
  /// How many bytes the server holds: the phone resumes from here.
  @GET('/v1/attachments/{attachment_id}/upload')
  Future<UploadStateOut> uploadState({
    @Path('attachment_id') required String attachmentId,
  });

  /// Upload Chunk.
  ///
  /// Appends up to 256 KB at `offset` (signed like every Collect request).
  @PUT('/v1/attachments/{attachment_id}/upload')
  Future<UploadStateOut> uploadChunk({
    @Path('attachment_id') required String attachmentId,
    @Query('offset') required int offset,
    @Body() required File body,
  });

  /// Complete Upload.
  ///
  /// Verifies size, type and SHA-256, then stores the photo.
  @POST('/v1/attachments/{attachment_id}/complete')
  Future<UploadStateOut> completeUpload({
    @Path('attachment_id') required String attachmentId,
  });

  /// Attachment Content.
  ///
  /// The photo, for anyone who can see its source or test.
  @GET('/v1/attachments/{attachment_id}/content')
  Future<void> attachmentContent({
    @Path('attachment_id') required String attachmentId,
  });
}
