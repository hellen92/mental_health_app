import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/app_state.dart';
import '../../theme/app_colors.dart';
import '../../widgets/mascot_image.dart';
import '../../widgets/soft_card.dart';

enum BreathPhase { inhale, hold, exhale, idle }

class CalmScreen extends StatefulWidget {
  const CalmScreen({super.key});

  @override
  State<CalmScreen> createState() => _CalmScreenState();
}

class _CalmScreenState extends State<CalmScreen>
    with TickerProviderStateMixin {
  int _selectedMinutes = 2;
  bool _isRunning = false;
  bool _isComplete = false;
  int _elapsedSeconds = 0;
  int _earnedEnergy = 0;
  Timer? _timer;

  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  BreathPhase _phase = BreathPhase.idle;

  static const int _inhaleMs = 4000;
  static const int _holdMs = 4000;
  static const int _exhaleMs = 6000;
  static const int _cycleMs = _inhaleMs + _holdMs + _exhaleMs;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _cycleMs),
    );

    _breathAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: _inhaleMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: _holdMs.toDouble(),
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.6)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: _exhaleMs.toDouble(),
      ),
    ]).animate(_breathController);

    _breathController.addListener(_updatePhase);
  }

  void _updatePhase() {
    final progress = _breathController.value;
    final inhaleEnd = _inhaleMs / _cycleMs;
    final holdEnd = (_inhaleMs + _holdMs) / _cycleMs;

    BreathPhase newPhase;
    if (progress < inhaleEnd) {
      newPhase = BreathPhase.inhale;
    } else if (progress < holdEnd) {
      newPhase = BreathPhase.hold;
    } else {
      newPhase = BreathPhase.exhale;
    }

    if (newPhase != _phase && _isRunning) {
      setState(() => _phase = newPhase);
    }
  }

  int get _totalSeconds => _selectedMinutes * 60;

  void _start() {
    setState(() {
      _isRunning = true;
      _isComplete = false;
      _earnedEnergy = 0;
      _phase = BreathPhase.inhale;
    });
    _breathController.repeat();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= _totalSeconds) _complete();
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    _breathController.stop();
    setState(() => _isRunning = false);
  }

  void _resume() {
    setState(() => _isRunning = true);
    _breathController.repeat();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsedSeconds++;
        if (_elapsedSeconds >= _totalSeconds) _complete();
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    _breathController.stop();
    _breathController.reset();
    setState(() {
      _isRunning = false;
      _isComplete = false;
      _elapsedSeconds = 0;
      _earnedEnergy = 0;
      _phase = BreathPhase.idle;
    });
  }

  Future<void> _complete() async {
    _timer?.cancel();
    _breathController.stop();

    final energyGain = await AppStateScope.read(context)
        .completeBreathingSession(_selectedMinutes);

    setState(() {
      _isRunning = false;
      _isComplete = true;
      _earnedEnergy = energyGain;
      _phase = BreathPhase.idle;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  String get _phaseText {
    switch (_phase) {
      case BreathPhase.inhale:
        return 'Breathe in...';
      case BreathPhase.hold:
        return 'Hold...';
      case BreathPhase.exhale:
        return 'Breathe out...';
      case BreathPhase.idle:
        return 'Ready when you are';
    }
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _totalSeconds - _elapsedSeconds;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: _isComplete
            ? _buildCompleteState()
            : _buildActiveState(remaining),
      ),
    );
  }

  Widget _buildActiveState(int remaining) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          const MascotImage(size: 80),
          const SizedBox(height: 24),

          Text(
            'Breathing Session',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _phaseText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 40),

          // Breathing circle
          AnimatedBuilder(
            animation: _breathAnimation,
            builder: (context, child) {
              final scale = _isRunning || _elapsedSeconds > 0
                  ? _breathAnimation.value
                  : 0.6;
              return Container(
                width: 200 * scale,
                height: 200 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.mint.withValues(alpha: 0.8),
                      AppColors.mintLight.withValues(alpha: 0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.mint.withValues(alpha: 0.3),
                      blurRadius: 30 * scale,
                      spreadRadius: 10 * scale,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _formatTime(remaining.clamp(0, _totalSeconds)),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppColors.greenDark,
                          fontWeight: FontWeight.w300,
                          fontSize: 28,
                        ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),

          // Duration selector
          if (!_isRunning && _elapsedSeconds == 0) ...[
            Text(
              'Session length',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [1, 2, 5].map((min) {
                final isSelected = _selectedMinutes == min;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ChoiceChip(
                    label: Text('$min min'),
                    selected: isSelected,
                    onSelected: (_) =>
                        setState(() => _selectedMinutes = min),
                    selectedColor: AppColors.mint,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.greenDark
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.green
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isRunning) ...[
                _ControlButton(
                  icon: Icons.pause_rounded,
                  label: 'Pause',
                  onTap: _pause,
                ),
                const SizedBox(width: 20),
                _ControlButton(
                  icon: Icons.stop_rounded,
                  label: 'Reset',
                  onTap: _reset,
                  secondary: true,
                ),
              ] else if (_elapsedSeconds > 0 && !_isComplete) ...[
                _ControlButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Resume',
                  onTap: _resume,
                ),
                const SizedBox(width: 20),
                _ControlButton(
                  icon: Icons.stop_rounded,
                  label: 'Reset',
                  onTap: _reset,
                  secondary: true,
                ),
              ] else ...[
                SizedBox(
                  width: 200,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Start'),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildCompleteState() {
    final totalEnergy = AppStateScope.of(context).calmEnergy;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MascotImage(size: 140),
            const SizedBox(height: 32),
            Text(
              'Well done! 🌿',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.greenDark,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'You completed a $_selectedMinutes-minute session.\nYour mind and body thank you.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Reward card
            SoftCard(
              color: AppColors.mintLight,
              child: Column(
                children: [
                  const Text('🌿', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    'Your companion feels stronger!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.greenDark,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+$_earnedEnergy calm energy',
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
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: 200,
              height: 56,
              child: ElevatedButton(
                onPressed: _reset,
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool secondary;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: secondary
                  ? Colors.grey.withValues(alpha: 0.1)
                  : AppColors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: secondary ? AppColors.textSecondary : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}
