import 'package:auditlab/auth/auth_service.dart';
import 'package:auditlab/phase2/universal_layout_main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UniversalDrawer extends ConsumerWidget {
  final Map<String, dynamic> userData;
  final int selectedIndex;
  final List<NavItem> navItems;
  final Function(int) onItemSelected;
  final bool isPermanent;

  const UniversalDrawer({
    super.key,
    required this.userData,
    required this.selectedIndex,
    required this.navItems,
    required this.onItemSelected,
    this.isPermanent = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRole = userData['role'] as String?;
    final userName = userData['name'] as String?;
    final userEmail = userData['email'] as String?;
    final districtName = userData['districtName'] as String?;

    return Drawer(
      child: Column(
        children: [
          // User Profile Header
          _buildProfileHeader(
            context,
            userName,
            userEmail,
            userRole,
            districtName,
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return _buildNavTile(
                    context,
                    item,
                    index,
                    selectedIndex == index,
                  );
                }),

                const Divider(),

                // Settings
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to settings
                  },
                ),

                // Help & Support
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & Support'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to help
                  },
                ),
              ],
            ),
          ),

          // Logout Button
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () => _handleLogout(context, ref),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String? userName,
    String? userEmail,
    String? userRole,
    String? districtName,
  ) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          userName?.substring(0, 1).toUpperCase() ?? 'U',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      accountName: Row(
        children: [
          Text(userName ?? 'User'),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userRole ?? '',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      accountEmail: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(userEmail ?? ''),
          if (districtName != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    districtName,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context,
    NavItem item,
    int index,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[700],
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[800],
          ),
        ),
        selected: isSelected,
        onTap: () => onItemSelected(index),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final authService = AuthService();
      await authService.signOut();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}
