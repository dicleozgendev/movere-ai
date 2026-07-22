import 'package:flutter/material.dart';

/// Movere AI's standard AppBar.
///
/// Implementing PreferredSizeWidget is required: Scaffold needs to know in advance
/// the height of the widget passed to the appBar parameter.
class MovereAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MovereAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    // Color/text style comes from appBarTheme in AppTheme.
    return AppBar(title: Text(title), actions: actions);
  }
}

/// The app's 5 main tabs. The index order must match the BottomNav exactly.
enum MovereTab { dashboard, focus, progress, academy, settings }

/// Movere AI's bottom navigation bar.
///
/// For now it takes "which tab is selected" from the outside (currentIndex)
/// and reports the selection back out (onTap). The actual page transitions
/// will be wired up once navigation is set up.
class MovereBottomNav extends StatelessWidget {
  const MovereBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timer_outlined),
          activeIcon: Icon(Icons.timer),
          label: 'Focus',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insights_outlined),
          activeIcon: Icon(Icons.insights),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Academy',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          activeIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
