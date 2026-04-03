enum MissionType { calm, move }

class DailyMission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final int reward;
  final String date; // yyyy-MM-dd
  bool completed;

  DailyMission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.reward,
    required this.date,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'reward': reward,
        'date': date,
        'completed': completed,
      };

  factory DailyMission.fromJson(Map<String, dynamic> json) => DailyMission(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        type: MissionType.values.byName(json['type'] as String),
        reward: json['reward'] as int,
        date: json['date'] as String,
        completed: json['completed'] as bool,
      );

  String get typeBadge => type == MissionType.calm ? 'Calm' : 'Move';
  String get typeEmoji => type == MissionType.calm ? '🧘' : '🚶';
}
