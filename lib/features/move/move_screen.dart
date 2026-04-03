import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bouncing_mascot.dart';
import '../../widgets/mascot_image.dart';
import '../../widgets/soft_card.dart';
import '../../models/daily_mission.dart';

class MoveScreen extends StatefulWidget {
  const MoveScreen({super.key});

  @override
  State<MoveScreen> createState() => _MoveScreenState();
}

class _MoveScreenState extends State<MoveScreen> {
  int? _earnedEnergy;

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final mission = state.todayMoveMission;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Mascot with energetic glow when mission done
              BouncingMascot(
                size: 120,
                glowColor: mission?.completed == true
                    ? const Color(0xFFFFC96B)
                    : AppColors.mint,
              ),
              const SizedBox(height: 16),

              Text(
                'Movement',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                mission?.completed == true
                    ? 'Great job getting moving today!'
                    : 'A little movement goes a long way.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              if (mission != null) ...[
                // Today's movement mission
                _MoveMissionCard(
                  mission: mission,
                  onComplete: mission.completed
                      ? null
                      : () => _completeMission(mission),
                ),
                const SizedBox(height: 24),
              ],

              // Reward feedback
              if (_earnedEnergy != null) ...[
                _RewardCard(
                  energy: _earnedEnergy!,
                  totalEnergy: state.calmEnergy,
                ),
                const SizedBox(height: 24),
              ],

              // Completed state
              if (mission?.completed == true && _earnedEnergy == null) ...[
                SoftCard(
                  color: AppColors.mintLight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.green, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Mission complete!',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.greenDark,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Tips section
              SoftCard(
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Movement tips',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _TipRow(
                        emoji: '🌿',
                        text: 'Even 5 minutes of walking helps reset your mind.'),
                    const SizedBox(height: 8),
                    _TipRow(
                        emoji: '🧘',
                        text: 'Gentle stretching releases stored tension.'),
                    const SizedBox(height: 8),
                    _TipRow(
                        emoji: '🎵',
                        text: 'Try moving to music you love — no rules.'),
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

  Future<void> _completeMission(DailyMission mission) async {
    final energy = await AppStateScope.read(context).completeMission(mission.id);
    setState(() => _earnedEnergy = energy);
  }
}

class _MoveMissionCard extends StatelessWidget {
  final DailyMission mission;
  final VoidCallback? onComplete;

  const _MoveMissionCard({required this.mission, this.onComplete});

  @override
  Widget build(BuildContext context) {
    final isDone = mission.completed;

    return SoftCard(
      color: isDone
          ? AppColors.mintLight.withValues(alpha: 0.6)
          : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '🚶 Move',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE65100),
                        fontSize: 12,
                      ),
                ),
              ),
              const Spacer(),
              Text(
                '+${mission.reward} 🌿',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            mission.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  decoration:
                      isDone ? TextDecoration.lineThrough : null,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            mission.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (!isDone) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Complete'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final int energy;
  final int totalEnergy;

  const _RewardCard({required this.energy, required this.totalEnergy});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: AppColors.mintLight,
      child: Column(
        children: [
          const MascotImage(size: 60),
          const SizedBox(height: 12),
          Text(
            'Your companion feels stronger!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.greenDark,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '+$energy calm energy',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.green,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total: $totalEnergy',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String emoji;
  final String text;

  const _TipRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
