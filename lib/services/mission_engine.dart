import 'dart:math';
import '../models/daily_mission.dart';

/// Generates deterministic daily missions based on the date.
class MissionEngine {
  static const _calmMissions = [
    _MissionTemplate(
      title: '2-minute breathing',
      description: 'A short breathing exercise to center yourself.',
      reward: 10,
    ),
    _MissionTemplate(
      title: 'Grounding check-in',
      description: 'Notice 5 things you can see, 4 you can touch.',
      reward: 8,
    ),
    _MissionTemplate(
      title: 'Body scan',
      description: 'Slowly scan from head to toe and release tension.',
      reward: 12,
    ),
    _MissionTemplate(
      title: 'Mindful minute',
      description: 'Close your eyes and simply breathe for 60 seconds.',
      reward: 8,
    ),
  ];

  static const _moveMissions = [
    _MissionTemplate(
      title: '5-minute walk',
      description: 'A gentle walk around your space or outside.',
      reward: 15,
    ),
    _MissionTemplate(
      title: '1000 steps',
      description: 'Get moving and reach 1000 steps today.',
      reward: 20,
    ),
    _MissionTemplate(
      title: 'Stretch break',
      description: 'Stretch your arms, neck, and legs for a few minutes.',
      reward: 10,
    ),
    _MissionTemplate(
      title: 'Dance it out',
      description: 'Put on a song and move freely for one track.',
      reward: 15,
    ),
  ];

  /// Generate today's pair of missions.
  /// Uses the date as a seed so the same day always gives the same missions.
  static List<DailyMission> generateForDate(String dateStr) {
    final seed = dateStr.hashCode;
    final rng = Random(seed);

    final calmIndex = rng.nextInt(_calmMissions.length);
    final moveIndex = rng.nextInt(_moveMissions.length);

    final calm = _calmMissions[calmIndex];
    final move = _moveMissions[moveIndex];

    return [
      DailyMission(
        id: 'calm_$dateStr',
        title: calm.title,
        description: calm.description,
        type: MissionType.calm,
        reward: calm.reward,
        date: dateStr,
      ),
      DailyMission(
        id: 'move_$dateStr',
        title: move.title,
        description: move.description,
        type: MissionType.move,
        reward: move.reward,
        date: dateStr,
      ),
    ];
  }
}

class _MissionTemplate {
  final String title;
  final String description;
  final int reward;

  const _MissionTemplate({
    required this.title,
    required this.description,
    required this.reward,
  });
}
