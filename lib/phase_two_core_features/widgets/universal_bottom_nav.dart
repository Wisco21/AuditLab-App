import 'package:auditlab/phase_two_core_features/universal_layout_main.dart';
import 'package:flutter/material.dart';

class UniversalBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<NavItem> navItems;
  final Function(int) onItemSelected;
  final VoidCallback onMenuTap;

  const UniversalBottomNav({
    super.key,
    required this.selectedIndex,
    required this.navItems,
    required this.onItemSelected,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    // Limit to 5 items max (4 nav items + 1 menu button)
    final displayItems = navItems.take(4).toList();
    final hasMore = navItems.length > 4;

    return NavigationBar(
      selectedIndex: selectedIndex < displayItems.length ? selectedIndex : 0,
      onDestinationSelected: (index) {
        if (index < displayItems.length) {
          onItemSelected(index);
        } else if (hasMore) {
          onMenuTap();
        }
      },
      destinations: [
        ...displayItems.asMap().entries.map((entry) {
          final item = entry.value;
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(
              item.icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: item.label,
          );
        }),
        if (hasMore)
          const NavigationDestination(icon: Icon(Icons.menu), label: 'More'),
      ],
    );
  }
}
