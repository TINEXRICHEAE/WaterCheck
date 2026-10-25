import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:watercheck_collect/features/location/location_service.dart';

void main() {
  test('a browser refusing or location switched off gives its own reason '
      '(2026-10-25)', () {
    expect(
      problemOf(const PermissionDeniedException('User denied Geolocation')),
      LocationProblem.denied,
    );
    expect(
      problemOf(const LocationServiceDisabledException()),
      LocationProblem.serviceOff,
    );
    expect(problemOf(TimeoutException('no fix')), LocationProblem.timeout);
    expect(
      problemOf(const LocationException(LocationProblem.deniedForever)),
      LocationProblem.deniedForever,
    );
    expect(problemOf(StateError('other')), LocationProblem.unavailable);
  });
}
