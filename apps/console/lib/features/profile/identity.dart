import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

import '../../app/console_sync.dart';
import '../../app/session.dart';

PeopleClient _api(WidgetRef ref) =>
    WaterCheckApi(ref.read(consoleDioProvider)).people;

final _identityProvider = FutureProvider.autoDispose<Identity>((ref) {
  ref.watch(sessionProvider.select((s) => s.me?.id));
  return WaterCheckApi(ref.watch(consoleDioProvider)).people.myIdentity();
});

/// My username and whether others see my real name (ADR-032).
class MyIdentity extends ConsumerWidget {
  const MyIdentity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = UiKitLocalizations.of(context);
    return switch (ref.watch(_identityProvider)) {
      AsyncData(:final value) => IdentitySection(
        handle: value.handle,
        fullName: value.fullName,
        public: value.public,
        isFree: (h) async => (await _api(ref).checkHandle(handle: h)).free,
        save: ({handle, public}) async {
          try {
            await _api(ref).setMyIdentity(
              body: IdentityIn(handle: handle, public: public),
            );
            ref.invalidate(_identityProvider);
            return null;
          } on Object catch (e) {
            final f = ApiFailure.from(e);
            return f.code == 'handle_taken' ? ui.identityTaken : f.code;
          }
        },
      ),
      AsyncError(:final error) => ErrorView(
        error: error,
        compact: true,
        onRetry: () => ref.invalidate(_identityProvider),
      ),
      _ => const LinearProgressIndicator(),
    };
  }
}
