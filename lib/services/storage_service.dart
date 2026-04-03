import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_check_in.dart';
import '../models/breathing_session.dart';
import '../models/daily_mission.dart';

class StorageService {
  static const _keyMoodCheckIns = 'mood_check_ins';
  static const _keyBreathingSessions = 'breathing_sessions';
  static const _keyStreakDays = 'streak_days';
  static const _keyCalmEnergy = 'calm_energy';
  static const _keyLastActiveDate = 'last_active_date';
  static const _keyDailyMissions = 'daily_missions';
  static const _keyCompletedMoveCount = 'completed_move_count';
  static const _keyCompletedCalmCount = 'completed_calm_count';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  // --- Mood Check-ins ---

  List<MoodCheckIn> getMoodCheckIns() {
    final raw = _prefs.getStringList(_keyMoodCheckIns) ?? [];
    return raw
        .map((s) => MoodCheckIn.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveMoodCheckIn(MoodCheckIn checkIn) async {
    final list = getMoodCheckIns();
    list.add(checkIn);
    await _prefs.setStringList(
      _keyMoodCheckIns,
      list.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  MoodCheckIn? getTodayCheckIn() {
    final all = getMoodCheckIns();
    for (final c in all.reversed) {
      if (c.isToday) return c;
    }
    return null;
  }

  // --- Breathing Sessions ---

  List<BreathingSession> getBreathingSessions() {
    final raw = _prefs.getStringList(_keyBreathingSessions) ?? [];
    return raw
        .map((s) =>
            BreathingSession.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveBreathingSession(BreathingSession session) async {
    final list = getBreathingSessions();
    list.add(session);
    await _prefs.setStringList(
      _keyBreathingSessions,
      list.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  int getSessionsThisWeek() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek =
        DateTime(weekStart.year, weekStart.month, weekStart.day);
    return getBreathingSessions()
        .where((s) => s.completedAt.isAfter(startOfWeek))
        .length;
  }

  List<int> getWeeklySessionCounts() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeek =
        DateTime(weekStart.year, weekStart.month, weekStart.day);

    final counts = List.filled(7, 0);
    for (final s in getBreathingSessions()) {
      if (s.completedAt.isAfter(startOfWeek)) {
        final dayIndex = s.completedAt.weekday - 1;
        if (dayIndex >= 0 && dayIndex < 7) {
          counts[dayIndex]++;
        }
      }
    }
    return counts;
  }

  // --- Streak ---

  int getStreakDays() => _prefs.getInt(_keyStreakDays) ?? 0;

  Future<void> updateStreak() async {
    final today = _todayString();
    final lastActive = _prefs.getString(_keyLastActiveDate);

    if (lastActive == today) return;

    final yesterday =
        _dateString(DateTime.now().subtract(const Duration(days: 1)));
    int streak = getStreakDays();

    if (lastActive == yesterday) {
      streak++;
    } else if (lastActive != today) {
      streak = 1;
    }

    await _prefs.setInt(_keyStreakDays, streak);
    await _prefs.setString(_keyLastActiveDate, today);
  }

  // --- Calm Energy ---

  int getCalmEnergy() => _prefs.getInt(_keyCalmEnergy) ?? 0;

  Future<int> addCalmEnergy(int amount) async {
    final updated = getCalmEnergy() + amount;
    await _prefs.setInt(_keyCalmEnergy, updated);
    return updated;
  }

  // --- Daily Missions ---

  List<DailyMission> getDailyMissions(String dateStr) {
    final raw = _prefs.getStringList('${_keyDailyMissions}_$dateStr') ?? [];
    return raw
        .map((s) =>
            DailyMission.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDailyMissions(
      String dateStr, List<DailyMission> missions) async {
    await _prefs.setStringList(
      '${_keyDailyMissions}_$dateStr',
      missions.map((m) => jsonEncode(m.toJson())).toList(),
    );
  }

  // --- Mission completion counts ---

  int getCompletedMoveCount() =>
      _prefs.getInt(_keyCompletedMoveCount) ?? 0;

  Future<void> incrementMoveCount() async {
    await _prefs.setInt(
        _keyCompletedMoveCount, getCompletedMoveCount() + 1);
  }

  int getCompletedCalmCount() =>
      _prefs.getInt(_keyCompletedCalmCount) ?? 0;

  Future<void> incrementCalmCount() async {
    await _prefs.setInt(
        _keyCompletedCalmCount, getCompletedCalmCount() + 1);
  }

  // --- Helpers ---

  String todayString() => _todayString();

  String _todayString() => _dateString(DateTime.now());

  String _dateString(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
