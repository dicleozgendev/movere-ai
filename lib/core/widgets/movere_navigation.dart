import 'package:flutter/material.dart';

/// Movere AI'ın standart AppBar'ı.
///
/// PreferredSizeWidget implementasyonu şart: Scaffold, appBar parametresine
/// verilen widget'ın yüksekliğini önceden bilmek ister.
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
    // Renk/yazı stili AppTheme'deki appBarTheme'den geliyor.
    return AppBar(title: Text(title), actions: actions);
  }
}

/// Uygulamanın 5 ana sekmesi. index sırası BottomNav ile birebir aynı olmalı.
enum MovereTab { dashboard, focus, progress, academy, settings }

/// Movere AI'ın alt navigasyon çubuğu.
///
/// Şimdilik "hangi sekme seçili" bilgisini dışarıdan alıyor (currentIndex)
/// ve seçimi dışarıya haber veriyor (onTap). Gerçek sayfa geçişleri
/// navigasyon kurulduğunda bağlanacak.
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
