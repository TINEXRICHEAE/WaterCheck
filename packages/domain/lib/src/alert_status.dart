/// Alert lifecycle (F-ALR-3): `open → acknowledged → action_in_progress →
/// closed`, or `false_alarm` from any open state. The server is
/// authoritative (SPEC §8.4); clients use this to offer only valid actions.
enum AlertStatus {
  open('open'),
  acknowledged('acknowledged'),
  actionInProgress('action_in_progress'),
  closed('closed'),
  falseAlarm('false_alarm');

  const AlertStatus(this.code);

  final String code;

  bool get isTerminal => this == closed || this == falseAlarm;

  Set<AlertStatus> get nextStates => switch (this) {
    open => {acknowledged, falseAlarm},
    acknowledged => {actionInProgress, closed, falseAlarm},
    actionInProgress => {closed, falseAlarm},
    closed || falseAlarm => const {},
  };

  bool canTransitionTo(AlertStatus next) => nextStates.contains(next);

  static AlertStatus fromCode(String code) => values.firstWhere(
    (s) => s.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unknown status'),
  );
}
