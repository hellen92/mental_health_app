import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/soft_card.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;

  const StreakCard({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            '$streakDays',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
          ),
          Text(
            streakDays == 1 ? 'Day streak' : 'Day streak',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
