import 'package:flutter/material.dart';
import '../../app/app_shell.dart';
import '../../app/app_state.dart';
import '../../models/daily_mission.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bouncing_mascot.dart';
import '../../widgets/mascot_state.dart';
import '../../widgets/soft_card.dart';
import 'widgets/mood_card.dart';
import 'widgets/streak_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final moodStyle = MascotMoodStyle.fromActivity(
      mood: state.todayMood,
      calmDone: state.calmMissionDone,
      moveDone: state.moveMissionDone,
    );

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              Center(
                child: BouncingMascot(
                  size: 130,
                  glowColor: moodStyle.glowColor,
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  moodStyle.greeting,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Daily check-in
              if (state.checkedInToday)
                _CheckedInBadge(mood: state.todayMood!)
              else
                _MoodSelector(
                  selectedMood: state.todayMood,
                  onSelect: (mood) async {
                    await AppStateScope.read(context).checkInMood(mood);
                  },
                ),
              const SizedBox(height: 24),

              // Today's Missions
              Text(
                "Today's Missions",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...state.todayMissions.map((mission) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MissionCard(
                      mission: mission,
                      onTap: () => _handleMissionTap(context, mission),
                    ),
                  )),
              const SizedBox(height: 12),

              // Streak & energy row
              Row(
                children: [
                  Expanded(
                    child: StreakCard(streakDays: state.streakDays),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CalmEnergyMini(energy: state.calmEnergy),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Supportive message
              SoftCard(
                color: moodStyle.cardColor.withValues(alpha: 0.4),
                child: Row(
                  children: [
                    Text(moodStyle.emoji,
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        moodStyle.supportMessage,
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.greenDark,
                                  fontStyle: FontStyle.italic,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMissionTap(BuildContext context, DailyMission mission) {
    if (mission.completed) return;
    if (mission.type == MissionType.calm) {
      TabSwitcher.of(context).switchTo(1); // Calm tab
    } else {
      TabSwitcher.of(context).switchTo(2); // Move tab
    }
  }
}

// --- Private widgets ---

class _MissionCard extends StatelessWidget {
  final DailyMission mission;
  final VoidCallback onTap;

  const _MissionCard({required this.mission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCalm = mission.type == MissionType.calm;
    final badgeColor =
        isCalm ? AppColors.mintLight : const Color(0xFFFFF3E0);
    final badgeTextColor =
        isCalm ? AppColors.greenDark : const Color(0xFFE65100);

    return GestureDetector(
      onTap: mission.completed ? null : onTap,
      child: SoftCard(
        color: mission.completed
            ? AppColors.mintLight.withValues(alpha: 0.4)
            : Colors.white,
        child: Row(
          children: [
            // Left: badge + info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${mission.typeEmoji} ${mission.typeBadge}',
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: badgeTextColor,
                                fontSize: 12,
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mission.title,
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: mission.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    mission.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right: reward or check
            if (mission.completed)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.green, size: 28)
            else
              Column(
                children: [
                  Text(
                    '+${mission.reward}',
                    style:
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.green,
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  const Text('🌿', style: TextStyle(fontSize: 16)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _MoodSelector extends StatelessWidget {
  final String? selectedMood;
  final ValueChanged<String> onSelect;

  const _MoodSelector({required this.selectedMood, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MoodCard(
            emoji: '😌',
            label: 'Calm',
            color: AppColors.mintLight,
            isSelected: selectedMood == 'calm',
            onTap: () => onSelect('calm'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MoodCard(
            emoji: '😰',
            label: 'Stressed',
            color: AppColors.pinkLight,
            isSelected: selectedMood == 'stressed',
            onTap: () => onSelect('stressed'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: MoodCard(
            emoji: '😴',
            label: 'Tired',
            color: const Color(0xFFE8E4F0),
            isSelected: selectedMood == 'tired',
            onTap: () => onSelect('tired'),
          ),
        ),
      ],
    );
  }
}

class _CheckedInBadge extends StatelessWidget {
  final String mood;

  const _CheckedInBadge({required this.mood});

  @override
  Widget build(BuildContext context) {
    final style = MascotMoodStyle.fromActivity(mood: mood);

    return SoftCard(
      color: style.cardColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded,
              color: AppColors.green, size: 22),
          const SizedBox(width: 10),
          Text(
            'Checked in today — feeling $mood',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.greenDark,
                ),
          ),
          const SizedBox(width: 8),
          Text(style.emoji, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}

class _CalmEnergyMini extends StatelessWidget {
  final int energy;

  const _CalmEnergyMini({required this.energy});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('🌿', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            '$energy',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenDark,
                ),
          ),
          Text(
            'Energy',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
