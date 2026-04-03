class BreathingSession {
  final int durationMinutes;
  final DateTime completedAt;

  const BreathingSession({
    required this.durationMinutes,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
        'durationMinutes': durationMinutes,
        'completedAt': completedAt.toIso8601String(),
      };

  factory BreathingSession.fromJson(Map<String, dynamic> json) =>
      BreathingSession(
        durationMinutes: json['durationMinutes'] as int,
        completedAt: DateTime.parse(json['completedAt'] as String),
      );
}
