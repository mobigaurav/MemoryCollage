import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    return Theme(
      data: MbTheme.studio,
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: _ShelfBar(
          index: index,
          onSelect: (next) {
            navigationShell.goBranch(
              next,
              initialLocation: next == index,
            );
          },
        ),
      ),
    );
  }
}

class _ShelfBar extends StatelessWidget {
  const _ShelfBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    const bar = 62.0;
    const lift = 30.0;
    return SizedBox(
      height: bar + lift + bottom,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: bar + bottom,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFFFBF6),
                border: Border(top: BorderSide(color: MbTokens.linen)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: bottom,
            height: bar,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _Tab(
                  selected: index == 0,
                  icon: Icons.menu_book_outlined,
                  selectedIcon: Icons.menu_book,
                  label: 'Books',
                  onTap: () => onSelect(0),
                ),
                _Tab(
                  selected: index == 1,
                  icon: Icons.palette_outlined,
                  selectedIcon: Icons.palette,
                  label: 'Studio',
                  onTap: () => onSelect(1),
                ),
                Expanded(
                  child: _ReelsTab(
                    selected: index == 2,
                    onTap: () => onSelect(2),
                  ),
                ),
                _Tab(
                  selected: index == 3,
                  icon: Icons.public_outlined,
                  selectedIcon: Icons.public,
                  label: 'World',
                  onTap: () => onSelect(3),
                ),
                _Tab(
                  selected: index == 4,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: 'You',
                  onTap: () => onSelect(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? MbTokens.leather : MbTokens.inkSoft;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: MbTokens.sans,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReelsTab extends StatelessWidget {
  const _ReelsTab({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBF6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: MbTokens.leather.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: selected ? MbTokens.leatherDark : MbTokens.leather,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.movie_creation_outlined,
                  color: MbTokens.cream,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Reels',
              style: TextStyle(
                fontFamily: MbTokens.sans,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? MbTokens.leather : MbTokens.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
