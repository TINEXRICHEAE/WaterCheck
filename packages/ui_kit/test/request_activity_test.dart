import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

class _Ignore extends ErrorInterceptorHandler {
  @override
  void next(DioException err) {}
}

void main() {
  testWidgets('the bar shows only for a request that takes a while', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: RequestActivityBar(child: SizedBox())),
    );
    final slow = Completer<void>();
    unawaited(showingActivity(() => slow.future));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    slow.complete();
    await tester.pump();
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(requestsInFlight.value, 0);
  });

  testWidgets('a busy icon button spins and takes no second tap', (
    tester,
  ) async {
    final done = Completer<void>();
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BusyIconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              taps++;
              return done.future;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(IconButton));
    expect(taps, 1);
    done.complete();
    await tester.pump();
    expect(find.byIcon(Icons.delete), findsOneWidget);
  });

  test('maintenance is noticed from the server, and clears with its next '
      'answer (ADR-035)', () {
    final seen = RequestActivityInterceptor();
    DioException failing(int code, Object? data) {
      final options = RequestOptions(path: '/v1/sync/push');
      return DioException(
        requestOptions: options,
        response: Response<Object?>(
          requestOptions: options,
          statusCode: code,
          data: data,
        ),
      );
    }

    seen.onError(failing(503, {'detail': 'maintenance'}), _Ignore());
    expect(serverInMaintenance.value, isTrue);
    // No answer at all says nothing either way.
    seen.onError(
      DioException(requestOptions: RequestOptions(path: '/x')),
      _Ignore(),
    );
    expect(serverInMaintenance.value, isTrue);
    seen.onError(failing(404, {'detail': 'nope'}), _Ignore());
    expect(serverInMaintenance.value, isFalse);
  });
}
