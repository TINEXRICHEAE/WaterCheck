// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'clients/health_client.dart';
import 'clients/auth_client.dart';
import 'clients/installations_client.dart';
import 'clients/admin_client.dart';
import 'clients/reference_client.dart';
import 'clients/sync_client.dart';
import 'clients/attachments_client.dart';
import 'clients/notifications_client.dart';
import 'clients/tiles_client.dart';
import 'clients/conflicts_client.dart';
import 'clients/dashboard_client.dart';

/// WaterCheck API `v0.1.0`
class WaterCheckApi {
  WaterCheckApi(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.1.0';

  HealthClient? _health;
  AuthClient? _auth;
  InstallationsClient? _installations;
  AdminClient? _admin;
  ReferenceClient? _reference;
  SyncClient? _sync;
  AttachmentsClient? _attachments;
  NotificationsClient? _notifications;
  TilesClient? _tiles;
  ConflictsClient? _conflicts;
  DashboardClient? _dashboard;

  HealthClient get health => _health ??= HealthClient(_dio, baseUrl: _baseUrl);

  AuthClient get auth => _auth ??= AuthClient(_dio, baseUrl: _baseUrl);

  InstallationsClient get installations =>
      _installations ??= InstallationsClient(_dio, baseUrl: _baseUrl);

  AdminClient get admin => _admin ??= AdminClient(_dio, baseUrl: _baseUrl);

  ReferenceClient get reference =>
      _reference ??= ReferenceClient(_dio, baseUrl: _baseUrl);

  SyncClient get sync => _sync ??= SyncClient(_dio, baseUrl: _baseUrl);

  AttachmentsClient get attachments =>
      _attachments ??= AttachmentsClient(_dio, baseUrl: _baseUrl);

  NotificationsClient get notifications =>
      _notifications ??= NotificationsClient(_dio, baseUrl: _baseUrl);

  TilesClient get tiles => _tiles ??= TilesClient(_dio, baseUrl: _baseUrl);

  ConflictsClient get conflicts =>
      _conflicts ??= ConflictsClient(_dio, baseUrl: _baseUrl);

  DashboardClient get dashboard =>
      _dashboard ??= DashboardClient(_dio, baseUrl: _baseUrl);
}
