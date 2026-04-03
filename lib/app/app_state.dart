import 'package:flutter/material.dart';
import '../models/mood_check_in.dart';
import '../models/breathing_session.dart';
import '../models/daily_mission.dart';
import '../models/progress_summary.dart';
import '../services/mission_engine.dart';
import '../services/storage_service.dart';

/// Central app state using ChangeNotifier.
class AppState extends ChangeNotifier {
  final StorageService storage;

  AppState(this.storage) {
    _load();
  }

  String? _todayMood;
  bool _checkedInToday = false;
  int _streakDays = 0;
  int _calmEnergy = 0;
  int _totalCheckIns = 0;
  List<DailyMission> _todayMissions = [];

  String? get todayMood => _todayMood;
  bool get checkedInToday => _checkedInToday;
  int get streakDays => _streakDays;
  int get calmEnergy => _calmEnergy;
  List<DailyMission> get todayMissions => _todayMissions;

  bool get calmMissionDone =>
      _todayMissions.any((m) => m.type == MissionType.calm && m.completed);
  bool get moveMissionDone =>
      _todayMissions.any((m) => m.type == MissionType.move && m.completed);
  bool get allMissionsDone => calmMissionDone && moveMissionDone;

  DailyMission? get todayCalmMission => _todayMissions
      .cast<DailyMission?>()
      .firstWhere((m) => m!.type == MissionType.calm, orElse: () => null);

  DailyMission? get todayMoveMission => _todayMissions
      .cast<DailyMission?>()
      .firstWhere((m) => m!.type == MissionType.move, orElse: () => null);

  void _load() {
    final todayCheckIn = storage.getTodayCheckIn();
    _todayMood = todayCheckIn?.mood;
    _checkedInToday = todayCheckIn != null;
    _streakDays = storage.getStreakDays();
    _calmEnergy = storage.getCalmEnergy();
    _totalCheckIns = storage.getMoodCheckIns().length;
    _loadTodayMissions();
  }

  void _loadTodayMissions() {
    final today = storage.todayString();
    var missions = storage.getDailyMissions(today);
    if (missions.isEmpty) {
      missions = MissionEngine.generateForDate(today);
      storage.saveDailyMissions(today, missions);
    }
    _todayMissions = missions;
  }

  Future<void> checkInMood(String mood) async {
    final checkIn = MoodCheckIn(mood: mood, timestamp: DateTime.now());
    await storage.saveMoodCheckIn(checkIn);
    await storage.updateStreak();

    _todayMood = mood;
    _checkedInToday = true;
    _streakDays = storage.getStreakDays();
    _totalCheckIns = storage.getMoodCheckIns().length;
    notifyListeners();
  }

  Future<int> completeBreathingSession(int durationMinutes) async {
    final session = BreathingSession(
      durationMinutes: durationMinutes,
      completedAt: DateTime.now(),
    );
    await storage.saveBreathingSession(session);
    await storage.updateStreak();

    final energyGain = durationMinutes * 5;
    _calmEnergy = await storage.addCalmEnergy(energyGain);
    _streakDays = storage.getStreakDays();
    notifyListeners();
    return energyGain;
  }

  /// Complete a daily mission by id. Returns the energy gained.
  Future<int> completeMission(String missionId) async {
    final mission = _todayMissions.firstWhere((m) => m.id == missionId);
    if (mission.completed) return 0;

    mission.completed = true;
    final today = storage.todayString();
    await storage.saveDailyMissions(today, _todayMissions);
    await storage.updateStreak();

    if (mission.type == MissionType.calm) {
      await storage.incrementCalmCount();
    } else {
      await storage.incrementMoveCount();
    }

    _calmEnergy = await storage.addCalmEnergy(mission.reward);
    _streakDays = storage.getStreakDays();
    notifyListeners();
    return mission.reward;
  }

  ProgressSummary getProgressSummary() {
    return ProgressSummary(
      streakDays: _streakDays,
      sessionsThisWeek: storage.getSessionsThisWeek(),
      moodCheckInsTotal: _totalCheckIns,
      calmEnergy: _calmEnergy,
      movementMissionsCompleted: storage.getCompletedMoveCount(),
      calmMissionsCompleted: storage.getCompletedCalmCount(),
      weeklySessionCounts: storage.getWeeklySessionCounts(),
    );
  }
}

/// Makes AppState available to the widget tree.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateScope>()!
        .notifier!;
  }

  static AppState read(BuildContext context) {
    return (context
            .getElementForInheritedWidgetOfExactType<AppStateScope>()!
            .widget as AppStateScope)
        .notifier!;
  }
}
