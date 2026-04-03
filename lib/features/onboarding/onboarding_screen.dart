import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../theme/app_colors.dart';
import '../../widgets/bouncing_mascot.dart';

Future<LottieComposition?> _dotLottieDecoder(List<int> bytes) {
  return LottieComposition.decodeZip(
    bytes,
    filePicker: (files) {
      for (final file in files) {
        if (file.name.startsWith('animations/') && file.name.endsWith('.json')) {
          return file;
        }
      }

      for (final file in files) {
        if (file.name.endsWith('.json')) {
          return file;
        }
      }

      return null;
    },
  );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.mintLight, AppColors.cream],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  SizedBox(
                    height: 220,
                    child: Lottie.asset(
                      'assets/images/kawaii_animals_giving_love.lottie',
                      decoder: _dotLottieDecoder,
                      repeat: true,
                      fit: BoxFit.contain,
                      backgroundLoading: true,
                      errorBuilder: (context, error, stackTrace) {
                        return const BouncingMascot(size: 200);
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Calm Companion',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.greenDark,
                          fontSize: 32,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Build calm, one moment at a time',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 17,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                      child: const Text('Start'),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
