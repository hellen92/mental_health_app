class ProgressSummary {
  final int streakDays;
  final int sessionsThisWeek;
  final int moodCheckInsTotal;
  final int calmEnergy;
  final int movementMissionsCompleted;
  final int calmMissionsCompleted;
  final List<int> weeklySessionCounts;

  const ProgressSummary({
    required this.streakDays,
    required this.sessionsThisWeek,
    required this.moodCheckInsTotal,
    required this.calmEnergy,
    required this.movementMissionsCompleted,
    required this.calmMissionsCompleted,
    required this.weeklySessionCounts,
  });
}
