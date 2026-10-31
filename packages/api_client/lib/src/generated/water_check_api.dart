// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';

import 'clients/health_client.dart';
import 'clients/auth_client.dart';
import 'clients/account_client.dart';
import 'clients/installations_client.dart';
import 'clients/admin_client.dart';
import 'clients/reference_client.dart';
import 'clients/research_client.dart';
import 'clients/people_client.dart';
import 'clients/sync_client.dart';
import 'clients/attachments_client.dart';
import 'clients/notifications_client.dart';
import 'clients/tiles_client.dart';
import 'clients/conflicts_client.dart';
import 'clients/dashboard_client.dart';
import 'clients/profile_client.dart';
import 'clients/testers_client.dart';
import 'clients/collectors_client.dart';

/// WaterCheck API `v0.1.0`
class WaterCheckApi {
  WaterCheckApi(Dio dio, {String? baseUrl}) : _dio = dio, _baseUrl = baseUrl;

  final Dio _dio;
  final String? _baseUrl;

  static String get version => '0.1.0';

  HealthClient? _health;
  AuthClient? _auth;
  AccountClient? _account;
  InstallationsClient? _installations;
  AdminClient? _admin;
  ReferenceClient? _reference;
  ResearchClient? _research;
  PeopleClient? _people;
  SyncClient? _sync;
  AttachmentsClient? _attachments;
  NotificationsClient? _notifications;
  TilesClient? _tiles;
  ConflictsClient? _conflicts;
  DashboardClient? _dashboard;
  ProfileClient? _profile;
  TestersClient? _testers;
  CollectorsClient? _collectors;

  HealthClient get health => _health ??= HealthClient(_dio, baseUrl: _baseUrl);

  AuthClient get auth => _auth ??= AuthClient(_dio, baseUrl: _baseUrl);

  AccountClient get account =>
      _account ??= AccountClient(_dio, baseUrl: _baseUrl);

  InstallationsClient get installations =>
      _installations ??= InstallationsClient(_dio, baseUrl: _baseUrl);

  AdminClient get admin => _admin ??= AdminClient(_dio, baseUrl: _baseUrl);

  ReferenceClient get reference =>
      _reference ??= ReferenceClient(_dio, baseUrl: _baseUrl);

  ResearchClient get research =>
      _research ??= ResearchClient(_dio, baseUrl: _baseUrl);

  PeopleClient get people => _people ??= PeopleClient(_dio, baseUrl: _baseUrl);

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

  ProfileClient get profile =>
      _profile ??= ProfileClient(_dio, baseUrl: _baseUrl);

  TestersClient get testers =>
      _testers ??= TestersClient(_dio, baseUrl: _baseUrl);

  CollectorsClient get collectors =>
      _collectors ??= CollectorsClient(_dio, baseUrl: _baseUrl);
}
