import 'package:data/data.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/gate.dart';

/// The labelled map of all of Uganda from the tile server next to the API
/// (ADR-014), as in the Console: `…/api` → `…/tiles`. Online only for now;
/// without a connection the sources still show on a plain background.
final mapTemplateProvider = FutureProvider<String?>((ref) async {
  final api = ref.watch(credentialsProvider)?.apiUrl ?? defaultApiUrl();
  final root = api.endsWith('/') ? api.substring(0, api.length - 1) : api;
  final base =
      '${root.endsWith('/api') ? root.substring(0, root.length - 4) : root}/tiles';
  try {
    final styles = (await Dio().get<List<dynamic>>('$base/styles.json')).data!;
    final id = (styles.first as Map)['id'];
    return '$base/styles/$id/256/{z}/{x}/{y}.png';
  } catch (_) {
    return null;
  }
});
