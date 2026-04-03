import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../features/onboarding/onboarding_screen.dart';
import 'app_shell.dart';

class CalmCompanionApp extends StatelessWidget {
  const CalmCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calm Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const AppShell(),
      },
    );
  }
}
