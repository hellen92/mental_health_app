import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'mascot_image.dart';

class BouncingMascot extends StatefulWidget {
  final double size;
  final Color? glowColor;

  const BouncingMascot({super.key, this.size = 180, this.glowColor});

  @override
  State<BouncingMascot> createState() => _BouncingMascotState();
}

class _BouncingMascotState extends State<BouncingMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _bounce = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = widget.glowColor ?? AppColors.mint;

    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounce.value),
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: glow.withValues(alpha: 0.35),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: MascotImage(size: widget.size),
      ),
    );
  }
}
