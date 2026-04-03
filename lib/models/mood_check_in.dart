class MoodCheckIn {
  final String mood;
  final DateTime timestamp;

  const MoodCheckIn({required this.mood, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'mood': mood,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MoodCheckIn.fromJson(Map<String, dynamic> json) => MoodCheckIn(
        mood: json['mood'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  bool get isToday {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }
}
