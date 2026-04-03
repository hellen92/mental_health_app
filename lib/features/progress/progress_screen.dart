import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/mascot_image.dart';
import '../../widgets/soft_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final summary = state.getProgressSummary();

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
                child: Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              const SizedBox(height: 24),

              // Calm Energy hero card
              SoftCard(
                color: AppColors.mintLight.withValues(alpha: 0.6),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                child: Row(
                  children: [
                    const MascotImage(size: 56),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Calm Energy',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.greenDark),
                          ),
                          Text(
                            '${summary.calmEnergy}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: AppColors.greenDark,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Text('🌿', style: TextStyle(fontSize: 32)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats grid
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: '🔥',
                      value: '${summary.streakDays}',
                      label: 'Day streak',
                      color: AppColors.mint.withValues(alpha: 0.3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: '🧘',
                      value: '${summary.calmMissionsCompleted}',
                      label: 'Calm',
                      color: AppColors.mintLight,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: '🚶',
                      value: '${summary.movementMissionsCompleted}',
                      label: 'Move',
                      color: const Color(0xFFFFF3E0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      icon: '💚',
                      value: '${summary.moodCheckInsTotal}',
                      label: 'Check-ins',
                      color: AppColors.pinkLight.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Resilience summary
              Text(
                'Weekly resilience',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryTile(
                      label: 'Breathing sessions',
                      value: '${summary.sessionsThisWeek}',
                      emoji: '🫁',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryTile(
                      label: 'Total missions',
                      value:
                          '${summary.calmMissionsCompleted + summary.movementMissionsCompleted}',
                      emoji: '🎯',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Weekly chart
              Text(
                'Sessions this week',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SoftCard(
                child: SizedBox(
                  height: 160,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(7, (i) {
                      final sessions = summary.weeklySessionCounts[i];
                      final max = summary.weeklySessionCounts
                          .fold<int>(1, (a, b) => a > b ? a : b);
                      final ratio = sessions / max;
                      return Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '$sessions',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.greenDark,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 600),
                                curve: Curves.easeOut,
                                height: 100 * ratio,
                                decoration: BoxDecoration(
                                  color: sessions > 0
                                      ? AppColors.mint
                                      : Colors.grey
                                          .withValues(alpha: 0.15),
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _dayLabels[i],
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Mascot encouragement
              Center(
                child: Column(
                  children: [
                    const MascotImage(size: 80),
                    const SizedBox(height: 12),
                    Text(
                      _getEncouragement(summary.streakDays, summary.calmEnergy),
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.greenDark,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getEncouragement(int streak, int energy) {
    if (streak >= 7) return "A whole week! You're unstoppable!";
    if (streak >= 3) return "You're building real resilience!";
    if (energy >= 50) return 'Your companion is thriving!';
    if (streak >= 1) return 'Great start — keep going!';
    return 'Start your first mission today!';
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: color,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;

  const _SummaryTile({
    required this.label,
    required this.value,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenDark,
                      ),
                ),
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
