import 'package:auditlab/phase_one_auth/auth/auth_service/auth_service.dart';
import 'package:auditlab/phase_one_auth/cores/app_router.dart';
import 'package:auditlab/phase_two_core_features/pages/team_member_screen.dart';
import 'package:auditlab/phase_two_core_features/pages/analytics_dashboard.dart';
import 'package:auditlab/phase_two_core_features/pages/improved_assignments_screen.dart';
import 'package:auditlab/phase_two_core_features/pages/improved_periods_screen.dart';
import 'package:auditlab/phase_two_core_features/phase2_audit_logs_screen.dart';
import 'package:auditlab/phase_two_core_features/provider/user_provider.dart';
import 'package:auditlab/phase_two_core_features/widgets/universal_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/universal_bottom_nav.dart';

/// Navigation item model
class NavItem {
  final String label;
  final IconData icon;
  final Widget screen;
  final List<String> allowedRoles;
  final bool requiresSupervisor;

  const NavItem({
    required this.label,
    required this.icon,
    required this.screen,
    this.allowedRoles = const [],
    this.requiresSupervisor = false,
  });

  bool isAllowed(String? userRole) {
    if (allowedRoles.isEmpty) return true;
    if (userRole == null) return false;

    if (requiresSupervisor) {
      return userRole == 'DOF' || userRole == 'CA';
    }

    return allowedRoles.contains(userRole);
  }
}

/// Universal Layout - Adapts to screen size and user role
class UniversalLayout extends ConsumerStatefulWidget {
  const UniversalLayout({super.key});

  @override
  ConsumerState<UniversalLayout> createState() => _UniversalLayoutState();
}

class _UniversalLayoutState extends ConsumerState<UniversalLayout> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Navigation items - filtered by role
  final List<NavItem> _allNavItems = const [
    NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard,
      screen: ImprovedDashboard(),
    ),
    NavItem(label: 'Periods', icon: Icons.folder_open, screen: PeriodsScreen()),
    NavItem(
      label: 'My Assignments',
      icon: Icons.assignment_ind,
      screen: MyAssignmentsScreen(),
    ),
    NavItem(
      label: 'Audit Logs',
      icon: Icons.history,
      screen: AuditLogsScreen(),
      requiresSupervisor: true,
    ),
    NavItem(
      label: 'Team',
      icon: Icons.people,
      screen: TeamMembersScreen(),
      requiresSupervisor: true,
    ),
  ];

  List<NavItem> _getFilteredNavItems(String? userRole) {
    return _allNavItems.where((item) => item.isAllowed(userRole)).toList();
  }

  void _onNavItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Close drawer on mobile after selection
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final deviceType = getDeviceType(MediaQuery.of(context).size.width);

    return userDataAsync.when(
      data: (userData) {
        if (userData == null) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        final userRole = userData['role'] as String?;
        final filteredNavItems = _getFilteredNavItems(userRole);

        // Ensure selected index is valid
        if (_selectedIndex >= filteredNavItems.length) {
          _selectedIndex = 0;
        }

        final currentScreen = filteredNavItems.isEmpty
            ? const Center(child: Text('No accessible screens'))
            : filteredNavItems[_selectedIndex].screen;

        switch (deviceType) {
          case DeviceType.mobile:
            return _buildMobileLayout(
              currentScreen,
              filteredNavItems,
              userData,
            );

          case DeviceType.tablet:
            return _buildTabletLayout(
              currentScreen,
              filteredNavItems,
              userData,
            );

          case DeviceType.desktop:
            return _buildDesktopLayout(
              currentScreen,
              filteredNavItems,
              userData,
            );
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
      ),
    );
  }

  /// Mobile Layout - Bottom Navigation
  Widget _buildMobileLayout(
    Widget currentScreen,
    List<NavItem> navItems,
    Map<String, dynamic> userData,
  ) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: UniversalDrawer(
        userData: userData,
        selectedIndex: _selectedIndex,
        navItems: navItems,
        onItemSelected: _onNavItemSelected,
      ),
      body: currentScreen,
      bottomNavigationBar: UniversalBottomNav(
        selectedIndex: _selectedIndex,
        navItems: navItems,
        onItemSelected: _onNavItemSelected,
        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  /// Tablet Layout - Rail Navigation
  Widget _buildTabletLayout(
    Widget currentScreen,
    List<NavItem> navItems,
    Map<String, dynamic> userData,
  ) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onNavItemSelected,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  (userData['name'] as String?)
                          ?.substring(0, 1)
                          .toUpperCase() ??
                      'U',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            destinations: navItems
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: currentScreen),
        ],
      ),
    );
  }

  /// Desktop Layout - Permanent Drawer
  Widget _buildDesktopLayout(
    Widget currentScreen,
    List<NavItem> navItems,
    Map<String, dynamic> userData,
  ) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 280,
            child: UniversalDrawer(
              userData: userData,
              selectedIndex: _selectedIndex,
              navItems: navItems,
              onItemSelected: _onNavItemSelected,
              isPermanent: true,
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                _buildDesktopAppBar(userData),
                Expanded(child: currentScreen),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Desktop App Bar
  Widget _buildDesktopAppBar(Map<String, dynamic> userData) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              userData['districtName'] ?? 'Dashboard',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          // Search bar (placeholder)
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Notifications
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          // Profile
          PopupMenuButton(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    (userData['name'] as String?)
                            ?.substring(0, 1)
                            .toUpperCase() ??
                        'U',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  userData['name'] ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
          ),
        ],
      ),
    );
  }

  // And update _handleLogout method:
  void _handleLogout() async {
    final authService = ref.read(authServiceProvider); // ← Now works
    await authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}

// Provider for auth service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(); // Replace with your actual AuthService instance creation logic
});
