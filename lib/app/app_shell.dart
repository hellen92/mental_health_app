import 'package:flutter/material.dart';
import '../features/home/home_screen.dart';
import '../features/calm/calm_screen.dart';
import '../features/move/move_screen.dart';
import '../features/progress/progress_screen.dart';
import '../theme/app_colors.dart';

/// Provides tab-switching capability to descendant widgets.
class TabSwitcher extends InheritedWidget {
  final void Function(int index) switchTo;

  const TabSwitcher({
    super.key,
    required this.switchTo,
    required super.child,
  });

  static TabSwitcher of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabSwitcher>()!;
  }

  @override
  bool updateShouldNotify(TabSwitcher oldWidget) => false;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    CalmScreen(),
    MoveScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return TabSwitcher(
      switchTo: (index) => setState(() => _currentIndex = index),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: _screens[_currentIndex],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
                selectedIcon:
                    Icon(Icons.home_rounded, color: AppColors.greenDark),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.spa_outlined, color: AppColors.textSecondary),
                selectedIcon:
                    Icon(Icons.spa_rounded, color: AppColors.greenDark),
                label: 'Calm',
              ),
              NavigationDestination(
                icon: Icon(Icons.directions_walk_outlined,
                    color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.directions_walk_rounded,
                    color: AppColors.greenDark),
                label: 'Move',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined,
                    color: AppColors.textSecondary),
                selectedIcon:
                    Icon(Icons.bar_chart_rounded, color: AppColors.greenDark),
                label: 'Progress',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
