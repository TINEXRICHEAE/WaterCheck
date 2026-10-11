import 'dart:io';

/// Fails when line coverage in `coverage/lcov.info` is below the P1 gate.
/// Run after `dart run coverage:test_with_coverage`.
void main(List<String> args) {
  final minimum = args.isEmpty ? 95.0 : double.parse(args.first);
  final lcov = File('coverage/lcov.info');
  if (!lcov.existsSync()) {
    stderr.writeln('coverage/lcov.info not found');
    exit(2);
  }
  var found = 0;
  var hit = 0;
  for (final line in lcov.readAsLinesSync()) {
    if (line.startsWith('LF:')) found += int.parse(line.substring(3));
    if (line.startsWith('LH:')) hit += int.parse(line.substring(3));
  }
  final percent = found == 0 ? 0.0 : 100 * hit / found;
  stdout.writeln(
    'domain line coverage: ${percent.toStringAsFixed(1)}% ($hit/$found), '
    'minimum $minimum%',
  );
  if (percent < minimum) exit(1);
}
