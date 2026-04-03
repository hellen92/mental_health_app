import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Visual configuration derived from user's mood and mission activity.
class MascotMoodStyle {
  final Color glowColor;
  final Color cardColor;
  final String greeting;
  final String supportMessage;
  final String emoji;

  const MascotMoodStyle({
    required this.glowColor,
    required this.cardColor,
    required this.greeting,
    required this.supportMessage,
    required this.emoji,
  });

  /// Activity-aware style: considers mood + which missions are done.
  static MascotMoodStyle fromActivity({
    String? mood,
    bool calmDone = false,
    bool moveDone = false,
  }) {
    // Both missions done → thriving
    if (calmDone && moveDone) {
      return const MascotMoodStyle(
        glowColor: Color(0xFFFFC96B),
        cardColor: Color(0xFFFFF8E1),
        greeting: "You're thriving today!",
        supportMessage:
            'Both missions complete — your companion is radiating calm energy!',
        emoji: '🌟',
      );
    }

    // Only movement done → energetic
    if (moveDone) {
      return const MascotMoodStyle(
        glowColor: Color(0xFFFFB74D),
        cardColor: Color(0xFFFFF3E0),
        greeting: 'Nice moves!',
        supportMessage:
            'Your body thanks you. Try a calm session to complete the pair.',
        emoji: '⚡',
      );
    }

    // Only calm done → soothing
    if (calmDone) {
      return const MascotMoodStyle(
        glowColor: AppColors.mint,
        cardColor: AppColors.mintLight,
        greeting: 'Feeling centered.',
        supportMessage:
            'Inner calm unlocked. A little movement could feel great too.',
        emoji: '✨',
      );
    }

    // Fall back to mood-based
    return _fromMood(mood);
  }

  /// Mood-only style (used when no missions are completed yet).
  static MascotMoodStyle _fromMood(String? mood) {
    switch (mood) {
      case 'calm':
        return const MascotMoodStyle(
          glowColor: AppColors.mint,
          cardColor: AppColors.mintLight,
          greeting: 'You look peaceful today!',
          supportMessage:
              "Wonderful! Let's keep this peaceful energy going.",
          emoji: '✨',
        );
      case 'stressed':
        return const MascotMoodStyle(
          glowColor: AppColors.pink,
          cardColor: AppColors.pinkLight,
          greeting: "I'm here for you.",
          supportMessage:
              "It's okay to feel this way. Let's breathe together.",
          emoji: '💗',
        );
      case 'tired':
        return const MascotMoodStyle(
          glowColor: Color(0xFFBDB2D1),
          cardColor: Color(0xFFE8E4F0),
          greeting: 'Rest is productive too.',
          supportMessage: 'Be gentle with yourself. You deserve rest.',
          emoji: '🌙',
        );
      default:
        return const MascotMoodStyle(
          glowColor: AppColors.mint,
          cardColor: Colors.white,
          greeting: 'Ready for today?',
          supportMessage:
              "Pick a mission to start — you're doing great just by being here.",
          emoji: '💚',
        );
    }
  }
}
