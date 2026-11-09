import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/widgets.dart' show AppLifecycleListener;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../photos/photo_service.dart';
import '../research/research.dart' show fetchPicture;
import '../sync/collect_sync.dart';
import 'test_draft.dart';

final waterDraftRepositoryProvider = Provider<WaterDraftRepository>(
  (ref) => WaterDraftRepository(ref.watch(databaseProvider)),
);

/// The active tester's unfinished water tests.
final waterDraftsProvider = StreamProvider<List<WaterDraftItem>>(
  (ref) => ref
      .watch(waterDraftRepositoryProvider)
      .watch(ref.watch(submissionOriginProvider)?.collectorKey),
);

/// Keeps a water test in progress (ADR-034): saved shortly after each
/// change, sent a little later and on leaving the app. Nothing is kept
/// until the tester has entered something.
class WaterDraftKeeper {
  WaterDraftKeeper(this._ref);

  final Ref _ref;
  Timer? _save;
  Timer? _send;
  TestDraft? _latest;
  AppLifecycleListener? _lifecycle;
  Future<void> _running = Future.value();

  /// Each picture's id, by the picture itself.
  final _pictures = LinkedHashMap<Uint8List, String>.identity();
  final _closed = <String>{};

  WaterDraftRepository get _repo => _ref.read(waterDraftRepositoryProvider);

  void changed(TestDraft d) {
    _latest = d;
    if (d.id == null || !d.touched || _closed.contains(d.id)) return;
    _lifecycle ??= AppLifecycleListener(onHide: () => unawaited(_keepNow()));
    _save?.cancel();
    _save = Timer(const Duration(milliseconds: 800), () {
      unawaited(_write());
    });
  }

  /// One write at a time, in order.
  Future<void> _write() {
    final draft = _latest;
    if (draft == null) return _running;
    return _running = _running
        .then((_) => _saveState(draft))
        .catchError((Object e) => debugPrint('Test not saved: $e'));
  }

  Future<void> _saveState(TestDraft d) async {
    final id = d.id;
    final sourceId = d.sourceId;
    if (id == null || sourceId == null || _closed.contains(id)) return;
    final origin = _ref.read(submissionOriginProvider);
    await _repo.save(
      id: id,
      sourceId: sourceId,
      collectorKey: origin?.collectorKey,
      state: d.toState(),
    );
    if (origin != null) await _savePictures(d, id, origin);
    if (_send?.isActive ?? false) return;
    _send = Timer(const Duration(seconds: 30), () {
      unawaited(_ref.read(syncControllerProvider.notifier).sendDrafts());
    });
  }

  Future<void> _savePictures(
    TestDraft d,
    String id,
    SubmissionOrigin origin,
  ) async {
    final attachments = _ref.read(attachmentRepositoryProvider);
    for (final jpeg in d.photos) {
      if (_pictures.containsKey(jpeg)) continue;
      final pictureId = const IdGenerator().next();
      await _repo.addPicture(
        draftId: id,
        pictureId: pictureId,
        jpeg: jpeg,
        files: _ref.read(photoFilesProvider),
        attachments: attachments,
        origin: origin,
        taken: d.photoTaken[jpeg],
      );
      _pictures[jpeg] = pictureId;
    }
    final gone = [
      for (final e in _pictures.entries)
        if (!d.photos.any((p) => identical(p, e.key))) e.key,
    ];
    for (final jpeg in gone) {
      await _repo.removePicture(
        draftId: id,
        pictureId: _pictures.remove(jpeg)!,
        attachments: attachments,
        origin: origin,
      );
    }
  }

  Future<void> _keepNow() async {
    _save?.cancel();
    _send?.cancel();
    if (_latest?.touched ?? false) await _write();
    await _ref.read(syncControllerProvider.notifier).sendDrafts();
  }

  /// Everything saved, before the test is submitted; [picturesKept] then
  /// says which pictures need no sending of their own.
  Future<void> flush() async {
    _save?.cancel();
    if (_latest?.touched ?? false) await _write();
  }

  bool picturesKept(Uint8List jpeg) => _pictures.containsKey(jpeg);

  /// The test ended (submitted, or corrected): saved no more.
  void closed(String id) {
    _closed.add(id);
    _save?.cancel();
    _send?.cancel();
    _pictures.clear();
  }

  /// The saved test, ready to continue; null if it can no longer be read.
  Future<TestDraft?> open(String id) async {
    final row = await _repo.draft(id);
    if (row == null) return null;
    final files = _ref.read(photoFilesProvider);
    final dio = _ref.read(collectApiDioProvider);
    final state = (jsonDecode(row.state) as Map).cast<String, Object?>();
    final testers = await _ref.read(testerProfilesProvider.future);
    final profiles = await _ref.read(referenceProfilesProvider.future);
    final photos = <Uint8List>[];
    final taken = LinkedHashMap<Uint8List, GeoFix>.identity();
    _pictures.clear();
    for (final e in _repo.pictures(row).entries) {
      final bytes =
          await files.read(e.value.path) ?? await fetchPicture(dio, e.key);
      if (bytes == null) continue;
      photos.add(bytes);
      _pictures[bytes] = e.key;
      if (e.value.taken case final t?) taken[bytes] = t;
    }
    return TestDraft.fromState(
      id: id,
      sourceId: row.sourceId,
      state: state,
      testers: testers,
      profiles: profiles,
      photos: photos,
      photoTaken: taken,
    );
  }

  /// Throws the saved test away.
  Future<void> discard(String id) async {
    closed(id);
    await _repo.discard(id, _ref.read(photoFilesProvider));
    unawaited(_ref.read(syncControllerProvider.notifier).sendDrafts());
  }

  void dispose() {
    _save?.cancel();
    _send?.cancel();
    _lifecycle?.dispose();
  }
}
